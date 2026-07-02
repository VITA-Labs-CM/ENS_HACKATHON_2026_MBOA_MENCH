import 'dart:convert';
import 'ai_service.dart';

/// Generates courses in MINESEC APC format using AI.
class CourseGenerator {
  CourseGenerator({required this.aiService});

  final AiService aiService;

  /// Generate a structured course in MINESEC format.
  Future<GeneratedCourse> generateCourse({
    required String subject,
    required String level,
    required String chapter,
    required List<String> competencies,
    String? additionalContext,
  }) async {
    final systemPrompt = '''Tu es un expert en pédagogie camerounaise (MINESEC).
Génère un cours structuré au format APC (Approche Par Compétences).

FORMAT DE SORTIE (JSON strict):
{
  "title": "Titre du cours",
  "subject": "$subject",
  "level": "$level",
  "chapter": "$chapter",
  "duration_minutes": 45,
  "competencies": [...],
  "sections": [
    {
      "title": "Titre section",
      "type": "introduction|development|exercise|summary",
      "content": "Contenu détaillé...",
      "key_points": ["point 1", "point 2"]
    }
  ],
  "quiz_questions": [
    {
      "question": "...",
      "type": "multiple_choice|true_false|short_answer",
      "options": ["A", "B", "C", "D"],
      "correct_answer": "B",
      "explanation": "..."
    }
  ]
}''';

    final userMsg = '''Matière: $subject
Niveau: $level  
Chapitre: $chapter
Compétences visées: ${competencies.join(', ')}
${additionalContext != null ? 'Contexte: $additionalContext' : ''}

Génère le cours complet en JSON.''';

    final response = await aiService.complete(
      systemPrompt: systemPrompt,
      userMessage: userMsg,
      maxTokens: 4096,
      temperature: 0.5,
    );

    if (!response.success) {
      return GeneratedCourse(success: false, error: response.error);
    }

    try {
      // Extract JSON from response
      final jsonStr = _extractJson(response.content);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GeneratedCourse(success: true, data: data);
    } catch (e) {
      return GeneratedCourse(success: false, error: 'Erreur parsing: $e', rawContent: response.content);
    }
  }

  String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end > start) return text.substring(start, end + 1);
    return text;
  }
}

class GeneratedCourse {
  const GeneratedCourse({required this.success, this.data, this.error, this.rawContent});
  final bool success;
  final Map<String, dynamic>? data;
  final String? error, rawContent;
}
