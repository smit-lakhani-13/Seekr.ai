import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Aspect-preserving camera preview.
///
/// CameraPreview stretches if it is forced into an arbitrary SizedBox. This
/// wrapper gives the texture its native preview dimensions, then crops with
/// BoxFit.cover so the image stays natural in cards and full-screen views.
class CameraPreviewBox extends StatelessWidget {
  const CameraPreviewBox({
    required this.controller,
    this.fit = BoxFit.cover,
    super.key,
  });

  final CameraController controller;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (!controller.value.isInitialized || previewSize == null) {
      return const ColoredBox(color: Colors.black);
    }

    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait =
              MediaQuery.orientationOf(context) == Orientation.portrait;
          final width = isPortrait ? previewSize.height : previewSize.width;
          final height = isPortrait ? previewSize.width : previewSize.height;

          return FittedBox(
            fit: fit,
            child: SizedBox(
              width: width,
              height: height,
              child: CameraPreview(controller),
            ),
          );
        },
      ),
    );
  }
}
