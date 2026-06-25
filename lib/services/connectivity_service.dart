import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import '../domain/models.dart';
import '../services/audio_queue.dart';

// ── Interface ────────────────────────────────────────────────────────────────

abstract class ConnectivityService {
  /// True when at least one internet-capable network is available.
  Stream<bool> get onlineStream;
  bool get isOnline;

  /// Connect to the wearable's local AP (Android 10+ only; no-op otherwise).
  Future<void> connectToDeviceAP({required String ssid, String? bssid});

  /// Release the wearable AP connection held by WifiNetworkSpecifier.
  Future<void> disconnectFromDeviceAP();

  /// Ensure a cellular network is held for cloud calls (Android).
  Future<void> requestCellular();

  CloudRouteState get cloudRouteState;
  Stream<CloudRouteState> get cloudRouteStream;

  /// Prefer cellular for Tier-2 cloud calls while leaving WiFi available for
  /// the local device AP. Unsupported platforms fall back to default internet.
  Future<void> setPreferCellularForCloud(bool enabled);

  /// Android-only helper for per-network HTTP over cellular. Returns null when
  /// unsupported/unavailable so callers can use the default route.
  Future<NativeHttpResponse?> postJsonViaCellular({
    required Uri uri,
    required Map<String, dynamic> body,
  });

  /// Run [call], classifying failures and applying retry/backoff/TTS fallback.
  /// - SocketException / TimeoutException -> network fail -> retry up to [maxRetries].
  /// - Other exceptions (server errors etc.) -> rethrow immediately, no retry.
  Future<T> withRetry<T>(
    Future<T> Function() call, {
    AudioQueue? audioQueue,
    int maxRetries = 1,
  });

  void dispose();
}

class CloudRouteState {
  const CloudRouteState({
    required this.preferCellular,
    required this.cellularReady,
    required this.lastMessage,
  });

  final bool preferCellular;
  final bool cellularReady;
  final String lastMessage;

