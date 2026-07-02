import 'session_memory.dart';
import 'persistent_memory.dart';
import 'summary_memory.dart';

/// Memory retrieval with scoring — combines all memory layers.
class MemoryRepository {
  MemoryRepository({
    required this.sessionMemory,
    required this.persistentMemory,
    required this.summaryMemory,
  });

  final SessionMemory sessionMemory;
  final PersistentMemory persistentMemory;
  final SummaryMemory summaryMemory;

  /// Retrieve the most relevant context for a query.
  /// Combines session (fresh), persistent (deep), and summary (compressed).
  Future<RetrievalResult> retrieve({
    required String studentId,
    required String query,
    int maxResults = 10,
  }) async {
    final scored = <ScoredMemory>[];

    // 1. Session memory (highest recency weight)
    final sessionResults = sessionMemory.search(query);
    for (final entry in sessionResults) {
      scored.add(ScoredMemory(
        entry: entry,
        score: _computeScore(entry, query, recencyBoost: 0.3),
        source: MemorySource.session,
      ));
    }

    // 2. Persistent memory (deep retrieval)
    final persistentResults = await persistentMemory.search(studentId, query);
    for (final entry in persistentResults) {
      scored.add(ScoredMemory(
        entry: entry,
        score: _computeScore(entry, query, recencyBoost: 0.1),
        source: MemorySource.persistent,
      ));
    }

    // Sort by score and limit
    scored.sort((a, b) => b.score.compareTo(a.score));
    final topResults = scored.take(maxResults).toList();

    // 3. Add summary context
    final summaryContext = summaryMemory.buildContext(maxChars: 1000);

    return RetrievalResult(
      memories: topResults,
      summaryContext: summaryContext,
      totalCandidates: scored.length,
    );
  }

  /// Compute relevance score for a memory entry.
  double _computeScore(MemoryEntry entry, String query, {double recencyBoost = 0.0}) {
    double score = 0;

    // 1. Importance score (0-1, weight: 0.3)
    score += entry.importanceScore * 0.3;

    // 2. Recency score (0-1, weight: 0.3 + boost)
    final age = DateTime.now().difference(entry.timestamp);
    final recencyScore = _decayFunction(age);
    score += recencyScore * (0.3 + recencyBoost);

    // 3. Relevance to query (0-1, weight: 0.4)
    final relevance = _computeRelevance(entry, query);
    score += relevance * 0.4;

    return score.clamp(0.0, 1.0);
  }

  /// Time decay function — exponential decay over days.
  double _decayFunction(Duration age) {
    final days = age.inHours / 24.0;
    // Half-life of 7 days
    return 0.5 * (1.0 / (1.0 + days / 7.0)) + 0.5 * (days < 1 ? 1.0 : 0.0);
  }

  /// Simple keyword-based relevance (would be embeddings in production).
  double _computeRelevance(MemoryEntry entry, String query) {
    final queryWords = query.toLowerCase().split(RegExp(r'\s+'));
    final text = '${entry.content} ${entry.topic}'.toLowerCase();

    int matches = 0;
    for (final word in queryWords) {
      if (word.length > 2 && text.contains(word)) matches++;
    }

    return queryWords.isEmpty ? 0 : matches / queryWords.length;
  }
}

/// A memory entry with a computed relevance score.
class ScoredMemory {
  const ScoredMemory({required this.entry, required this.score, required this.source});
  final MemoryEntry entry;
  final double score;
  final MemorySource source;
}

/// Result of a memory retrieval operation.
class RetrievalResult {
  const RetrievalResult({required this.memories, required this.summaryContext, required this.totalCandidates});
  final List<ScoredMemory> memories;
  final String summaryContext;
  final int totalCandidates;

  /// Build a context string for the AI prompt.
  String toContextString() {
    final buf = StringBuffer();
    if (summaryContext.isNotEmpty) {
      buf.writeln('=== Historique résumé ===');
      buf.writeln(summaryContext);
    }
    if (memories.isNotEmpty) {
      buf.writeln('=== Contexte pertinent ===');
      for (final m in memories) {
        buf.writeln('- [${m.entry.topic}] ${m.entry.content}');
      }
    }
    return buf.toString();
  }
}

enum MemorySource { session, persistent, summary }
