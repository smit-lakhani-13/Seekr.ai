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
      ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.65));
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
        case SeekrMode.none:
          return await _autoDescribe(img);
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

  Future<String?> _autoDescribe(InputImage img) async {
    final text = await _readText(img);
    final scene = await _labelScene(img, preferText: false);

    if (text != null && scene != null) {
      return '$text. $scene';
    }
    return text ?? scene;
  }

  // ML Kit Image Labeling is broad, not precise object detection. These labels
  // are too generic or frequently wrong in the live demo, so never speak them as facts.
  static const _labelBlocklist = {
    'metal',
    'wood',
    'plastic',
    'glass',
    'rubber',
    'material property',
    'font',
    'pattern',
    'design',
    'product',
    'brand',
    'event',
    'room',
    'floor',
    'ceiling',
    'wall',
    'hand',
    'arm',
    'leg',
    'finger',
    'skin',
    'flesh',
    'gesture',
    'food',
    'chair',
    'tableware',
    'musical instrument',
    'string instrument',
    'bowed string instrument',
    'wind instrument',
    'plucked string instruments',
    'percussion instrument',
    'musical keyboard',
    'keyboard instrument',
  };

  Future<String?> _labelScene(
    InputImage img, {
    bool preferText = true,
  }) async {
    // Text is more specific than generic labels — try OCR first.
    if (preferText) {
      final textResult = await _readText(img);
      if (textResult != null) return textResult;
    }

    final labels = await _labeler.processImage(img);
    if (labels.isEmpty) return null;
    final names = labels
        .where((l) => l.confidence >= 0.65)
        .map((l) => l.label.toLowerCase().trim())
        .where(_isUsefulLabel)
        .take(3)
        .toList();
    if (names.isEmpty) return null;
    return 'I can see ${_joinNatural(names)}.';
  }

  bool _isUsefulLabel(String label) {
    if (label.length < 4) return false;
    if (_labelBlocklist.contains(label)) return false;
    if (label.contains('instrument')) return false;
    if (label.contains('material')) return false;
    return true;
  }

  Future<String?> _scanProduct(InputImage img) async {
    // Barcode first (precise); fall back to image labels.
    final barcodes = await _barcodeScanner.processImage(img);
    if (barcodes.isNotEmpty && barcodes.first.displayValue != null) {
      return 'Product barcode detected: ${barcodes.first.displayValue}';
    }
    final labels = await _labeler.processImage(img);
    if (labels.isEmpty) return null;
    final top = labels
        .where((l) => l.confidence >= 0.65)
        .map((l) => l.label.toLowerCase().trim())
        .where(_isUsefulLabel)
        .take(2)
        .toList();
    if (top.isEmpty) return null;
    return 'I can see product-like items: ${_joinNatural(top)}.';
  }

  String _joinNatural(List<String> items) {
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items.first} and ${items.last}';
    return '${items.sublist(0, items.length - 1).join(', ')}, and ${items.last}';
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
