import 'session_memory.dart';

/// Compressed AI state — summarizes long conversation/learning history.
/// Prevents context window overflow by compressing older memories.
class SummaryMemory {
  SummaryMemory({this.maxSummaries = 20});

  final int maxSummaries;
  final List<MemorySummary> _summaries = [];

  /// Add a summary (e.g., from summarizing a session).
  void addSummary(MemorySummary summary) {
    _summaries.add(summary);
    while (_summaries.length > maxSummaries) {
      _summaries.removeAt(0);
    }
  }

  /// Create a summary from a list of memory entries.
  MemorySummary summarizeEntries(List<MemoryEntry> entries, String topic) {
    if (entries.isEmpty) {
      return MemorySummary(
        topic: topic,
        summary: 'Aucune donnée',
        entryCount: 0,
        timeRange: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
        keyPoints: [],
        avgImportance: 0,
      );
    }

    // Extract key points (high importance entries)
    final sorted = List.of(entries)
      ..sort((a, b) => b.importanceScore.compareTo(a.importanceScore));
    final keyPoints = sorted.take(5).map((e) => e.content).toList();

    // Compute time range
    final timestamps = entries.map((e) => e.timestamp).toList()..sort();
    final timeRange = DateTimeRange(
      start: timestamps.first,
      end: timestamps.last,
    );

    // Average importance
    final avgImportance =
        entries.map((e) => e.importanceScore).reduce((a, b) => a + b) /
            entries.length;

    // Build compressed summary text
    final topicCounts = <String, int>{};
    for (final e in entries) {
      topicCounts[e.topic] = (topicCounts[e.topic] ?? 0) + 1;
    }
    final topTopics = topicCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final summaryText = StringBuffer()
      ..writeln('Résumé: ${entries.length} interactions sur $topic')
      ..writeln('Sujets principaux: ${topTopics.take(3).map((e) => e.key).join(', ')}')
      ..writeln('Points clés:');
    for (final kp in keyPoints) {
      summaryText.writeln('- $kp');
    }

    return MemorySummary(
      topic: topic,
      summary: summaryText.toString(),
      entryCount: entries.length,
      timeRange: timeRange,
      keyPoints: keyPoints,
      avgImportance: avgImportance,
    );
  }

  /// Get all summaries.
  List<MemorySummary> get summaries => List.unmodifiable(_summaries);

  /// Get summary for a specific topic.
  MemorySummary? forTopic(String topic) {
    try {
      return _summaries.firstWhere((s) => s.topic == topic);
    } catch (_) {
      return null;
    }
  }

  /// Build a context string for the AI (fits in context window).
  String buildContext({int maxChars = 2000}) {
    final buf = StringBuffer();
    // Most recent summaries first
    for (final s in _summaries.reversed) {
      final text = '[${ s.topic}] ${s.summary}\n';
      if (buf.length + text.length > maxChars) break;
      buf.write(text);
    }
    return buf.toString();
  }

  void clear() => _summaries.clear();
}

/// A compressed summary of multiple memory entries.
class MemorySummary {
  const MemorySummary({
    required this.topic,
    required this.summary,
    required this.entryCount,
    required this.timeRange,
    required this.keyPoints,
    required this.avgImportance,
  });

  final String topic;
  final String summary;
  final int entryCount;
  final DateTimeRange timeRange;
  final List<String> keyPoints;
  final double avgImportance;
}

/// Simple date range (avoids Flutter dependency).
class DateTimeRange {
  const DateTimeRange({required this.start, required this.end});
  final DateTime start, end;
  Duration get duration => end.difference(start);
}
