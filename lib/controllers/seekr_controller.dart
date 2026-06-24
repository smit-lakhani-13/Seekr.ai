import 'dart:async';

import 'package:get/get.dart';

import '../data/device_service.dart';
import '../domain/models.dart';
import '../services/audio_queue.dart';
import '../services/tts_service.dart';

/// Orchestrates the whole experience and exposes reactive state to the UI.
///
/// Flow:  device stream  ->  active mode logic  ->  audio queue  ->  TTS
/// Depth/Obstacle mode feeds distances to an obstacle alerter (threshold +
/// cooldown so it never spams). Descriptive modes emit periodic descriptions.
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

  // ----- internals -----
  StreamSubscription<double>? _distanceSub;
  StreamSubscription<DeviceConnectionState>? _connSub;
  Timer? _descriptionTimer;
  DateTime? _lastObstacleAlert;
  int _sceneIndex = 0;

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
    _audio.clear();
    nowSpeaking.value = null;
    _descriptionTimer?.cancel();
    _announce('${mode.label} activated. ${mode.description}', AudioPriority.normal);

    final descriptive = mode == SeekrMode.sceneDetection ||
        mode == SeekrMode.textRecognition ||
        mode == SeekrMode.supermarket;
    if (descriptive) {
      _descriptionTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _emitDescription(mode),
      );
    }
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

  void _emitDescription(SeekrMode mode) {
    final samples = _samplesFor(mode);
    final text = samples[_sceneIndex % samples.length];
    _sceneIndex++;
    _announce(text, AudioPriority.normal);
  }

  List<String> _samplesFor(SeekrMode mode) {
    switch (mode) {
      case SeekrMode.sceneDetection:
        return const [
          'A bright room with a window on your left and two people seated ahead.',
          'An open doorway about three metres in front of you.',
          'A pavement with a bench on the right.',
        ];
      case SeekrMode.textRecognition:
        return const [
          'Sign reads: Platform 2, trains to the city centre.',
          'Menu: coffee, two dollars fifty. Tea, two dollars.',
          'Label reads: paracetamol, take one tablet twice daily.',
        ];
      case SeekrMode.supermarket:
        return const [
          'Aisle 4: breakfast cereals on your right.',
          'Product: one litre whole milk, expires in five days.',
          'Aisle 7: cleaning supplies ahead.',
        ];
      default:
        return const ['No description available.'];
    }
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
    _descriptionTimer?.cancel();
    _device.dispose();
    super.onClose();
  }
}
