import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seekr_companion_demo/domain/models.dart';
import 'package:seekr_companion_demo/services/tts_service.dart';
import 'package:seekr_companion_demo/services/audio_queue.dart';

class MockTtsService implements TtsService {
  final List<String> spoken = [];
  bool wasStopped = false;

  @override
  Future<void> init() async {}

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {
    wasStopped = true;
  }
}

class BlockingTtsService implements TtsService {
  final List<String> spoken = [];
  int stopCount = 0;
  Completer<void>? _current;

  @override
  Future<void> init() async {}

  @override
  Future<void> speak(String text) {
    spoken.add(text);
    _current = Completer<void>();
    return _current!.future;
  }

  @override
  Future<void> stop() async {
    stopCount++;
    _current?.complete();
  }

  void finishCurrent() {
    _current?.complete();
  }
}

void main() {
  group('SeekrMode Extension Tests', () {
    test('label returns correct string', () {
      expect(SeekrMode.none.label, 'No mode');
      expect(SeekrMode.textRecognition.label, 'Text Recognition');
      expect(SeekrMode.sceneDetection.label, 'Scene Detection');
      expect(SeekrMode.depthObstacle.label, 'Depth & Obstacle');
      expect(SeekrMode.supermarket.label, 'Supermarket');
    });

    test('description returns correct string', () {
      expect(SeekrMode.none.description, 'Select a mode to begin.');
      expect(
          SeekrMode.depthObstacle.description, 'Warns about obstacles ahead.');
    });
  });

  group('AudioQueue Tests', () {
    test('Normal priority items are queued sequentially', () async {
      final mockTts = MockTtsService();
      final queue = AudioQueue(mockTts);

      queue.enqueue(const Utterance('Hello', AudioPriority.normal));
      queue.enqueue(const Utterance('World', AudioPriority.normal));

      // Wait a moment for async draining to run
      await Future<void>.delayed(Duration.zero);

      expect(mockTts.spoken, ['Hello', 'World']);
    });

    test('Safety priority item interrupts current speaking and jumps the line',
        () async {
      final mockTts = MockTtsService();
      final queue = AudioQueue(mockTts);

      queue.enqueue(
          const Utterance('Long scene description', AudioPriority.normal));
      queue.enqueue(const Utterance('Obstacle ahead!', AudioPriority.safety));

      await Future<void>.delayed(Duration.zero);

      expect(mockTts.wasStopped, isTrue);
    });

    test('replace clears stale normal speech and speaks latest result',
        () async {
      final tts = BlockingTtsService();
      final queue = AudioQueue(tts);

      queue.enqueue(const Utterance('alarm screen', AudioPriority.normal));
      await Future<void>.delayed(Duration.zero);
      queue
          .enqueue(const Utterance('queued stale alarm', AudioPriority.normal));
      queue.replace(const Utterance('desk and monitor', AudioPriority.normal));
      await Future<void>.delayed(Duration.zero);

      expect(tts.stopCount, 1);
      expect(tts.spoken, ['alarm screen', 'desk and monitor']);

      tts.finishCurrent();
    });
  });
}
