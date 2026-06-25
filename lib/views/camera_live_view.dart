import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/seekr_controller.dart';
import '../data/device_image_source.dart';
import '../domain/models.dart';
import '../services/live_frame_gate.dart';
import 'widgets/camera_preview_box.dart';

class CameraLiveView extends StatefulWidget {
  const CameraLiveView({
    required this.initialMode,
    super.key,
  });

  final SeekrMode initialMode;

  @override
  State<CameraLiveView> createState() => _CameraLiveViewState();
}

class _CameraLiveViewState extends State<CameraLiveView> {
  static const _captureInterval = Duration(seconds: 1);
  static const _captureTimeout = Duration(seconds: 4);

  late final SeekrController _controller;
  late final DeviceImageSource _source;
  late final SeekrMode _mode;
  Timer? _timer;
  bool _initializing = true;
  bool _processing = false;
  bool _torchOn = false;
  bool _released = false;
  String _status = 'Opening camera...';
  final LiveFrameGate _frameGate = LiveFrameGate();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SeekrController>();
    _source = Get.find<DeviceImageSource>();
    _mode = widget.initialMode == SeekrMode.none
        ? SeekrMode.textRecognition
        : widget.initialMode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_start());
    });
  }

  Future<void> _start() async {
    _controller.prepareLiveMode(_mode);
    try {
      if (!_source.isReady) {
        await _source.initialize();
      }
      await _source.setTorchMode(false);
      _controller.cameraController.value = _source.cameraController;
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _status = 'Point camera at something. Descriptions update live.';
      });
      await _analyzeFrame();
      _timer = Timer.periodic(_captureInterval, (_) => _analyzeFrame());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _status = 'Camera unavailable: $e';
      });
    }
  }

  Future<void> _analyzeFrame() async {
    if (_processing || !mounted || _released) return;
    final ticket = _frameGate.begin();
    _processing = true;
    try {
      final description =
          await _controller.describeLiveFrame(_mode).timeout(_captureTimeout);
      if (!mounted || _released || !_frameGate.tryApply(ticket)) return;
      setState(() => _status = description);
      // Obstacle alerts are driven by _onDistance (safety priority + cooldown).
      if (_mode != SeekrMode.depthObstacle) {
        _controller.announceLive(description);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _status = 'Camera is still adjusting...');
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _toggleTorch() async {
    final next = !_torchOn;
    final ok = await _source.setTorchMode(next);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Torch is not available on this camera.')),
      );
      setState(() => _torchOn = false);
      return;
    }
    setState(() => _torchOn = next);
  }

  Future<void> _close() async {
    await _releaseCamera();
    if (mounted) Get.back<void>();
  }

  Future<void> _releaseCamera() async {
    if (_released) return;
    _released = true;
    _frameGate.reset();
    _timer?.cancel();
    _timer = null;
    _controller.stopSpeaking();
    _controller.cameraController.value = null;
    await _source.setTorchMode(false);
    await _source.dispose();
  }

  void _releaseCameraSync() {
    if (_released) return;
    _released = true;
    _frameGate.reset();
    _timer?.cancel();
    _timer = null;
    _controller.stopSpeaking();
    _controller.cameraController.value = null;
    _source.setTorchMode(false).ignore();
    _source.dispose().ignore();
  }

  @override
  void dispose() {
    _releaseCameraSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        _releaseCameraSync();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() {
              final camera = _controller.cameraController.value;
              if (camera != null && camera.value.isInitialized) {
                return CameraPreviewBox(controller: camera);
              }
              return ColoredBox(
                color: Colors.black,
                child: Center(
                  child: _initializing
                      ? const CircularProgressIndicator()
                      : Text(
                          _status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              );
            }),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _RoundIconButton(
                      tooltip: 'Close live camera',
                      icon: Icons.close_rounded,
                      onPressed: _close,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Text(
                            _mode.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _RoundIconButton(
                      tooltip: _torchOn
                          ? 'Turn flashlight off'
                          : 'Turn flashlight on',
                      icon: _torchOn
                          ? Icons.flashlight_off_rounded
                          : Icons.flashlight_on_rounded,
                      onPressed: _toggleTorch,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                minimum: const EdgeInsets.all(16),
                child: Semantics(
                  liveRegion: true,
                  label: 'Live description. $_status',
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(190),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: _processing
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primary,
                                    ),
                                  )
                                : Icon(
                                    Icons.record_voice_over_rounded,
                                    color: cs.primary,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.black.withAlpha(165),
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
