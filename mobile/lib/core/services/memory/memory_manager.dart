import 'session_memory.dart';
import 'persistent_memory.dart';
import 'summary_memory.dart';
import 'memory_repository.dart';

/// Orchestrates all memory layers.
class MemoryManager {
  MemoryManager({
    SessionMemory? session,
    PersistentMemory? persistent,
    SummaryMemory? summary,
  })  : session = session ?? SessionMemory(),
        persistent = persistent ?? PersistentMemory(),
        summary = summary ?? SummaryMemory(),
        repository = MemoryRepository(
          sessionMemory: session ?? SessionMemory(),
          persistentMemory: persistent ?? PersistentMemory(),
          summaryMemory: summary ?? SummaryMemory(),
        );

  final SessionMemory session;
  final PersistentMemory persistent;
  final SummaryMemory summary;
  final MemoryRepository repository;

  bool _initialized = false;

  /// Initialize persistent storage.
  Future<void> initialize() async {
    if (_initialized) return;
    await persistent.initialize();
    _initialized = true;
  }

  /// Add a new memory entry to both session and persistent memory.
  Future<void> addMemory(String studentId, MemoryEntry entry) async {
    // 1. Add to session memory for immediate access
    session.add(entry);

    // 2. Persist to SQLite
    if (_initialized) {
      await persistent.store(studentId, entry);
    }
  }

  /// Retrieve relevant context for a query.
  Future<RetrievalResult> getContext(String studentId, String query) async {
    if (!_initialized) throw StateError('MemoryManager not initialized');
    return await repository.retrieve(studentId: studentId, query: query);
  }

  /// Summarize a completed session and clear short-term memory.
  Future<void> summarizeSessionAndClear(String topic) async {
    final entries = session.forTopic(topic);
    if (entries.isNotEmpty) {
      final s = summary.summarizeEntries(entries, topic);
      summary.addSummary(s);
    }
    // Clear session memory to free RAM
    session.clear();
  }

  /// Prune old persistent memories if storage is full.
  Future<void> pruneOldMemories(String studentId) async {
    if (!_initialized) return;
    await persistent.prune(studentId);
  }

  Future<void> dispose() async {
    if (_initialized) {
      await persistent.close();
      _initialized = false;
    }
  }
}
