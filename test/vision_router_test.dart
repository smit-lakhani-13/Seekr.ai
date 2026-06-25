import 'package:flutter_test/flutter_test.dart';
import 'package:seekr_companion_demo/domain/models.dart';
import 'package:seekr_companion_demo/services/audio_queue.dart';
import 'package:seekr_companion_demo/services/cloud_vision_service.dart';
import 'package:seekr_companion_demo/services/connectivity_service.dart';
import 'package:seekr_companion_demo/services/local_vision_service.dart';
import 'package:seekr_companion_demo/services/vision_router.dart';

// ── Minimal mocks ─────────────────────────────────────────────────────────────

class _MockLocal implements LocalVisionService {
  final String? result;
  _MockLocal(this.result);
  @override
  Future<String?> analyze(List<int> imageBytes, SeekrMode mode) async => result;
  @override
  Future<void> dispose() async {}
}

class _MockCloud implements CloudVisionService {
  final String? result;
  final bool throws;
  _MockCloud({this.result = 'cloud result', this.throws = false});
  @override
  Future<String> describe(List<int> imageBytes, SeekrMode mode,
      {String? question}) async {
    if (throws) throw Exception('cloud error');
    return result!;
  }

  @override
  Future<CloudHealth> health() async => const CloudHealth(
        reachable: true,
        status: 'ok',
        provider: 'mock',
      );
}

class _MockConn implements ConnectivityService {
  final bool online;
  _MockConn(this.online);
  @override
  bool get isOnline => online;
  @override
  Stream<bool> get onlineStream => Stream.value(online);
  @override
  Future<void> connectToDeviceAP({required String ssid, String? bssid}) async {}
  @override
  Future<void> disconnectFromDeviceAP() async {}
  @override
  Future<void> requestCellular() async {}
  @override
  Future<T> withRetry<T>(Future<T> Function() call,
          {AudioQueue? audioQueue, int maxRetries = 1}) =>
      call();
  @override
  void dispose() {}
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  final bytes = [0, 1, 2];

  group('VisionRouter — safety (depthObstacle)', () {
    test('always local, even when online + triggered', () async {
      final r = VisionRouter(
          _MockLocal('obstacle 1.2 m'), _MockCloud(), _MockConn(true));
      expect(await r.route(bytes, SeekrMode.depthObstacle, triggered: true),
          'obstacle 1.2 m');
    });

    test('local returns null → default spoken message', () async {
      final r = VisionRouter(_MockLocal(null), _MockCloud(), _MockConn(true));
      expect(await r.route(bytes, SeekrMode.depthObstacle),
          'Obstacle detection active.');
    });
  });

  group('VisionRouter — textRecognition (local-first)', () {
    test('local finds text → returns it, never calls cloud', () async {
      // cloud throws to prove it is never reached
      final r = VisionRouter(_MockLocal('Text reads: Exit'),
          _MockCloud(throws: true), _MockConn(true));
      expect(await r.route(bytes, SeekrMode.textRecognition, triggered: true),
          'Text reads: Exit');
    });

    test('local null + online + triggered → cloud', () async {
      final r = VisionRouter(_MockLocal(null),
          _MockCloud(result: 'Sign: Platform 2'), _MockConn(true));
      expect(await r.route(bytes, SeekrMode.textRecognition, triggered: true),
          'Sign: Platform 2');
    });

    test('local null + offline → no-internet message', () async {
      final r = VisionRouter(_MockLocal(null), _MockCloud(), _MockConn(false));
      expect(await r.route(bytes, SeekrMode.textRecognition, triggered: true),
          contains('No internet'));
    });

    test(
        'local null + online + NOT triggered → no-local message (no cloud upload)',
        () async {
      // cloud throws to prove it is never reached when not triggered
      final r = VisionRouter(
          _MockLocal(null), _MockCloud(throws: true), _MockConn(true));
      final result =
          await r.route(bytes, SeekrMode.textRecognition, triggered: false);
      expect(result,
          isNot(contains('Unable to describe'))); // specific OCR message
      expect(result, contains('No text detected'));
    });

    test(
        'local null + online + triggered + cloud throws → descriptive fallback',
        () async {
      final r = VisionRouter(
          _MockLocal(null), _MockCloud(throws: true), _MockConn(true));
      final result =
          await r.route(bytes, SeekrMode.textRecognition, triggered: true);
      // No crash; gives a descriptive spoken message
      expect(result, isNotEmpty);
    });
  });

