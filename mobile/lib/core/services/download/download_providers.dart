import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'download_manager.dart';
import 'storage_manager.dart';

/// Singleton provider for the DownloadManager.
final downloadManagerProvider = Provider<DownloadManager>((ref) {
  final manager = DownloadManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// Singleton provider for StorageManager.
final storageManagerProvider = Provider<StorageManager>((ref) {
  return StorageManager.instance;
});

/// Stream of all download task state updates.
final downloadStateStreamProvider = StreamProvider<DownloadTask>((ref) {
  return ref.watch(downloadManagerProvider).stateStream;
});

/// Reactive state for a specific download task.
final downloadTaskProvider =
    StateNotifierProvider.family<DownloadTaskNotifier, DownloadTask?, String>(
  (ref, taskId) {
    final manager = ref.watch(downloadManagerProvider);
    return DownloadTaskNotifier(manager, taskId);
  },
);

/// Notifier for a single download task — subscribes to DownloadManager stream.
class DownloadTaskNotifier extends StateNotifier<DownloadTask?> {
  DownloadTaskNotifier(this._manager, this._taskId) : super(null) {
    // Initial state
    state = _manager.getTask(_taskId);

    // Subscribe to updates
    _subscription = _manager.stateStream.listen((task) {
      if (task.id == _taskId) {
        state = task;
      }
    });
  }

  final DownloadManager _manager;
  final String _taskId;
  StreamSubscription<DownloadTask>? _subscription;

  void pause() => _manager.pause(_taskId);
  Future<void> resume() => _manager.resume(_taskId);
  void cancel() => _manager.cancel(_taskId);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Reactive storage usage data.
final storageUsageProvider = FutureProvider<StorageUsage>((ref) async {
  final storage = ref.watch(storageManagerProvider);
  final byCategory = await storage.usageByCategory();
  final total = await storage.totalUsedBytes();

  return StorageUsage(
    totalBytes: total,
    modelBytes: byCategory['models'] ?? 0,
    courseBytes: byCategory['courses'] ?? 0,
    resourceBytes: byCategory['class_resources'] ?? 0,
    tempBytes: byCategory['temp'] ?? 0,
    cacheBytes: byCategory['cache'] ?? 0,
  );
});

/// All active + queued download tasks.
final allDownloadTasksProvider =
    Provider<List<DownloadTask>>((ref) {
  // Trigger rebuild on any state change
  ref.watch(downloadStateStreamProvider);
  return ref.watch(downloadManagerProvider).allTasks;
});

/// Storage usage breakdown.
class StorageUsage {
  const StorageUsage({
    required this.totalBytes,
    required this.modelBytes,
    required this.courseBytes,
    required this.resourceBytes,
    required this.tempBytes,
    required this.cacheBytes,
  });

  final int totalBytes;
  final int modelBytes;
  final int courseBytes;
  final int resourceBytes;
  final int tempBytes;
  final int cacheBytes;

  double get totalMb => totalBytes / (1024 * 1024);
  double get modelMb => modelBytes / (1024 * 1024);
  double get courseMb => courseBytes / (1024 * 1024);
  double get resourceMb => resourceBytes / (1024 * 1024);
}
