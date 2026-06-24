import '../domain/models.dart';
import 'tts_service.dart';

/// A single shared audio output (one earpiece) with two priorities.
///
/// The real engineering problem: an obstacle warning and a scene description
/// can be ready at the same instant, but you can only speak one thing at a
/// time. Safety alerts jump to the front and interrupt the current utterance;
/// descriptions queue behind.
///
/// Re-entrancy is handled with a single drain loop guarded by [_draining], so
/// two loops can never run concurrently and audio can't overlap or reorder.
class AudioQueue {
  final TtsService _tts;
  final void Function(String nowSpeaking)? onSpeakStart;
  final void Function()? onSpeakEnd;

  AudioQueue(this._tts, {this.onSpeakStart, this.onSpeakEnd});

  final List<Utterance> _queue = <Utterance>[];
  bool _draining = false;

  void enqueue(Utterance u) {
    if (u.priority == AudioPriority.safety) {
      _queue.insert(0, u); // jump the line
      _tts.stop(); // cut the current utterance so the alert plays now
    } else {
      _queue.add(u);
    }
    _startDraining();
  }

  Future<void> _startDraining() async {
    if (_draining) return; // only one loop ever runs → no overlap / no reorder
    _draining = true;
    while (_queue.isNotEmpty) {
      final Utterance u = _queue.removeAt(0);
      onSpeakStart?.call(u.text);
      await _tts.speak(u.text); // resolves on completion (awaitSpeakCompletion=true)
      onSpeakEnd?.call();
    }
    _draining = false;
  }

  void clear() {
    _queue.clear();
    _tts.stop();
  }
}
