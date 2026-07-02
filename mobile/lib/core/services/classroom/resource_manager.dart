import 'dart:async';
import 'dart:io';
import '../download/storage_manager.dart';

/// Manages classroom resources — courses, PDFs, videos, exams.
/// All resources are cached locally for offline usage.
class ResourceManager {
  ResourceManager({StorageManager? storage})
      : _storage = storage ?? StorageManager.instance;

  final StorageManager _storage;
  final Map<String, ClassResource> _resources = {};
  final _ctrl = StreamController<List<ClassResource>>.broadcast();
  Stream<List<ClassResource>> get resourceStream => _ctrl.stream;

  /// Add a resource to a classroom.
  Future<ClassResource> addResource({
    required String classId,
    required String name,
    required ResourceType type,
    required String sourceUrl,
    int? sizeBytes,
    String? sha256,
  }) async {
    final id = '${classId}_${DateTime.now().millisecondsSinceEpoch}';
    final localPath = await _storage.classResourcePath(classId);

    final resource = ClassResource(
      id: id,
      classId: classId,
      name: name,
      type: type,
      sourceUrl: sourceUrl,
      localPath: '$localPath/$name',
      sizeBytes: sizeBytes ?? 0,
      sha256: sha256,
      isDownloaded: false,
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _resources[id] = resource;
    _notify();
    return resource;
  }

  /// Mark a resource as downloaded.
  void markDownloaded(String resourceId) {
    final r = _resources[resourceId];
    if (r == null) return;
    _resources[resourceId] = r.copyWith(isDownloaded: true, updatedAt: DateTime.now());
    _notify();
  }

  /// Get all resources for a classroom.
  List<ClassResource> getClassResources(String classId) =>
      _resources.values.where((r) => r.classId == classId).toList();

  /// Get all downloaded resources (available offline).
  List<ClassResource> getOfflineResources() =>
      _resources.values.where((r) => r.isDownloaded).toList();

  /// Delete a resource and its local file.
  Future<bool> deleteResource(String resourceId) async {
    final r = _resources[resourceId];
    if (r == null) return false;
    final file = File(r.localPath);
    if (await file.exists()) await file.delete();
    _resources.remove(resourceId);
    _notify();
    return true;
  }

  /// Check if a resource file exists locally.
  Future<bool> isAvailableOffline(String resourceId) async {
    final r = _resources[resourceId];
    if (r == null) return false;
    return File(r.localPath).exists();
  }

  void _notify() {
    if (!_ctrl.isClosed) _ctrl.add(_resources.values.toList());
  }

  void dispose() => _ctrl.close();
}

/// A classroom resource entity.
class ClassResource {
  const ClassResource({
    required this.id,
    required this.classId,
    required this.name,
    required this.type,
    required this.sourceUrl,
    required this.localPath,
    required this.sizeBytes,
    required this.isDownloaded,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.sha256,
  });

  final String id, classId, name, sourceUrl, localPath;
  final ResourceType type;
  final int sizeBytes, version;
  final bool isDownloaded;
  final DateTime createdAt, updatedAt;
  final String? sha256;

  ClassResource copyWith({bool? isDownloaded, DateTime? updatedAt, int? version}) {
    return ClassResource(
      id: id, classId: classId, name: name, type: type,
      sourceUrl: sourceUrl, localPath: localPath, sizeBytes: sizeBytes,
      sha256: sha256, isDownloaded: isDownloaded ?? this.isDownloaded,
      version: version ?? this.version,
      createdAt: createdAt, updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'class_id': classId, 'name': name,
    'type': type.name, 'source_url': sourceUrl,
    'local_path': localPath, 'size_bytes': sizeBytes,
    'sha256': sha256, 'is_downloaded': isDownloaded,
    'version': version,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

/// Types of classroom resources.
enum ResourceType { course, pdf, video, exam, audio, document }
