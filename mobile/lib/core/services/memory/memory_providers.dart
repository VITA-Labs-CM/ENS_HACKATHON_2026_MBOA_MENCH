import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'session_memory.dart';
import 'persistent_memory.dart';
import 'summary_memory.dart';
import 'memory_manager.dart';

/// Provider for SessionMemory.
final sessionMemoryProvider = Provider<SessionMemory>((ref) {
  return SessionMemory();
});

/// Provider for PersistentMemory.
final persistentMemoryProvider = Provider<PersistentMemory>((ref) {
  final memory = PersistentMemory();
  // We don't await initialize here, it's done in MemoryManager initialization
  ref.onDispose(() => memory.close());
  return memory;
});

/// Provider for SummaryMemory.
final summaryMemoryProvider = Provider<SummaryMemory>((ref) {
  return SummaryMemory();
});

/// Provider for MemoryManager.
final memoryManagerProvider = Provider<MemoryManager>((ref) {
  final session = ref.watch(sessionMemoryProvider);
  final persistent = ref.watch(persistentMemoryProvider);
  final summary = ref.watch(summaryMemoryProvider);

  final manager = MemoryManager(
    session: session,
    persistent: persistent,
    summary: summary,
  );

  // Note: App startup logic should call await manager.initialize()
  ref.onDispose(() => manager.dispose());
  return manager;
});
