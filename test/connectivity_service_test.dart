import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:seekr_companion_demo/services/connectivity_service.dart';
import 'package:seekr_companion_demo/services/audio_queue.dart';
import 'package:seekr_companion_demo/services/tts_service.dart';
import 'package:seekr_companion_demo/domain/models.dart';

class _TrackingTts implements TtsService {
  final spoken = <String>[];
  bool wasStopped = false;
  @override
  Future<void> init() async {}
  @override
  Future<void> speak(String text) async => spoken.add(text);
  @override
  Future<void> stop() async => wasStopped = true;
}

void main() {
  group('NoopConnectivityService', () {
    test('starts online by default', () {
      final svc = NoopConnectivityService();
      expect(svc.isOnline, isTrue);
      svc.dispose();
    });

    test('setOnline(false) updates isOnline and emits on stream', () async {
      final svc = NoopConnectivityService();
      final events = <bool>[];
      final sub = svc.onlineStream.listen(events.add);
      svc.setOnline(false);
      await Future<void>.delayed(Duration.zero);
      expect(svc.isOnline, isFalse);
      expect(events, [false]);
      await sub.cancel();
      svc.dispose();
    });

    test('withRetry passes through success immediately', () async {
      final svc = NoopConnectivityService();
      final result = await svc.withRetry(() async => 42);
      expect(result, 42);
      svc.dispose();
    });

    test('withRetry re-throws non-network errors immediately (no retry)',
        () async {
      final svc = NoopConnectivityService();
      int calls = 0;
      try {
        await svc.withRetry(() async {
          calls++;
          throw Exception('server error');
        });
      } catch (_) {}
      expect(calls, 1);
      svc.dispose();
    });
  });

  group('Retry logic — failure classification', () {
    test(
        'SocketException retries maxRetries times then rethrows + speaks TTS fallback',
        () async {
      final tts = _TrackingTts();
      final queue = AudioQueue(tts);
      int calls = 0;

      try {
        await _retryHelper(
          () async {
            calls++;
            throw const SocketException('no route to host');
          },
          audioQueue: queue,
          maxRetries: 2,
        );
      } on SocketException {
        // expected
      }

      expect(calls, 3); // initial + 2 retries
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(tts.spoken, contains('Connection lost, please wait'));
      queue.clear();
    });

    test('non-network exception does NOT retry', () async {
      int calls = 0;
      try {
        await _retryHelper(
          () async {
            calls++;
            throw ArgumentError('bad input');
          },
          maxRetries: 3,
        );
      } on ArgumentError {
        // expected
      }
      expect(calls, 1);
    });

    test('success on second attempt (recovers after one SocketException)',
        () async {
      int calls = 0;
      final result = await _retryHelper(
        () async {
          calls++;
          if (calls == 1) throw const SocketException('transient');
          return 'ok';
        },
        maxRetries: 1,
      );
      expect(result, 'ok');
      expect(calls, 2);
    });

    test('backoff delay grows', () async {
      final delays = <Duration>[];
      int calls = 0;
      try {
        await _retryHelper(
          () async {
            calls++;
            throw const SocketException('x');
          },
          maxRetries: 2,
          delayOverride: delays.add,
        );
      } on SocketException {
        // expected
      }
      expect(calls, 3);
      // 1ms base, doubling: [1ms, 2ms]
      expect(delays.length, 2);
      expect(delays[1].inMilliseconds,
          greaterThanOrEqualTo(delays[0].inMilliseconds));
    });
  });
}

// Mirror of ConnectivityServiceImpl.withRetry for unit testing without platform channels.
Future<T> _retryHelper<T>(
  Future<T> Function() call, {
  AudioQueue? audioQueue,
  int maxRetries = 1,
  void Function(Duration)? delayOverride,
}) async {
  int attempt = 0;
  Duration delay = const Duration(milliseconds: 1); // fast in tests
  const maxDelay = Duration(milliseconds: 8);

  while (true) {
    try {
      return await call().timeout(const Duration(seconds: 5));
    } on SocketException {
      if (attempt >= maxRetries) {
        audioQueue?.enqueue(const Utterance(
            'Connection lost, please wait', AudioPriority.safety));
        rethrow;
      }
    } on TimeoutException {
      if (attempt >= maxRetries) {
        audioQueue?.enqueue(const Utterance(
            'Connection lost, please wait', AudioPriority.safety));
        rethrow;
      }
    }
    attempt++;
    delayOverride?.call(delay);
    await Future<void>.delayed(delay);
    delay = delay * 2;
    if (delay > maxDelay) delay = maxDelay;
  }
}
