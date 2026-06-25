import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../domain/models.dart';
import 'connectivity_service.dart';

// ── Interface ─────────────────────────────────────────────────────────────────

abstract class CloudVisionService {
  Future<String> describe(List<int> imageBytes, SeekrMode mode,
      {String? question});
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
}

// ── No-op (tests) ─────────────────────────────────────────────────────────────

class NoopCloudVisionService implements CloudVisionService {
  @override
  Future<String> describe(List<int> imageBytes, SeekrMode mode,
          {String? question}) async =>
      'Cloud description unavailable in this build.';
}
