import 'ai_service.dart';

/// Teacher chatbot assistant — conversational AI for teachers.
class TeacherChatbot {
  TeacherChatbot({required this.aiService});

  final AiService aiService;
  final List<ChatTurn> _history = [];

  static const _systemPrompt = '''Tu es l'assistant IA de MBOA MENCH, conçu pour aider les enseignants camerounais.

Tes capacités:
- Répondre aux questions pédagogiques
- Aider à structurer des cours au format APC (MINESEC)
- Conseiller sur la gestion de classe
- Aider à créer des exercices et examens
- Interpréter les performances des élèves

Contexte: système éducatif camerounais, classes d'examen (3e, Probatoire, Terminale).
Langue: français. Sois concis et pratique.''';

  /// Send a message and get a response.
  Future<String> chat(String message) async {
    _history.add(ChatTurn(role: 'user', content: message));

    // Build context from history (limit to last 10 turns to fit context window)
    final recentHistory = _history.length > 20
        ? _history.sublist(_history.length - 20)
        : _history;

    final contextMsg = recentHistory
        .map((t) => '${t.role == 'user' ? 'Enseignant' : 'Assistant'}: ${t.content}')
        .join('\n\n');

    final response = await aiService.complete(
      systemPrompt: _systemPrompt,
      userMessage: contextMsg,
      maxTokens: 1024,
      temperature: 0.7,
    );

    final reply = response.success
        ? response.content
        : 'Désolé, je ne peux pas répondre pour le moment. (${response.error})';

    _history.add(ChatTurn(role: 'assistant', content: reply));
    return reply;
  }

  /// Clear conversation history.
  void clearHistory() => _history.clear();

  /// Get conversation history.
  List<ChatTurn> get history => List.unmodifiable(_history);
}

class ChatTurn {
  const ChatTurn({required this.role, required this.content});
  final String role, content;
}
