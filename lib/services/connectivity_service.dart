import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import '../services/audio_queue.dart';
import '../domain/models.dart';

// ── Interface ────────────────────────────────────────────────────────────────

abstract class ConnectivityService {
  /// True when at least one internet-capable network is available.
  Stream<bool> get onlineStream;
  bool get isOnline;

  /// Connect to the wearable's local AP (Android 10+ only; no-op otherwise).
  Future<void> connectToDeviceAP({required String ssid, String? bssid});

  /// Ensure a cellular network is held for cloud calls (Android).
  Future<void> requestCellular();

  /// Run [call], classifying failures and applying retry/backoff/TTS fallback.
  /// - SocketException / TimeoutException → network fail → retry up to [maxRetries].
  /// - Other exceptions (server errors etc.) → rethrow immediately, no retry.
  Future<T> withRetry<T>(
    Future<T> Function() call, {
    AudioQueue? audioQueue,
    int maxRetries = 1,
  });

  void dispose();
}

// ── Implementation ───────────────────────────────────────────────────────────

class ConnectivityServiceImpl implements ConnectivityService {
  static const _networkChannel = MethodChannel('seekr/network');
  static const _networkLostChannel = EventChannel('seekr/network_lost');

  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _sub;
  final _onlineController = StreamController<bool>.broadcast();
  bool _isOnline = false;

  ConnectivityServiceImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  void _init() {
    _connectivity.checkConnectivity().then(_updateOnline);
    _sub = _connectivity.onConnectivityChanged.listen(_updateOnline);
    _networkLostChannel.receiveBroadcastStream().listen((event) {
      if (event == 'cellular_lost') _onlineController.add(false);
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
  Future<void> requestCellular() async {
    try {
      await _networkChannel.invokeMethod<void>('requestCellularNetwork');
    } on PlatformException {
      // Non-Android or no SIM: swallow; cloud calls still work via default route.
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
      // Exponential backoff capped at 30 s.
      delay = delay * 2;
      if (delay > maxDelay) delay = maxDelay;
    }
  }

  void _speakConnectionLost(AudioQueue? queue) {
    queue?.enqueue(
        const Utterance('Connection lost, please wait', AudioPriority.safety));
  }

  @override
  void dispose() {
    _sub.cancel();
    _onlineController.close();
  }
}

// ── No-op for tests / web ────────────────────────────────────────────────────

class NoopConnectivityService implements ConnectivityService {
  bool _online;
  final _controller = StreamController<bool>.broadcast();

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
  Future<void> requestCellular() async {}
  @override
  Future<T> withRetry<T>(
    Future<T> Function() call, {
    AudioQueue? audioQueue,
    int maxRetries = 1,
  }) =>
      call();
  @override
  void dispose() => _controller.close();
}
