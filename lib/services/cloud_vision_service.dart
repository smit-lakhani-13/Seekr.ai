import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../domain/models.dart';
import 'connectivity_service.dart';

// ── Interface ─────────────────────────────────────────────────────────────────

abstract class CloudVisionService {
  Future<String> describe(List<int> imageBytes, SeekrMode mode,
      {String? question});
  Future<CloudHealth> health();
}

class CloudHealth {
  const CloudHealth({
    required this.reachable,
    required this.status,
    this.provider,
    this.message,
  });

  final bool reachable;
  final String status;
  final String? provider;
  final String? message;
}

// ── HTTP implementation (calls FastAPI backend) ───────────────────────────────

String _taskFor(SeekrMode mode) => switch (mode) {
      SeekrMode.textRecognition => 'ocr',
      SeekrMode.supermarket => 'product',
      SeekrMode.sceneDetection => 'scene',
      _ => 'scene',
    };

class HttpCloudVisionService implements CloudVisionService {
  final ConnectivityService _connectivity;

  HttpCloudVisionService(this._connectivity);

  @override
  Future<String> describe(
    List<int> imageBytes,
    SeekrMode mode, {
    String? question,
  }) =>
      _connectivity.withRetry(() async {
        final cellularResult = await _describeViaCellular(
          imageBytes,
          mode,
          question: question,
        );
        if (cellularResult != null) return cellularResult;

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${AppConfig.backendUrl}/describe'),
        );
        request.fields['task'] = _taskFor(mode);
        if (question != null) request.fields['question'] = question;
        request.files.add(
          http.MultipartFile.fromBytes('image', imageBytes,
              filename: 'frame.jpg'),
        );

        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode != 200) {
          // 4xx/5xx = server error, not a network error — withRetry won't retry these.
          throw Exception('Cloud API ${response.statusCode}');
        }
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['text'] as String;
      });

  Future<String?> _describeViaCellular(
    List<int> imageBytes,
    SeekrMode mode, {
    String? question,
  }) async {
    final response = await _connectivity.postJsonViaCellular(
      uri: Uri.parse('${AppConfig.backendUrl}/describe_json'),
      body: {
        'image_base64': base64Encode(imageBytes),
        'task': _taskFor(mode),
        if (question != null) 'question': question,
      },
    );
    if (response == null) return null;
    if (response.statusCode != 200) {
      throw Exception('Cloud API ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['text'] as String;
  }

  @override
  Future<CloudHealth> health() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.backendUrl}/health'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode != 200) {
        return CloudHealth(
          reachable: false,
          status: 'HTTP ${response.statusCode}',
          message: 'Backend health endpoint returned an error.',
        );
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return CloudHealth(
        reachable: data['status'] == 'ok',
        status: data['status']?.toString() ?? 'unknown',
        provider: data['provider']?.toString(),
      );
    } catch (e) {
      return CloudHealth(
        reachable: false,
        status: 'unreachable',
        message: e.toString(),
      );
    }
  }
}

// ── No-op (tests) ─────────────────────────────────────────────────────────────

class NoopCloudVisionService implements CloudVisionService {
  @override
  Future<String> describe(List<int> imageBytes, SeekrMode mode,
          {String? question}) async =>
      'Cloud description unavailable in this build.';

  @override
  Future<CloudHealth> health() async => const CloudHealth(
        reachable: false,
        status: 'not configured',
        message: 'No cloud service registered.',
      );
}
