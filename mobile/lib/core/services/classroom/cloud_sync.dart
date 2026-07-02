import 'dart:convert';
import 'package:http/http.dart' as http;

/// Cloud sync API layer — communicates with the central backend.
class CloudSync {
  CloudSync({required this.baseUrl, this.authToken, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  String? authToken;
  final http.Client _client;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// Sync all changes since a timestamp.
  Future<CloudSyncResponse> sync({required DateTime since}) async {
    try {
      final resp = await _client.get(
        Uri.parse('$baseUrl/api/sync?since=${since.toIso8601String()}'),
        headers: _headers,
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return CloudSyncResponse(
          success: true,
          courses: (data['courses'] as List?)?.cast<Map<String, dynamic>>() ?? [],
          messages: (data['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [],
          quizResults: (data['quiz_results'] as List?)?.cast<Map<String, dynamic>>() ?? [],
          resources: (data['resources'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        );
      }
      return CloudSyncResponse(success: false, error: 'HTTP ${resp.statusCode}');
    } catch (e) {
      return CloudSyncResponse(success: false, error: '$e');
    }
  }

  /// Push local changes to cloud.
  Future<bool> pushChanges(List<Map<String, dynamic>> operations) async {
    try {
      final resp = await _client.post(
        Uri.parse('$baseUrl/api/sync/push'),
        headers: _headers,
        body: jsonEncode({'operations': operations}),
      );
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Join a class via cloud invite code.
  Future<Map<String, dynamic>?> joinClass(String code, String studentId) async {
    try {
      final resp = await _client.post(
        Uri.parse('$baseUrl/api/class/join'),
        headers: _headers,
        body: jsonEncode({'invite_code': code, 'student_id': studentId}),
      );
      if (resp.statusCode == 200) return jsonDecode(resp.body);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get resource manifest for a class.
  Future<List<Map<String, dynamic>>> getResourceManifest(String classId) async {
    try {
      final resp = await _client.get(
        Uri.parse('$baseUrl/api/class/$classId/resources'),
        headers: _headers,
      );
      if (resp.statusCode == 200) {
        return (jsonDecode(resp.body) as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  void dispose() => _client.close();
}

class CloudSyncResponse {
  const CloudSyncResponse({
    required this.success,
    this.courses = const [],
    this.messages = const [],
    this.quizResults = const [],
    this.resources = const [],
    this.error,
  });
  final bool success;
  final List<Map<String, dynamic>> courses, messages, quizResults, resources;
  final String? error;
}