  group('VisionRouter — supermarket (local-first / barcode)', () {
    test('local finds barcode → returns it, never calls cloud', () async {
      final r = VisionRouter(_MockLocal('Barcode: 5000169319981'),
          _MockCloud(throws: true), _MockConn(true));
      expect(await r.route(bytes, SeekrMode.supermarket, triggered: true),
          'Barcode: 5000169319981');
    });

    test('local null + online + triggered → cloud', () async {
      final r = VisionRouter(_MockLocal(null),
          _MockCloud(result: 'Product: whole milk'), _MockConn(true));
      expect(await r.route(bytes, SeekrMode.supermarket, triggered: true),
          'Product: whole milk');
    });
  });

  group('VisionRouter — sceneDetection (cloud-first)', () {
    test('online + triggered → cloud (rich description preferred)', () async {
      final r = VisionRouter(_MockLocal('Scene contains: chair'),
          _MockCloud(result: 'A bright room with window'), _MockConn(true));
      // Cloud takes priority for scene when triggered + online
      expect(await r.route(bytes, SeekrMode.sceneDetection, triggered: true),
          'A bright room with window');
    });

    test('offline + triggered → local fallback', () async {
      final r = VisionRouter(
          _MockLocal('Scene contains: chair'), _MockCloud(), _MockConn(false));
      expect(await r.route(bytes, SeekrMode.sceneDetection, triggered: true),
          'Scene contains: chair');
    });

    test('offline + no local → no-internet message', () async {
      final r = VisionRouter(_MockLocal(null), _MockCloud(), _MockConn(false));
      expect(await r.route(bytes, SeekrMode.sceneDetection, triggered: true),
          contains('No internet'));
    });

    test('online + NOT triggered → skips cloud, uses local', () async {
      final r = VisionRouter(_MockLocal('local label'),
          _MockCloud(result: 'should not appear'), _MockConn(true));
      expect(await r.route(bytes, SeekrMode.sceneDetection, triggered: false),
          'local label');
    });

    test('online + triggered + cloud throws → local fallback', () async {
      final r = VisionRouter(
          _MockLocal('local scene'), _MockCloud(throws: true), _MockConn(true));
      expect(await r.route(bytes, SeekrMode.sceneDetection, triggered: true),
          'local scene');
    });

    test('online + triggered + cloud throws + no local → generic error',
        () async {
      final r = VisionRouter(
          _MockLocal(null), _MockCloud(throws: true), _MockConn(true));
      expect(await r.route(bytes, SeekrMode.sceneDetection, triggered: true),
          contains('Unable to describe'));
    });
  });

  group('VisionRouter — SeekrMode.none (fallback path)', () {
    // captureAndDescribe() remaps none→sceneDetection before calling the router,
    // but the router must not crash if none reaches it directly.
    test('none + online + triggered → cloud via sceneDetection path', () async {
      final r = VisionRouter(_MockLocal(null),
          _MockCloud(result: 'fallback scene'), _MockConn(true));
      final result = await r.route(bytes, SeekrMode.none, triggered: true);
      expect(result, isNotEmpty);
    });

    test('none + offline + no local → no-internet message', () async {
      final r = VisionRouter(_MockLocal(null), _MockCloud(), _MockConn(false));
      final result = await r.route(bytes, SeekrMode.none, triggered: true);
      expect(result, contains('No internet'));
    });
  });
}
