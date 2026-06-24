import 'package:flutter_tts/flutter_tts.dart';

/// TTS behind an interface so it's swappable and mockable, and the rest of
/// the app never depends on a concrete plugin. If flutter_tts ever misbehaves
/// on a given platform, swap in [NoopTtsService] in main.dart — nothing else
/// changes. (Clean dependency boundaries; same pattern as the device source.)
abstract class TtsService {
  Future<void> init();
  Future<void> speak(String text);
  Future<void> stop();
}

class FlutterTtsService implements TtsService {
  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> init() async {
    try {
      // Makes `speak()` resolve only when speaking finishes — essential for
      // sequencing the audio queue correctly.
      await _tts.awaitSpeakCompletion(true);
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {
      // Best-effort: some platforms partially fail init; the visual log still works.
    }
  }

  @override
  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (_) {
      // Best-effort; the on-screen "now speaking" log still demonstrates flow.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

/// Visual-only fallback (no audio). Use if flutter_tts can't initialise.
class NoopTtsService implements TtsService {
  @override
  Future<void> init() async {}
  @override
  Future<void> speak(String text) async {}
  @override
  Future<void> stop() async {}
}
