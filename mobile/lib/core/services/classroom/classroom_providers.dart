import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'classroom_service.dart';
import 'sync_service.dart';
import 'resource_manager.dart';
import 'lan_connection.dart';
import 'cloud_sync.dart';

/// ClassroomService provider.
final classroomServiceProvider = Provider<ClassroomService>((ref) {
  final service = ClassroomService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// ResourceManager provider.
final resourceManagerProvider = Provider<ResourceManager>((ref) {
  final manager = ResourceManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// SyncService provider.
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(resourceManager: ref.watch(resourceManagerProvider));
  ref.onDispose(() => service.dispose());
  return service;
});

/// LAN connection provider.
final lanConnectionProvider = Provider<LanConnection>((ref) {
  final conn = LanConnection();
  ref.onDispose(() => conn.dispose());
  return conn;
});

/// Cloud sync provider.
final cloudSyncProvider = Provider<CloudSync>((ref) {
  final sync = CloudSync(baseUrl: 'https://api.mboamench.cm');
  ref.onDispose(() => sync.dispose());
  return sync;
});

/// Stream of sync status for UI.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(syncServiceProvider).syncStatusStream;
});

/// Stream of classroom list changes.
final classroomListProvider = StreamProvider<List<Classroom>>((ref) {
  return ref.watch(classroomServiceProvider).classroomStream;
});

/// Stream of LAN server status.
final lanStatusProvider = StreamProvider<LanStatus>((ref) {
  return ref.watch(lanConnectionProvider).statusStream;
});
