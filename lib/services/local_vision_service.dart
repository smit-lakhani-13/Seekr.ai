import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/models.dart';

// ── Interface ─────────────────────────────────────────────────────────────────

abstract class LocalVisionService {
  /// Returns a spoken-style string, or null if nothing useful was detected.
  /// null signals the router to fall through to Tier 2 or a graceful message.
  Future<String?> analyze(List<int> imageBytes, SeekrMode mode);
  Future<void> dispose();
}

// ── ML Kit implementation (Android) ──────────────────────────────────────────

class MlKitLocalVisionService implements LocalVisionService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _labeler =
      ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.7));
  final _barcodeScanner = BarcodeScanner();

  /// Write bytes to a temp file; ML Kit works reliably with file paths for JPEG.
  Future<InputImage> _toInputImage(List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/_seekr_mlkit.jpg');
    await file.writeAsBytes(bytes);
    return InputImage.fromFilePath(file.path);
  }

  @override
  Future<String?> analyze(List<int> imageBytes, SeekrMode mode) async {
    try {
      final img = await _toInputImage(imageBytes);
      switch (mode) {
        case SeekrMode.textRecognition:
          return await _readText(img);
        case SeekrMode.sceneDetection:
          return await _labelScene(img);
        case SeekrMode.supermarket:
          return await _scanProduct(img);
        default:
          return null;
      }
    } catch (_) {
      return null; // router falls through to cloud or graceful message
    }
  }

  Future<String?> _readText(InputImage img) async {
    final result = await _textRecognizer.processImage(img);
    if (result.text.trim().isEmpty) return null;
    return 'Text reads: ${result.text.replaceAll('\n', '. ')}';
  }

  Future<String?> _labelScene(InputImage img) async {
    final labels = await _labeler.processImage(img);
    if (labels.isEmpty) return null;
    final top = labels.take(3).map((l) => l.label).join(', ');
    return 'Scene contains: $top';
  }

  Future<String?> _scanProduct(InputImage img) async {
    // Barcode first (precise); fall back to image labels.
    final barcodes = await _barcodeScanner.processImage(img);
    if (barcodes.isNotEmpty && barcodes.first.displayValue != null) {
      return 'Barcode: ${barcodes.first.displayValue}';
    }
    final labels = await _labeler.processImage(img);
    if (labels.isEmpty) return null;
    final top = labels.take(2).map((l) => l.label).join(', ');
    return 'Looks like: $top';
  }

  @override
  Future<void> dispose() async {
    await _textRecognizer.close();
    await _labeler.close();
    await _barcodeScanner.close();
  }
}

// ── No-op (web / tests) ───────────────────────────────────────────────────────

class NoopLocalVisionService implements LocalVisionService {
  @override
  Future<String?> analyze(List<int> imageBytes, SeekrMode mode) async => null;
  @override
  Future<void> dispose() async {}
}
