import 'dart:convert';
import 'package:http/http.dart' as http;

/// AI service layer — Groq API with HuggingFace fallback.
/// Uses LLaMA 3.3 / Mixtral for course generation, analysis, chat.
class AiService {
  AiService({
    required this.groqApiKey,
    this.huggingFaceApiKey,
    this.groqModel = 'llama-3.3-70b-versatile',
    this.fallbackModel = 'mistralai/Mixtral-8x7B-Instruct-v0.1',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String groqApiKey;
  final String? huggingFaceApiKey;
  final String groqModel;
  final String fallbackModel;
  final http.Client _client;

  static const _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _hfUrl = 'https://api-inference.huggingface.co/models';

  /// Send a prompt to Groq, fallback to HuggingFace on failure.
  Future<AiResponse> complete({
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    // Try Groq first
    final groqResult = await _callGroq(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      temperature: temperature,
      maxTokens: maxTokens,
    );

    if (groqResult.success) return groqResult;

    // Fallback to HuggingFace
    if (huggingFaceApiKey != null) {
      return _callHuggingFace(
        prompt: '$systemPrompt\n\nUser: $userMessage\nAssistant:',
        maxTokens: maxTokens,
      );
    }

    return const AiResponse(
      success: false,
      content: '',
      error: 'Groq a échoué et aucune clé HuggingFace configurée',
      provider: 'none',
    );
  }

  Future<AiResponse> _callGroq({
    required String systemPrompt,
    required String userMessage,
    required double temperature,
    required int maxTokens,
  }) async {
    try {
      final resp = await _client.post(
        Uri.parse(_groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey',
        },
        body: jsonEncode({
          'model': groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content = data['choices'][0]['message']['content'] as String;
        return AiResponse(success: true, content: content, provider: 'groq');
      }
      return AiResponse(success: false, content: '', error: 'Groq HTTP ${resp.statusCode}', provider: 'groq');
    } catch (e) {
      return AiResponse(success: false, content: '', error: '$e', provider: 'groq');
    }
  }

  Future<AiResponse> _callHuggingFace({
    required String prompt,
    required int maxTokens,
  }) async {
    try {
      final resp = await _client.post(
        Uri.parse('$_hfUrl/$fallbackModel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $huggingFaceApiKey',
        },
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {'max_new_tokens': maxTokens, 'temperature': 0.7},
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content = data is List ? data[0]['generated_text'] as String : data['generated_text'] as String;
        return AiResponse(success: true, content: content, provider: 'huggingface');
      }
      return AiResponse(success: false, content: '', error: 'HF HTTP ${resp.statusCode}', provider: 'huggingface');
    } catch (e) {
      return AiResponse(success: false, content: '', error: '$e', provider: 'huggingface');
    }
  }

  void dispose() => _client.close();
}

class AiResponse {
  const AiResponse({required this.success, required this.content, required this.provider, this.error});
  final bool success; final String content, provider; final String? error;
}
