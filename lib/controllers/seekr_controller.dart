import 'dart:async';

import 'package:camera/camera.dart';
import 'package:get/get.dart';

import '../data/device_image_source.dart';
import '../services/connectivity_service.dart';
import '../services/local_vision_service.dart';
import '../data/device_service.dart';
import '../services/vision_router.dart';
import '../domain/models.dart';
import '../services/audio_queue.dart';
import '../services/cloud_vision_service.dart';
import '../services/live_speech_policy.dart';
import '../services/tts_service.dart';

/// Orchestrates the whole experience and exposes reactive state to the UI.
///
/// Flow:  device stream  ->  active mode logic  ->  audio queue  ->  TTS
/// Depth/Obstacle mode feeds distances to an obstacle alerter (threshold +
/// cooldown so it never spams). Descriptive modes are selected here; actual
/// live descriptions run in the full-screen camera view.
class SeekrController extends GetxController {
  final DeviceService _device;
  final TtsService _tts;
  late final AudioQueue _audio;

  SeekrController(this._device, this._tts);

  // ----- reactive state (observed by the UI) -----
  final Rx<DeviceConnectionState> connection =
      DeviceConnectionState.disconnected.obs;
  final Rx<SeekrMode> activeMode = SeekrMode.none.obs;
  final RxnDouble lastDistance = RxnDouble();
  final RxnString nowSpeaking = RxnString();
  final RxList<String> spokenLog = <String>[].obs;
  final RxDouble obstacleThreshold = 2.0.obs;
  final RxBool isCapturing = false.obs;
  // Reactive camera controller — set after source.initialize() so _CameraPreviewCard rebuilds.
  final Rx<CameraController?> cameraController = Rx<CameraController?>(null);

  // ----- internals -----
  StreamSubscription<double>? _distanceSub;
  StreamSubscription<DeviceConnectionState>? _connSub;
  DateTime? _lastObstacleAlert;
  final LiveSpeechPolicy _liveSpeechPolicy = LiveSpeechPolicy();

  static const Duration _cooldown = Duration(seconds: 3);

  @override
  void onInit() {
    super.onInit();
    _audio = AudioQueue(
      _tts,
      onSpeakStart: (t) => nowSpeaking.value = t,
      onSpeakEnd: () => nowSpeaking.value = null,
    );
    _tts.init();
    _connSub = _device.connectionStream.listen((s) => connection.value = s);
    _distanceSub = _device.distanceStream.listen(_onDistance);
  }

  Future<void> connect() => _device.connect();

  void selectMode(SeekrMode mode) {
    activeMode.value = mode;
    stopSpeaking();
    _liveSpeechPolicy.reset();
    _announce(
        '${mode.label} activated. ${mode.description}', AudioPriority.normal);
  }

  /// Tap active mode → stop. Tap inactive mode → activate.
  void toggleMode(SeekrMode mode) {
    if (activeMode.value == mode) {
      stopMode();
    } else {
      selectMode(mode);
    }
  }

  /// Stop the current mode, clear audio, reset to none.
  void stopMode() {
    final stoppedMode = activeMode.value;
    activeMode.value = SeekrMode.none;
    _liveSpeechPolicy.reset();
    stopSpeaking();
    if (stoppedMode != SeekrMode.none) {
      spokenLog.insert(0, '${stoppedMode.label} stopped.');
      if (spokenLog.length > 20) spokenLog.removeLast();
    }
  }

  void stopSpeaking() {
    _audio.clear();
    _liveSpeechPolicy.reset();
    nowSpeaking.value = null;
  }

  /// Called by the full-screen camera view before starting its live loop.
  void prepareLiveMode(SeekrMode mode) {
    activeMode.value = mode;
    _liveSpeechPolicy.reset();
    stopSpeaking();
  }

  /// Speak live text only when the scene meaningfully changes.
  ///
  /// Live camera audio is latest-result-wins: the newest useful description
  /// replaces queued/current normal speech, while safety alerts keep their
  /// separate interrupt path.
  bool announceLive(String text) {
    final decision = _liveSpeechPolicy.decide(text);
    if (!decision.shouldSpeak) return false;

    _audio.replace(Utterance(text, AudioPriority.normal));
    spokenLog.insert(0, text);
    if (spokenLog.length > 20) spokenLog.removeLast();
    return true;
  }

