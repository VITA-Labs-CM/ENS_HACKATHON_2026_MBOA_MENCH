/// Short-term session memory — RAM-based, lost on app restart.
/// Stores current conversation context and recent interactions.
class SessionMemory {
  final List<MemoryEntry> _entries = [];
  final int maxEntries;

  SessionMemory({this.maxEntries = 100});

  /// Add an entry to session memory.
  void add(MemoryEntry entry) {
    _entries.add(entry);
    // Evict oldest if over capacity
    while (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
  }

  /// Get all entries.
  List<MemoryEntry> get entries => List.unmodifiable(_entries);

  /// Get recent entries (last N).
  List<MemoryEntry> recent(int count) {
    if (_entries.length <= count) return List.of(_entries);
    return _entries.sublist(_entries.length - count);
  }

  /// Search entries by keyword relevance.
  List<MemoryEntry> search(String query) {
    final keywords = query.toLowerCase().split(RegExp(r'\s+'));
    return _entries.where((e) {
      final text = '${e.content} ${e.topic}'.toLowerCase();
      return keywords.any((kw) => text.contains(kw));
    }).toList()
      ..sort((a, b) => b.importanceScore.compareTo(a.importanceScore));
  }

  /// Get entries for a specific topic.
  List<MemoryEntry> forTopic(String topic) =>
      _entries.where((e) => e.topic == topic).toList();

  /// Clear session memory.
  void clear() => _entries.clear();

  int get length => _entries.length;
}

/// A single memory entry.
class MemoryEntry {
  const MemoryEntry({
    required this.content,
    required this.topic,
    required this.type,
    required this.timestamp,
    this.importanceScore = 0.5,
    this.metadata = const {},
  });

  final String content;
  final String topic;
  final MemoryType type;
  final DateTime timestamp;
  final double importanceScore; // 0.0 to 1.0
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
    'content': content,
    'topic': topic,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'importance_score': importanceScore,
    'metadata': metadata,
  };

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
    content: json['content'] as String,
    topic: json['topic'] as String,
    type: MemoryType.values.byName(json['type'] as String),
    timestamp: DateTime.parse(json['timestamp'] as String),
    importanceScore: (json['importance_score'] as num).toDouble(),
    metadata: json['metadata'] as Map<String, dynamic>? ?? {},
  );
}

/// Types of memory entries.
enum MemoryType {
  conversation,  // Chat message
  quizResult,    // Quiz score
  mistake,       // Error made by student
  progress,      // Learning progress update
  preference,    // Student preference/style
  summary,       // Compressed summary
}
