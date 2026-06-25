import 'package:flutter_test/flutter_test.dart';
import 'package:seekr_companion_demo/services/live_frame_gate.dart';
import 'package:seekr_companion_demo/services/live_speech_policy.dart';

void main() {
  group('LiveSpeechPolicy', () {
    late DateTime now;
    late LiveSpeechPolicy policy;

    setUp(() {
      now = DateTime(2026, 1, 1, 12);
      policy = LiveSpeechPolicy(clock: () => now);
    });

    test('repeated same live result does not speak repeatedly', () {
      expect(policy.decide('I can see text: Alarm 7:00 AM').shouldSpeak, true);
      expect(policy.decide('I can see text alarm 7 00 am').shouldSpeak, false);
      expect(policy.decide('I can see text: Alarm 7:00 AM').shouldSpeak, false);
    });

    test('major scene change speaks immediately', () {
      expect(policy.decide('I can see text: Alarm 7:00 AM').shouldSpeak, true);
      now = now.add(const Duration(milliseconds: 800));

      expect(
        policy.decide('I can see a desk, monitor, and keyboard.').shouldSpeak,
        true,
      );
    });

    test('minor change waits for cooldown', () {
      expect(policy.decide('I can see a desk and monitor.').shouldSpeak, true);
      now = now.add(const Duration(seconds: 1));
      expect(
        policy.decide('I can see a desk, monitor, and keyboard.').shouldSpeak,
        false,
      );

      now = now.add(const Duration(seconds: 3));
      expect(
        policy.decide('I can see a desk, monitor, and keyboard.').shouldSpeak,
        true,
      );
    });

    test('low-value looking statuses stay silent', () {
      expect(policy.decide('No text detected yet.').shouldSpeak, false);
      expect(
        policy
            .decide('Looking around. Nothing clear detected yet.')
            .shouldSpeak,
        false,
      );
    });
  });

  group('LiveFrameGate', () {
    test('newer frame result suppresses older stale frame result', () {
      final gate = LiveFrameGate();
      final oldFrame = gate.begin();
      final newFrame = gate.begin();

      expect(gate.tryApply(newFrame), true);
      expect(gate.tryApply(oldFrame), false);
    });

    test('reset prevents late closed-screen result from applying', () {
      final gate = LiveFrameGate();
      final frame = gate.begin();

      gate.reset();

      expect(gate.tryApply(frame), false);
    });
  });
}
