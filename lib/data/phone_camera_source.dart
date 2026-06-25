import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'device_image_source.dart';

/// Uses the phone's back camera as a stand-in for the wearable camera.
/// Snapshot-on-trigger (takePicture) is the primary path.
/// Swap this out for a WiFi socket source when the real device arrives.
class PhoneCameraSource implements DeviceImageSource {
  CameraController? _controller;
  bool _ready = false;

  // Target < 150 KB per frame for comfortable Tier-2 cloud upload over ~1 Mbps.
  static const _targetWidth = 640;
  static const _jpegQuality = 70;

  @override
  Future<void> initialize() async {
    if (_ready) return; // idempotent: second call is a no-op
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception('Camera permission denied');
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception('No cameras available');

    // Use back camera; fall back to first available.
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset
          .medium, // 720p on most devices; downsized further on capture
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
    _ready = true;
  }

  @override
  bool get isReady => _ready && (_controller?.value.isInitialized ?? false);

  @override
  CameraController? get cameraController => _controller;

  @override
  Future<List<int>> captureFrame() async {
    if (!isReady) throw StateError('PhoneCameraSource not initialized');

    final xfile = await _controller!.takePicture();
    final bytes = await xfile.readAsBytes();

    // Downscale + JPEG compress to keep cloud upload small (< ~150 KB).
    return await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: _targetWidth,
      minHeight: 1, // maintain aspect ratio
      quality: _jpegQuality,
      format: CompressFormat.jpeg,
    );
  }

  @override
  Future<void> dispose() async {
    _ready = false;
    await _controller?.dispose();
    _controller = null;
  }
}