  CloudRouteState copyWith({
    bool? preferCellular,
    bool? cellularReady,
    String? lastMessage,
  }) {
    return CloudRouteState(
      preferCellular: preferCellular ?? this.preferCellular,
      cellularReady: cellularReady ?? this.cellularReady,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}

class NativeHttpResponse {
  const NativeHttpResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;
}

// ── Implementation ───────────────────────────────────────────────────────────

class ConnectivityServiceImpl implements ConnectivityService {
  static const _networkChannel = MethodChannel('seekr/network');
  static const _networkLostChannel = EventChannel('seekr/network_lost');

  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _sub;
  final _onlineController = StreamController<bool>.broadcast();
  final _routeController = StreamController<CloudRouteState>.broadcast();
  bool _isOnline = false;
  CloudRouteState _cloudRouteState = const CloudRouteState(
    preferCellular: false,
    cellularReady: false,
    lastMessage: 'Default internet route',
  );

  ConnectivityServiceImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  void _init() {
    _connectivity.checkConnectivity().then(_updateOnline);
    _sub = _connectivity.onConnectivityChanged.listen(_updateOnline);
    _networkLostChannel.receiveBroadcastStream().listen((event) {
      if (event == 'cellular_lost') {
        _setRouteState(
          _cloudRouteState.copyWith(
            cellularReady: false,
            lastMessage: 'Cellular route lost; using default internet',
          ),
        );
      }
    });
  }

  void _updateOnline(List<ConnectivityResult> results) {
    final online = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
    if (online != _isOnline) {
      _isOnline = online;
      _onlineController.add(online);
    }
  }

  @override
  Stream<bool> get onlineStream => _onlineController.stream;

  @override
  bool get isOnline => _isOnline;

  @override
  CloudRouteState get cloudRouteState => _cloudRouteState;

  @override
  Stream<CloudRouteState> get cloudRouteStream => _routeController.stream;

  @override
  Future<void> connectToDeviceAP({required String ssid, String? bssid}) async {
    try {
      await _networkChannel.invokeMethod<void>('connectToDeviceAP', {
        'ssid': ssid,
        if (bssid != null) 'bssid': bssid,
      });
    } on PlatformException catch (e) {
      if (e.code == 'UNSUPPORTED') {
        return; // Android <10 or iOS: degrade gracefully
      }
      rethrow;
    }
  }

  @override
  Future<void> disconnectFromDeviceAP() async {
    try {
      await _networkChannel.invokeMethod<void>('releaseDeviceAP');
    } on PlatformException {
      // No-op on non-Android or if AP was never connected.
    }
  }

  @override
  Future<void> requestCellular() async {
    try {
      final ok =
          await _networkChannel.invokeMethod<bool>('requestCellularNetwork');
      _setRouteState(
        _cloudRouteState.copyWith(
          cellularReady: ok == true,
          lastMessage: ok == true
              ? 'Cellular network held for cloud calls'
              : 'Cellular route unavailable; using default internet',
        ),
      );
    } on PlatformException {
      _setRouteState(
        _cloudRouteState.copyWith(
          cellularReady: false,
          lastMessage: 'Cellular route unavailable; using default internet',
        ),
      );
    }
  }

  @override
  Future<void> setPreferCellularForCloud(bool enabled) async {
    _setRouteState(
      _cloudRouteState.copyWith(
        preferCellular: enabled,
        lastMessage: enabled
            ? 'Requesting mobile-data cloud route...'
            : 'Using default internet route',
      ),
    );
    if (enabled) await requestCellular();
  }

  @override
  Future<NativeHttpResponse?> postJsonViaCellular({
    required Uri uri,
    required Map<String, dynamic> body,
  }) async {
    if (!_cloudRouteState.preferCellular) return null;
    if (!_cloudRouteState.cellularReady) await requestCellular();
    if (!_cloudRouteState.cellularReady) return null;

    try {
      final response = await _networkChannel.invokeMapMethod<String, dynamic>(
        'postJsonViaCellular',
        {
          'url': uri.toString(),
          'body': jsonEncode(body),
        },
      );
      if (response == null) return null;
      return NativeHttpResponse(
        statusCode: response['statusCode'] as int,
        body: response['body'] as String,
      );
    } on PlatformException catch (e) {
      _setRouteState(
        _cloudRouteState.copyWith(
          cellularReady: false,
          lastMessage:
              '${e.message ?? 'Cellular route failed'}; using default internet',
        ),
      );
      return null;
    }
  }

  @override
  Future<T> withRetry<T>(
    Future<T> Function() call, {
    AudioQueue? audioQueue,
    int maxRetries = 1,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 1);
    const maxDelay = Duration(seconds: 30);

    while (true) {
      try {
        return await call().timeout(const Duration(seconds: 15));
      } on SocketException {
        if (attempt >= maxRetries) {
          _speakConnectionLost(audioQueue);
          rethrow;
        }
      } on TimeoutException {
        if (attempt >= maxRetries) {
          _speakConnectionLost(audioQueue);
          rethrow;
        }
      }
      // Other exceptions (server errors, parse failures) bubble up immediately.

      attempt++;
      await Future<void>.delayed(delay);
      delay = delay * 2;
      if (delay > maxDelay) delay = maxDelay;
    }
  }

  void _speakConnectionLost(AudioQueue? queue) {
    queue?.enqueue(
        const Utterance('Connection lost, please wait', AudioPriority.safety));
  }

  void _setRouteState(CloudRouteState state) {
    _cloudRouteState = state;
    _routeController.add(state);
  }

  @override
  void dispose() {
    _sub.cancel();
    _onlineController.close();
    _routeController.close();
  }
}

// ── No-op for tests / web ────────────────────────────────────────────────────

class NoopConnectivityService implements ConnectivityService {
  bool _online;
  final _controller = StreamController<bool>.broadcast();
  final _routeController = StreamController<CloudRouteState>.broadcast();
  CloudRouteState _routeState = const CloudRouteState(
    preferCellular: false,
    cellularReady: false,
    lastMessage: 'Default internet route',
  );

  NoopConnectivityService({bool online = true}) : _online = online;

  void setOnline(bool v) {
    _online = v;
    _controller.add(v);
  }

  @override
  Stream<bool> get onlineStream => _controller.stream;
  @override
  bool get isOnline => _online;
  @override
  Future<void> connectToDeviceAP({required String ssid, String? bssid}) async {}
  @override
  Future<void> disconnectFromDeviceAP() async {}
  @override
  Future<void> requestCellular() async {}
  @override
  CloudRouteState get cloudRouteState => _routeState;
  @override
  Stream<CloudRouteState> get cloudRouteStream => _routeController.stream;
  @override
  Future<void> setPreferCellularForCloud(bool enabled) async {
    _routeState = CloudRouteState(
      preferCellular: enabled,
      cellularReady: false,
      lastMessage: enabled
          ? 'Cellular route requires Android device with SIM'
          : 'Default internet route',
    );
    _routeController.add(_routeState);
  }

  @override
  Future<NativeHttpResponse?> postJsonViaCellular({
    required Uri uri,
    required Map<String, dynamic> body,
  }) async =>
      null;

  @override
  Future<T> withRetry<T>(
    Future<T> Function() call, {
    AudioQueue? audioQueue,
    int maxRetries = 1,
  }) =>
      call();
  @override
  void dispose() {
    _controller.close();
    _routeController.close();
  }
}
