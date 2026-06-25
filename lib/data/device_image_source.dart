import 'dart:async';
import 'package:camera/camera.dart';

// ── Interface ────────────────────────────────────────────────────────────────
// Abstracts the image source so the real wearable WiFi stream drops in later
// without touching controllers or views.

abstract class DeviceImageSource {
  /// Initialize (request permission, open camera/socket).
  Future<void> initialize();

  /// Whether the source is ready to capture.
  bool get isReady;

  /// Capture a single frame for cloud upload.
  /// Returns raw JPEG bytes (already downscaled — see PhoneCameraSource).
  Future<List<int>> captureFrame();

  /// Live preview widget (null for non-camera sources).
  CameraController? get cameraController;

  Future<void> dispose();
}

// ── Simulated source (for tests / web) ───────────────────────────────────────
// ponytail: no-op source keeps tests free of platform channels.

class SimulatedImageSource implements DeviceImageSource {
  @override
  Future<void> initialize() async {}
  @override
  bool get isReady => true;
  @override
  Future<List<int>> captureFrame() async =>
      List<int>.generate(1024, (i) => i % 256); // dummy bytes
  @override
  CameraController? get cameraController => null;
  @override
  Future<void> dispose() async {}
}
