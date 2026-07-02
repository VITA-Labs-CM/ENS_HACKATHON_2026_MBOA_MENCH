import 'dart:io';
import 'dart:isolate';
import 'package:crypto/crypto.dart';

/// SHA256 file integrity verification — runs in isolate to avoid UI jank.
class FileIntegrity {
  /// Computes SHA256 hash of a file in a background isolate.
  /// Returns the hex-encoded hash string.
  static Future<String> computeSha256(String filePath) async {
    return await Isolate.run(() => _computeSha256Sync(filePath));
  }

  /// Synchronous SHA256 computation — called inside isolate.
  static String _computeSha256Sync(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('Fichier introuvable', filePath);
    }

    final bytes = file.readAsBytesSync();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies a file against an expected SHA256 hash.
  /// Returns `true` if the hash matches, `false` otherwise.
  static Future<bool> verifySha256(String filePath, String expectedHash) async {
    try {
      final actualHash = await computeSha256(filePath);
      return actualHash.toLowerCase() == expectedHash.toLowerCase();
    } catch (_) {
      return false;
    }
  }

  /// Detects if a file is corrupted by:
  /// 1. Checking file exists and is not empty
  /// 2. Verifying the file can be read completely
  /// 3. Optionally checking SHA256 against expected hash
  static Future<FileIntegrityResult> checkIntegrity({
    required String filePath,
    String? expectedSha256,
    int? expectedSizeBytes,
  }) async {
    return await Isolate.run(() {
      final file = File(filePath);

      // Check existence
      if (!file.existsSync()) {
        return const FileIntegrityResult(
          status: IntegrityStatus.missing,
          message: 'Fichier introuvable',
        );
      }

      // Check size
      final actualSize = file.lengthSync();
      if (actualSize == 0) {
        return const FileIntegrityResult(
          status: IntegrityStatus.corrupted,
          message: 'Fichier vide (0 octets)',
        );
      }

      if (expectedSizeBytes != null && actualSize != expectedSizeBytes) {
        return FileIntegrityResult(
          status: IntegrityStatus.corrupted,
          message:
              'Taille incorrecte: $actualSize octets (attendu: $expectedSizeBytes)',
          actualSizeBytes: actualSize,
        );
      }

      // Check readability
      try {
        final bytes = file.readAsBytesSync();
        if (bytes.length != actualSize) {
          return const FileIntegrityResult(
            status: IntegrityStatus.corrupted,
            message: 'Lecture incomplète du fichier',
          );
        }

        // Check SHA256 if provided
        if (expectedSha256 != null) {
          final digest = sha256.convert(bytes);
          final actualHash = digest.toString();
          if (actualHash.toLowerCase() != expectedSha256.toLowerCase()) {
            return FileIntegrityResult(
              status: IntegrityStatus.hashMismatch,
              message: 'SHA256 ne correspond pas',
              actualHash: actualHash,
              expectedHash: expectedSha256,
              actualSizeBytes: actualSize,
            );
          }
          return FileIntegrityResult(
            status: IntegrityStatus.valid,
            message: 'Fichier vérifié (SHA256 OK)',
            actualHash: actualHash,
            actualSizeBytes: actualSize,
          );
        }

        return FileIntegrityResult(
          status: IntegrityStatus.valid,
          message: 'Fichier lisible et complet',
          actualSizeBytes: actualSize,
        );
      } catch (e) {
        return FileIntegrityResult(
          status: IntegrityStatus.corrupted,
          message: 'Erreur de lecture: $e',
        );
      }
    });
  }
}

/// Result of a file integrity check.
class FileIntegrityResult {
  const FileIntegrityResult({
    required this.status,
    required this.message,
    this.actualHash,
    this.expectedHash,
    this.actualSizeBytes,
  });

  final IntegrityStatus status;
  final String message;
  final String? actualHash;
  final String? expectedHash;
  final int? actualSizeBytes;

  bool get isValid => status == IntegrityStatus.valid;
}

/// Possible integrity check outcomes.
enum IntegrityStatus {
  valid,
  missing,
  corrupted,
  hashMismatch,
}