  void _onDistance(double d) {
    lastDistance.value = d;
    if (activeMode.value != SeekrMode.depthObstacle) return;
    if (d >= obstacleThreshold.value) return;

    final now = DateTime.now();
    if (_lastObstacleAlert != null &&
        now.difference(_lastObstacleAlert!) < _cooldown) {
      return; // cooldown: don't spam "obstacle, obstacle, obstacle"
    }
    _lastObstacleAlert = now;
    _announce(
      'Obstacle ${d.toStringAsFixed(1)} metres ahead',
      AudioPriority.safety, // interrupts any current description
    );
  }

  /// Snapshot-on-trigger: initialize source if needed, capture one frame,
  /// route it through the hybrid vision router, then speak the result.
  Future<void> captureAndDescribe() async {
    if (isCapturing.value) return; // debounce rapid taps
    isCapturing.value = true;
    try {
      final source = Get.find<DeviceImageSource>();
      if (!source.isReady) {
        try {
          await source.initialize();
        } catch (e) {
          _announce('Camera unavailable: $e', AudioPriority.safety);
          return;
        }
      }
      // Notify _CameraPreviewCard to show live preview after first init.
      if (cameraController.value == null) {
        cameraController.value = source.cameraController;
      }
      final bytes = await source.captureFrame();
      final router = Get.find<VisionRouter>();
      final description = await router.route(
        bytes,
        activeMode.value,
        triggered: true,
      );
      _announce(description, AudioPriority.normal);
    } catch (e) {
      _announce('Capture failed, please try again.', AudioPriority.safety);
    } finally {
      isCapturing.value = false;
    }
  }

  /// Fast live-camera path: Tier 1 only, no cloud upload. This keeps the
  /// full-screen view responsive and avoids sending continuous video frames.
  Future<String> describeLiveFrame(
    SeekrMode mode, {
    bool enrichWithCloud = false,
  }) async {
    final source = Get.find<DeviceImageSource>();
    if (!source.isReady) {
      await source.initialize();
    }
    cameraController.value = source.cameraController;

    if (mode == SeekrMode.depthObstacle) {
      final distance = lastDistance.value;
      return distance == null
          ? 'Obstacle mode active. No distance reading yet.'
          : 'Nearest object ${distance.toStringAsFixed(1)} metres ahead.';
    }

    final bytes = await source.captureFrame();

    if (enrichWithCloud &&
        (mode == SeekrMode.none || mode == SeekrMode.sceneDetection) &&
        Get.find<ConnectivityService>().isOnline) {
      try {
        return await Get.find<CloudVisionService>().describe(
          bytes,
          SeekrMode.sceneDetection,
        );
      } catch (_) {
        // Fall through to Tier-1 local result.
      }
    }

    final local = Get.find<LocalVisionService>();
    final result = await local.analyze(bytes, mode);
    if (result != null && result.trim().isNotEmpty) return result;

    return switch (mode) {
      SeekrMode.textRecognition => 'No text detected yet.',
      SeekrMode.supermarket => 'No product detected yet.',
      SeekrMode.sceneDetection => 'Looking around. Nothing clear detected yet.',
      SeekrMode.none => 'Looking around. Nothing clear detected yet.',
      _ => 'Looking around. Nothing clear detected yet.',
    };
  }

  void _announce(String text, AudioPriority priority) {
    _audio.enqueue(Utterance(text, priority));
    spokenLog.insert(0, text);
    if (spokenLog.length > 20) spokenLog.removeLast();
  }

  @override
  void onClose() {
    _distanceSub?.cancel();
    _connSub?.cancel();
    cameraController.value = null;
    _device.dispose();
    // Fire-and-forget async dispose of platform resources.
    // .ignore() suppresses unhandled future errors; try/catch handles Get.find miss.
    try {
      Get.find<DeviceImageSource>().dispose().ignore();
    } catch (_) {}
    try {
      Get.find<LocalVisionService>().dispose().ignore();
    } catch (_) {}
    try {
      Get.find<ConnectivityService>().dispose();
    } catch (_) {}
    super.onClose();
  }
}
