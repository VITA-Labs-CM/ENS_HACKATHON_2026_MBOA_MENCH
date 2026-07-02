import 'dart:convert';
import 'ai_service.dart';

/// Analyzes class performance and identifies students at risk.
class ClassAnalyzer {
  ClassAnalyzer({required this.aiService});

  final AiService aiService;

  /// Analyze class performance and get recommendations.
  Future<ClassAnalysis> analyzeClass({
    required String className,
    required String subject,
    required List<Map<String, dynamic>> studentData,
  }) async {
    const systemPrompt = '''Tu es un conseiller pédagogique expert du système éducatif camerounais.
Analyse les performances de classe et donne des recommandations.

FORMAT JSON:
{
  "summary": "Résumé global",
  "average_score": 0.0,
  "at_risk_students": ["nom1", "nom2"],
  "strengths": ["point fort 1"],
  "weaknesses": ["point faible 1"],
  "recommendations": ["recommandation 1"],
  "module_difficulty_ranking": [{"module": "...", "difficulty": "high|medium|low"}]
}''';

    final userMsg = '''Classe: $className — $subject
Données élèves: ${jsonEncode(studentData)}

Analyse les performances et donne tes recommandations.''';

    final response = await aiService.complete(
      systemPrompt: systemPrompt,
      userMessage: userMsg,
      maxTokens: 2048,
      temperature: 0.3,
    );

    if (!response.success) {
      return ClassAnalysis(success: false, error: response.error);
    }

    try {
      final jsonStr = _extractJson(response.content);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ClassAnalysis(success: true, data: data);
    } catch (e) {
      return ClassAnalysis(success: false, error: 'Parsing: $e', rawContent: response.content);
    }
  }

  String _extractJson(String text) {
    final s = text.indexOf('{');
    final e = text.lastIndexOf('}');
    if (s != -1 && e > s) return text.substring(s, e + 1);
    return text;
  }
}

class ClassAnalysis {
  const ClassAnalysis({required this.success, this.data, this.error, this.rawContent});
  final bool success;
  final Map<String, dynamic>? data;
  final String? error, rawContent;
}
