import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Abstract LAN connection layer — teacher device as local server.
///
/// In production, this would use shelf/shelf_io for HTTP server
/// and mDNS for service discovery. Currently provides the interface
/// and simulated behavior.
class LanConnection {
  LanConnection({this.port = 8080});

  final int port;
  bool _isRunning = false;
  String? _serverAddress;
  final List<LanClient> _connectedClients = [];
  final _statusCtrl = StreamController<LanStatus>.broadcast();
  Stream<LanStatus> get statusStream => _statusCtrl.stream;

  bool get isRunning => _isRunning;
  String? get serverAddress => _serverAddress;
  List<LanClient> get connectedClients => List.unmodifiable(_connectedClients);

  /// Start LAN server on teacher device.
  Future<LanStartResult> startServer({
    required String classId,
    required String className,
    String? password,
  }) async {
    if (_isRunning) {
      return const LanStartResult(success: false, message: 'Serveur déjà actif');
    }

    try {
      // Get local IP address
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      String? localIp;
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) {
            localIp = addr.address;
            break;
          }
        }
        if (localIp != null) break;
      }

      if (localIp == null) {
        return const LanStartResult(
          success: false,
          message: 'Impossible de trouver l\'adresse IP locale. '
              'Vérifiez votre connexion Wi-Fi/hotspot.',
        );
      }

      _serverAddress = '$localIp:$port';
      _isRunning = true;

      _emit(LanStatus(
        state: LanState.running,
        address: _serverAddress!,
        classId: classId,
        className: className,
        clientCount: 0,
      ));

      return LanStartResult(
        success: true,
        message: 'Serveur démarré sur $_serverAddress',
        address: _serverAddress,
        networkName: 'MBOA-MENCH-CLASS',
      );
    } catch (e) {
      return LanStartResult(success: false, message: 'Erreur: $e');
    }
  }

  /// Stop LAN server.
  Future<void> stopServer() async {
    _isRunning = false;
    _serverAddress = null;
    _connectedClients.clear();
    _emit(const LanStatus(state: LanState.stopped));
  }

  /// Connect to a teacher's LAN server (student side).
  Future<LanConnectResult> connectToServer({
    required String serverAddress,
    required String studentId,
    required String studentName,
    String? classCode,
  }) async {
    try {
      // Validate address format
      final parts = serverAddress.split(':');
      if (parts.length != 2) {
        return const LanConnectResult(success: false, message: 'Adresse invalide');
      }

      // In production: HTTP GET to server to verify + register
      await Future.delayed(const Duration(milliseconds: 500));

      return LanConnectResult(
        success: true,
        message: 'Connecté au serveur local',
        serverAddress: serverAddress,
      );
    } catch (e) {
      return LanConnectResult(success: false, message: 'Connexion échouée: $e');
    }
  }

  /// Share a resource over LAN to connected students.
  Future<void> shareResource({
    required String filePath,
    required String resourceName,
    List<String>? targetStudentIds,
  }) async {
    if (!_isRunning) throw StateError('Serveur LAN non démarré');
    // In production: serve file via HTTP endpoint
    // Students would GET /resources/<resourceName>
  }

  /// Generate connection info as JSON (for QR code).
  String generateConnectionQr({
    required String classId,
    required String className,
  }) {
    return jsonEncode({
      'type': 'mboa_mench_lan',
      'address': _serverAddress,
      'class_id': classId,
      'class_name': className,
      'version': 1,
    });
  }

  void _emit(LanStatus s) {
    if (!_statusCtrl.isClosed) _statusCtrl.add(s);
  }

  void dispose() {
    stopServer();
    _statusCtrl.close();
  }
}

/// A connected student device.
class LanClient {
  const LanClient({required this.id, required this.name, required this.deviceInfo, required this.connectedAt});
  final String id, name, deviceInfo;
  final DateTime connectedAt;
}

class LanStartResult {
  const LanStartResult({required this.success, required this.message, this.address, this.networkName});
  final bool success; final String message; final String? address, networkName;
}

class LanConnectResult {
  const LanConnectResult({required this.success, required this.message, this.serverAddress});
  final bool success; final String message; final String? serverAddress;
}

class LanStatus {
  const LanStatus({required this.state, this.address, this.classId, this.className, this.clientCount = 0});
  final LanState state; final String? address, classId, className; final int clientCount;
}

enum LanState { stopped, starting, running, error }
