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

// ── ML Kit implementation (Android/iOS) ──────────────────────────────────────

class MlKitLocalVisionService implements LocalVisionService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _labeler =
      ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
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
    final text = result.text.trim();
    if (text.isEmpty) return null;
    // First 2 non-empty lines, max 140 chars — keeps TTS brief and stable.
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .take(2)
        .join('. ');
    final summary = lines.length > 140
        ? '${lines.substring(0, 140).trimRight()}...'
        : lines;
    return 'I can see text: $summary';
  }

  // ML Kit frequently misclassifies consumer electronics as these — blocklist them.
  static const _labelBlocklist = {
    'musical instrument',
    'string instrument',
    'bowed string instrument',
    'wind instrument',
    'plucked string instruments',
    'percussion instrument',
    'musical keyboard',
    'keyboard instrument',
  };

  Future<String?> _labelScene(InputImage img) async {
    // Text is more specific than generic labels — try OCR first.
    final textResult = await _readText(img);
    if (textResult != null) return textResult;

    final labels = await _labeler.processImage(img);
    if (labels.isEmpty) return null;
    final names = labels
        .take(5)
        .map((l) => l.label.toLowerCase())
        .where((l) => l.length > 3)
        .where((l) => !_labelBlocklist.contains(l))
        .take(3)
        .toList();
    if (names.isEmpty) return null;
    return 'I can see: ${names.join(', ')}.';
  }

  Future<String?> _scanProduct(InputImage img) async {
    // Barcode first (precise); fall back to image labels.
    final barcodes = await _barcodeScanner.processImage(img);
    if (barcodes.isNotEmpty && barcodes.first.displayValue != null) {
      return 'Product barcode detected: ${barcodes.first.displayValue}';
    }
    final labels = await _labeler.processImage(img);
    if (labels.isEmpty) return null;
    final top = labels.take(2).map((l) => l.label).join(', ');
    return 'I can see product-like items: $top';
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
