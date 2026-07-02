import 'dart:async';
import 'package:dio/dio.dart';
import 'file_downloader.dart';
import 'file_integrity.dart';
import 'storage_manager.dart';

/// Orchestrates all downloads — queuing, concurrency, resume, integrity.
///
/// Architecture:
/// ```
/// DownloadManager (queue, orchestration)
///   └─ FileDownloader (HTTP transport)
///       └─ FileIntegrity (SHA256, isolate)
///   └─ StorageManager (paths, cleanup)
/// ```
class DownloadManager {
  DownloadManager({
    FileDownloader? downloader,
    StorageManager? storage,
    this.maxConcurrentDownloads = 2,
  })  : _downloader = downloader ?? FileDownloader(),
        _storage = storage ?? StorageManager.instance;

  final FileDownloader _downloader;
  final StorageManager _storage;
  final int maxConcurrentDownloads;

  /// Active downloads map: taskId → DownloadTask
  final Map<String, DownloadTask> _tasks = {};

  /// Queue of pending downloads
  final List<DownloadTask> _queue = [];

  /// Currently running downloads
  final List<String> _active = [];

  /// Stream of download state changes
  final _stateController = StreamController<DownloadTask>.broadcast();
  Stream<DownloadTask> get stateStream => _stateController.stream;

  /// Enqueue a download task. Starts immediately if capacity permits.
  Future<String> enqueue(DownloadRequest request) async {
    final task = DownloadTask(
      id: request.id,
      url: request.url,
      fileName: request.fileName,
      type: request.type,
      expectedSha256: request.expectedSha256,
      expectedSizeBytes: request.expectedSizeBytes,
      status: DownloadTaskStatus.queued,
      progress: 0,
      speedKbps: 0,
      cancelToken: CancelToken(),
    );

    _tasks[task.id] = task;
    _queue.add(task);
    _emitState(task);

    _processQueue();
    return task.id;
  }

  /// Pause a running download.
  void pause(String taskId) {
    final task = _tasks[taskId];
    if (task == null || task.status != DownloadTaskStatus.downloading) return;

    task.cancelToken.cancel('paused');
    _tasks[taskId] = task.copyWith(status: DownloadTaskStatus.paused);
    _active.remove(taskId);
    _emitState(_tasks[taskId]!);
    _processQueue();
  }

  /// Resume a paused or failed download.
  Future<void> resume(String taskId) async {
    final task = _tasks[taskId];
    if (task == null) return;
    if (task.status != DownloadTaskStatus.paused &&
        task.status != DownloadTaskStatus.failed) {
      return;
    }

    // Create new cancel token for the resumed download
    _tasks[taskId] = task.copyWith(
      status: DownloadTaskStatus.queued,
      cancelToken: CancelToken(),
    );
    _queue.add(_tasks[taskId]!);
    _emitState(_tasks[taskId]!);
    _processQueue();
  }

  /// Cancel and remove a download.
  void cancel(String taskId) {
    final task = _tasks[taskId];
    if (task == null) return;

    if (task.status == DownloadTaskStatus.downloading) {
      task.cancelToken.cancel('cancelled');
    }

    _active.remove(taskId);
    _queue.removeWhere((t) => t.id == taskId);
    _tasks.remove(taskId);
    _processQueue();
  }

  /// Get current state of a task.
  DownloadTask? getTask(String taskId) => _tasks[taskId];

  /// Get all tasks.
  List<DownloadTask> get allTasks => _tasks.values.toList();

  /// Get active tasks.
  List<DownloadTask> get activeTasks =>
      _active.map((id) => _tasks[id]!).toList();

  /// Process the download queue — start tasks if capacity allows.
  void _processQueue() {
    while (_active.length < maxConcurrentDownloads && _queue.isNotEmpty) {
      final task = _queue.removeAt(0);
      _startDownload(task);
    }
  }

