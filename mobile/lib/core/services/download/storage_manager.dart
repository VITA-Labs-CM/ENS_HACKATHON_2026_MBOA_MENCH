import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Manages structured storage folders for offline content.
///
/// Directory layout:
/// ```
/// <app_dir>/mboa_mench/
///   ├── models/          — AI model files (GGUF, embeddings)
///   ├── courses/         — Downloaded course packs (PDFs, text, quizzes)
///   │   └── <pack_id>/   — One folder per course pack
///   ├── class_resources/  — Synced classroom resources
///   │   └── <class_id>/  — Per-class resources
///   ├── temp/            — Partial downloads, staging area
///   └── cache/           — Ephemeral data (can be cleared)
/// ```
class StorageManager {
  StorageManager._();

  static StorageManager? _instance;
  static StorageManager get instance => _instance ??= StorageManager._();

  String? _basePath;

  /// Root directories for structured storage.
  static const _dirs = [
    'models',
    'courses',
    'class_resources',
    'temp',
    'cache',
  ];

  /// Initialize storage — creates all required folders.
  /// Must be called once at app startup.
  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _basePath = '${appDir.path}/mboa_mench';

    for (final dir in _dirs) {
      await Directory('$_basePath/$dir').create(recursive: true);
    }
  }

  /// Base path for all MBOA MENCH storage.
  String get basePath {
    if (_basePath == null) {
      throw StateError(
          'StorageManager not initialized. Call initialize() first.');
    }
    return _basePath!;
  }

  /// Path for AI model storage.
  String get modelsPath => '$basePath/models';

  /// Path for course pack storage.
  String get coursesPath => '$basePath/courses';

  /// Path for classroom resource storage.
  String get classResourcesPath => '$basePath/class_resources';

  /// Path for temporary/partial downloads.
  String get tempPath => '$basePath/temp';

  /// Path for cache data.
  String get cachePath => '$basePath/cache';

  /// Get or create a folder for a specific course pack.
  Future<String> coursePackPath(String packId) async {
    final path = '$coursesPath/$packId';
    await Directory(path).create(recursive: true);
    return path;
  }

  /// Get or create a folder for a specific classroom.
  Future<String> classResourcePath(String classId) async {
    final path = '$classResourcesPath/$classId';
    await Directory(path).create(recursive: true);
    return path;
  }

  /// Temporary file path for download-in-progress (for resume support).
  String tempFilePath(String downloadId, String fileName) {
    return '$tempPath/${downloadId}_$fileName';
  }

  /// Final destination path for a model file.
  String modelFilePath(String fileName) => '$modelsPath/$fileName';

  /// Calculate total used storage in bytes.
  Future<int> totalUsedBytes() async {
    int total = 0;
    for (final dirName in _dirs) {
      final dir = Directory('$basePath/$dirName');
      if (await dir.exists()) {
        total += await _directorySize(dir);
      }
    }
    return total;
  }

  /// Calculate storage used per category.
  Future<Map<String, int>> usageByCategory() async {
    final usage = <String, int>{};
    for (final dirName in _dirs) {
      final dir = Directory('$basePath/$dirName');
      if (await dir.exists()) {
        usage[dirName] = await _directorySize(dir);
      } else {
        usage[dirName] = 0;
      }
    }
    return usage;
  }

  /// Delete all cached data to free space.
  Future<int> clearCache() async {
    final cacheDir = Directory(cachePath);
    if (await cacheDir.exists()) {
      final size = await _directorySize(cacheDir);
      await cacheDir.delete(recursive: true);
      await cacheDir.create();
      return size;
    }
    return 0;
  }

  /// Delete all temp/partial download files.
  Future<int> clearTemp() async {
    final tempDir = Directory(tempPath);
    if (await tempDir.exists()) {
      final size = await _directorySize(tempDir);
      await tempDir.delete(recursive: true);
      await tempDir.create();
      return size;
    }
    return 0;
  }

  /// Delete a specific course pack and all its files.
  Future<bool> deleteCoursePack(String packId) async {
    final dir = Directory('$coursesPath/$packId');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      return true;
    }
    return false;
  }

  /// Delete a specific model file.
  Future<bool> deleteModel(String fileName) async {
    final file = File('$modelsPath/$fileName');
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }

  /// List all downloaded course packs.
  Future<List<String>> listCoursePacks() async {
    final dir = Directory(coursesPath);
    if (!await dir.exists()) return [];
    return dir
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.split('/').last)
        .toList();
  }

  /// List all downloaded models.
  Future<List<String>> listModels() async {
    final dir = Directory(modelsPath);
    if (!await dir.exists()) return [];
    return dir
        .listSync()
        .whereType<File>()
        .map((f) => f.path.split('/').last)
        .toList();
  }

  /// Move a completed download from temp to its final location.
  Future<File> promoteFromTemp({
    required String tempFilePath,
    required String finalPath,
  }) async {
    final tempFile = File(tempFilePath);
    if (!await tempFile.exists()) {
      throw FileSystemException('Fichier temporaire introuvable', tempFilePath);
    }

    // Ensure parent directory exists
    await Directory(finalPath).parent.create(recursive: true);

    return await tempFile.rename(finalPath);
  }

  /// Recursively calculate directory size.
  Future<int> _directorySize(Directory dir) async {
    int size = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }
}
