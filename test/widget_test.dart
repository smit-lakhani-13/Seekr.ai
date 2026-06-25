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
  });
}