  /// Start a single download.
  Future<void> _startDownload(DownloadTask task) async {
    _active.add(task.id);
    _tasks[task.id] = task.copyWith(status: DownloadTaskStatus.downloading);
    _emitState(_tasks[task.id]!);

    // Determine save path based on type
    final savePath = _resolveFilePath(task);

    final result = await _downloader.download(
      url: task.url,
      savePath: savePath,
      expectedSha256: task.expectedSha256,
      expectedSizeBytes: task.expectedSizeBytes,
      cancelToken: task.cancelToken,
      onProgress: (received, total, speed) {
        final progress = total > 0 ? received / total : 0.0;
        _tasks[task.id] = _tasks[task.id]!.copyWith(
          progress: progress,
          speedKbps: speed,
          downloadedBytes: received,
          totalBytes: total,
        );
        _emitState(_tasks[task.id]!);
      },
    );

    _active.remove(task.id);

    if (result.isSuccess) {
      // Move from temp to final location if needed
      final finalPath = _resolveFinalPath(task);
      if (savePath != finalPath) {
        await _storage.promoteFromTemp(
          tempFilePath: savePath,
          finalPath: finalPath,
        );
      }

      // Verify integrity
      _tasks[task.id] = _tasks[task.id]!.copyWith(
        status: DownloadTaskStatus.verifying,
      );
      _emitState(_tasks[task.id]!);

      if (task.expectedSha256 != null) {
        final integrity = await FileIntegrity.checkIntegrity(
          filePath: finalPath,
          expectedSha256: task.expectedSha256,
          expectedSizeBytes: task.expectedSizeBytes,
        );

        if (!integrity.isValid) {
          _tasks[task.id] = _tasks[task.id]!.copyWith(
            status: DownloadTaskStatus.failed,
            error: integrity.message,
          );
          _emitState(_tasks[task.id]!);
          _processQueue();
          return;
        }
      }

      _tasks[task.id] = _tasks[task.id]!.copyWith(
        status: DownloadTaskStatus.completed,
        progress: 1.0,
      );
    } else if (result.isPaused) {
      _tasks[task.id] = _tasks[task.id]!.copyWith(
        status: DownloadTaskStatus.paused,
        downloadedBytes: result.downloadedBytes,
      );
    } else {
      _tasks[task.id] = _tasks[task.id]!.copyWith(
        status: DownloadTaskStatus.failed,
        error: result.message,
      );
    }

    _emitState(_tasks[task.id]!);
    _processQueue();
  }

  String _resolveFilePath(DownloadTask task) {
    return switch (task.type) {
      DownloadType.model => _storage.tempFilePath(task.id, task.fileName),
      DownloadType.coursePack => _storage.tempFilePath(task.id, task.fileName),
      DownloadType.classResource =>
        _storage.tempFilePath(task.id, task.fileName),
    };
  }

  String _resolveFinalPath(DownloadTask task) {
    return switch (task.type) {
      DownloadType.model => _storage.modelFilePath(task.fileName),
      DownloadType.coursePack => '${_storage.coursesPath}/${task.fileName}',
      DownloadType.classResource =>
        '${_storage.classResourcesPath}/${task.fileName}',
    };
  }

  void _emitState(DownloadTask task) {
    if (!_stateController.isClosed) {
      _stateController.add(task);
    }
  }

  void dispose() {
    // Cancel all active downloads
    for (final id in _active) {
      _tasks[id]?.cancelToken.cancel('disposed');
    }
    _stateController.close();
    _downloader.dispose();
  }
}

/// Request to enqueue a download.
class DownloadRequest {
  const DownloadRequest({
    required this.id,
    required this.url,
    required this.fileName,
    required this.type,
    this.expectedSha256,
    this.expectedSizeBytes,
  });

  final String id;
  final String url;
  final String fileName;
  final DownloadType type;
  final String? expectedSha256;
  final int? expectedSizeBytes;
}

/// Represents a tracked download task with its current state.
class DownloadTask {
  DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    required this.type,
    required this.status,
    required this.progress,
    required this.speedKbps,
    required this.cancelToken,
    this.expectedSha256,
    this.expectedSizeBytes,
    this.downloadedBytes,
    this.totalBytes,
    this.error,
  });

  final String id;
  final String url;
  final String fileName;
  final DownloadType type;
  final DownloadTaskStatus status;
  final double progress;
  final double speedKbps;
  final CancelToken cancelToken;
  final String? expectedSha256;
  final int? expectedSizeBytes;
  final int? downloadedBytes;
  final int? totalBytes;
  final String? error;

  DownloadTask copyWith({
    DownloadTaskStatus? status,
    double? progress,
    double? speedKbps,
    CancelToken? cancelToken,
    int? downloadedBytes,
    int? totalBytes,
    String? error,
  }) {
    return DownloadTask(
      id: id,
      url: url,
      fileName: fileName,
      type: type,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      speedKbps: speedKbps ?? this.speedKbps,
      cancelToken: cancelToken ?? this.cancelToken,
      expectedSha256: expectedSha256,
      expectedSizeBytes: expectedSizeBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      error: error ?? this.error,
    );
  }
}

/// Task lifecycle status.
enum DownloadTaskStatus {
  queued,
  downloading,
  verifying,
  completed,
  paused,
  failed,
}

/// Type of downloadable content.
enum DownloadType {
  model,
  coursePack,
  classResource,
}
