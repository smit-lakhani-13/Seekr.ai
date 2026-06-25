import '../domain/models.dart';
import 'cloud_vision_service.dart';
import 'connectivity_service.dart';
import 'local_vision_service.dart';

/// Routes a captured frame to the correct vision tier.
///
/// Routing rules (matches Seekr's three-tier hybrid architecture):
///   depthObstacle   → always Tier 1 (safety; must never depend on network)
///   textRecognition → local-first (ML Kit OCR); cloud only when local finds nothing
///   supermarket     → local-first (ML Kit barcode/labels); cloud only when local finds nothing
///   sceneDetection  → cloud-first when user-triggered + online; local as fallback
///
/// No explicit user trigger → never uploads to cloud.
/// Offline → Tier 1 or spoken "no connection" message; never silent failure.
class VisionRouter {
  final LocalVisionService _local;
  final CloudVisionService _cloud;
  final ConnectivityService _connectivity;

  VisionRouter(this._local, this._cloud, this._connectivity);

  /// [triggered] = true when the user explicitly pressed "Describe".
  Future<String> route(
    List<int> imageBytes,
    SeekrMode mode, {
    bool triggered = false,
    String? question,
  }) async {
    // Safety: depth/obstacle is always on-device — never blocked on a network round-trip.
    if (mode == SeekrMode.depthObstacle) {
      return await _local.analyze(imageBytes, mode) ??
          'Obstacle detection active.';
    }

    // OCR + barcode: local-first (fast, offline, often sufficient for clear text/products).
    // Escalate to cloud only when local finds nothing AND user triggered AND online.
    if (mode == SeekrMode.textRecognition || mode == SeekrMode.supermarket) {
      final localResult = await _local.analyze(imageBytes, mode);
      if (localResult != null) return localResult;
      if (triggered && _connectivity.isOnline) {
        try {
          return await _cloud.describe(imageBytes, mode, question: question);
        } catch (_) {
          // Cloud failed; fall through to descriptive message.
        }
      }
      return _noLocalMsg(mode, _connectivity.isOnline);
    }

    // Scene/VQA: cloud-first when user-triggered + online (rich LLM description is the value).
    // Falls back to local labels, then graceful message.
    if (triggered && _connectivity.isOnline) {
      try {
        return await _cloud.describe(imageBytes, mode, question: question);
      } catch (_) {
        // Cloud failed → fall through to local.
      }
    }

    final localResult = await _local.analyze(imageBytes, mode);
    if (localResult != null) return localResult;

    return !_connectivity.isOnline
        ? 'No internet connection. Connect for full descriptions.'
        : 'Unable to describe image. Please try again.';
  }

  String _noLocalMsg(SeekrMode mode, bool online) {
    if (!online) {
      return 'No internet connection. Connect for full descriptions.';
    }
    return mode == SeekrMode.textRecognition
        ? 'No text detected. Move closer to the text.'
        : 'No product detected. Try again.';
  }
}
