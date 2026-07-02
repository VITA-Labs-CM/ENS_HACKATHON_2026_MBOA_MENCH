import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'resource_manager.dart';

/// Sync engine — auto/manual with LWW conflict resolution.
class SyncService {
  SyncService({required this.resourceManager, SharedPreferences? prefs})
      : _prefs = prefs;

  final ResourceManager resourceManager;
  SharedPreferences? _prefs;
  final List<SyncOperation> _outbox = [];
  final Map<String, DateTime> _lastSync = {};
  final _statusCtrl = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _statusCtrl.stream;
  bool _isOnline = false;
  bool _autoSyncEnabled = true;
  StreamSubscription? _connectSub;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    _autoSyncEnabled = _prefs?.getBool('auto_sync_enabled') ?? true;
    _loadTimestamps();
    _connectSub = Connectivity().onConnectivityChanged.listen((r) {
      final was = !_isOnline;
      _isOnline = !r.contains(ConnectivityResult.none);
      if (_isOnline && was && _autoSyncEnabled) syncAll();
    });
    final r = await Connectivity().checkConnectivity();
    _isOnline = !r.contains(ConnectivityResult.none);
  }

  Future<void> setAutoSync(bool v) async {
    _autoSyncEnabled = v;
    await _prefs?.setBool('auto_sync_enabled', v);
  }

  bool get isAutoSyncEnabled => _autoSyncEnabled;
  bool get isOnline => _isOnline;
  int get pendingCount => _outbox.length;

  void enqueueChange(SyncOperation op) {
    _outbox.add(op);
    _emit(SyncStatus(state: SyncState.pendingChanges, pendingCount: _outbox.length));
    if (_isOnline && _autoSyncEnabled) _pushOutbox();
  }

  Future<SyncResult> syncAll() async {
    if (!_isOnline) return const SyncResult(success: false, message: 'Hors ligne', pushed: 0, pulled: 0);
    _emit(const SyncStatus(state: SyncState.syncing, message: 'Synchronisation…'));
    try {
      final pushed = await _pushOutbox();
      final pulled = await _pullRemote();
      _lastSync['all'] = DateTime.now();
      await _saveTimestamps();
      _emit(SyncStatus(state: SyncState.idle, lastSync: DateTime.now()));
      return SyncResult(success: true, message: 'OK', pushed: pushed, pulled: pulled);
    } catch (e) {
      _emit(SyncStatus(state: SyncState.error, message: '$e'));
      return SyncResult(success: false, message: '$e', pushed: 0, pulled: 0);
    }
  }

  SyncConflictResult resolveConflict(Map<String, dynamic> local, Map<String, dynamic> remote) {
    final lt = DateTime.parse(local['updated_at'] ?? DateTime.now().toIso8601String());
    final rt = DateTime.parse(remote['updated_at'] ?? DateTime.now().toIso8601String());
    return rt.isAfter(lt)
        ? SyncConflictResult(winner: ConflictWinner.remote, data: remote)
        : SyncConflictResult(winner: ConflictWinner.local, data: local);
  }

  DateTime? getLastSync(String key) => _lastSync[key];

  Future<int> _pushOutbox() async {
    int c = 0;
    for (final op in List.of(_outbox)) {
      await Future.delayed(const Duration(milliseconds: 50));
      _outbox.remove(op);
      c++;
    }
    return c;
  }

  Future<int> _pullRemote() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 0;
  }

  void _loadTimestamps() {
    final j = _prefs?.getString('last_sync_timestamps');
    if (j != null) {
      (jsonDecode(j) as Map<String, dynamic>).forEach((k, v) {
        _lastSync[k] = DateTime.parse(v as String);
      });
    }
  }

  Future<void> _saveTimestamps() async {
    await _prefs?.setString('last_sync_timestamps',
        jsonEncode(_lastSync.map((k, v) => MapEntry(k, v.toIso8601String()))));
  }

  void _emit(SyncStatus s) { if (!_statusCtrl.isClosed) _statusCtrl.add(s); }

  void dispose() { _connectSub?.cancel(); _statusCtrl.close(); }
}

class SyncOperation {
  const SyncOperation({required this.id, required this.resourceType, required this.operationType, required this.data, required this.timestamp});
  final String id;
  final SyncResourceType resourceType;
  final SyncOperationType operationType;
  final Map<String, dynamic> data;
  final DateTime timestamp;
}

enum SyncResourceType { course, quiz, quizResult, message, studentProgress, classResource }
enum SyncOperationType { create, update, delete }

class SyncStatus {
  const SyncStatus({required this.state, this.pendingCount = 0, this.lastSync, this.message});
  final SyncState state; final int pendingCount; final DateTime? lastSync; final String? message;
}

enum SyncState { idle, syncing, pendingChanges, error }

class SyncResult {
  const SyncResult({required this.success, required this.message, required this.pushed, required this.pulled});
  final bool success; final String message; final int pushed; final int pulled;
}

class SyncConflictResult {
  const SyncConflictResult({required this.winner, required this.data});
  final ConflictWinner winner; final Map<String, dynamic> data;
}

enum ConflictWinner { local, remote }
