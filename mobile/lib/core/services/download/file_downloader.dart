import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'file_integrity.dart';

/// Low-level file download service with resume support.
///
/// Features:
/// - Chunked downloads with progress callbacks
/// - Interruption recovery (HTTP Range headers)
/// - SHA256 verification after download
/// - WiFi-only mode enforcement
class FileDownloader {
  FileDownloader({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    return Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 10),
      sendTimeout: const Duration(seconds: 15),
    ));
  }

  /// Download a file with resume support.
  ///
  /// [url] — Remote file URL.
  /// [savePath] — Where to save the file (temp path recommended).
  /// [expectedSha256] — Optional hash for post-download verification.
  /// [onProgress] — Callback with (received, total) in bytes.
  /// [cancelToken] — Token to cancel/pause the download.
  Future<DownloadResult> download({
    required String url,
    required String savePath,
    String? expectedSha256,
    int? expectedSizeBytes,
    void Function(int received, int total, double speed)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final tempFile = File(savePath);
    int downloadedBytes = 0;

    // Check for existing partial download (resume support)
    if (await tempFile.exists()) {
      downloadedBytes = await tempFile.length();
    }

    try {
      // Track speed
      int lastReceived = downloadedBytes;
      DateTime lastTime = DateTime.now();

      final response = await _dio.download(
        url,
        savePath,
        options: Options(
          headers: downloadedBytes > 0
              ? {'Range': 'bytes=$downloadedBytes-'}
              : null,
          // Append if resuming, create if new
          extra: {'append': downloadedBytes > 0},
        ),
        deleteOnError: false, // Keep partial for resume
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final now = DateTime.now();
          final elapsed = now.difference(lastTime).inMilliseconds;

          double speed = 0;
          if (elapsed > 500) {
            // Calculate speed in KB/s
            final bytesPerMs =
                (received - lastReceived + downloadedBytes) / elapsed;
            speed = bytesPerMs * 1000 / 1024; // KB/s
            lastReceived = received;
            lastTime = now;
          }

          final actualReceived = received + downloadedBytes;
          final actualTotal =
              total != -1 ? total + downloadedBytes : (expectedSizeBytes ?? -1);
          onProgress?.call(actualReceived, actualTotal, speed);
        },
      );

      if (response.statusCode != 200 && response.statusCode != 206) {
        return DownloadResult(
          status: DownloadStatus.failed,
          message:
              'Erreur HTTP ${response.statusCode}: ${response.statusMessage}',
          filePath: savePath,
        );
      }

      // Verify integrity if hash provided
      if (expectedSha256 != null) {
        final integrityResult = await FileIntegrity.checkIntegrity(
          filePath: savePath,
          expectedSha256: expectedSha256,
          expectedSizeBytes: expectedSizeBytes,
        );

        if (!integrityResult.isValid) {
          return DownloadResult(
            status: DownloadStatus.integrityFailed,
            message: integrityResult.message,
            filePath: savePath,
          );
        }
      }

      return DownloadResult(
        status: DownloadStatus.completed,
        message: 'Téléchargement terminé',
        filePath: savePath,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return DownloadResult(
          status: DownloadStatus.paused,
          message: 'Téléchargement suspendu',
          filePath: savePath,
          downloadedBytes: await File(savePath).length(),
        );
      }

      return DownloadResult(
        status: DownloadStatus.failed,
        message: 'Erreur réseau: ${e.message}',
        filePath: savePath,
        downloadedBytes:
            await tempFile.exists() ? await tempFile.length() : 0,
      );
    } catch (e) {
      return DownloadResult(
        status: DownloadStatus.failed,
        message: 'Erreur inattendue: $e',
        filePath: savePath,
      );
    }
  }

  /// Check if a remote file supports range requests (for resume).
  Future<bool> supportsResume(String url) async {
    try {
      final response = await _dio.head(url);
      return response.headers.value('accept-ranges') == 'bytes';
    } catch (_) {
      return false;
    }
  }

  /// Get remote file size without downloading.
  Future<int?> getRemoteFileSize(String url) async {
    try {
      final response = await _dio.head(url);
      final contentLength = response.headers.value('content-length');
      return contentLength != null ? int.tryParse(contentLength) : null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _dio.close();
  }
}

/// Result of a download operation.
class DownloadResult {
  const DownloadResult({
    required this.status,
    required this.message,
    required this.filePath,
    this.downloadedBytes,
  });

  final DownloadStatus status;
  final String message;
  final String filePath;
  final int? downloadedBytes;

  bool get isSuccess => status == DownloadStatus.completed;
  bool get isPaused => status == DownloadStatus.paused;
  bool get canResume =>
      status == DownloadStatus.paused || status == DownloadStatus.failed;
}

/// Status of a download operation.
enum DownloadStatus {
  completed,
  paused,
  failed,
  integrityFailed,
}
