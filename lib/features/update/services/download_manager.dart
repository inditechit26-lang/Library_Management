import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

enum DownloadStatus {
  idle,
  downloading,
  completed,
  cancelled,
  failed,
}

enum DownloadErrorType {
  none,
  noInternet,
  invalidUrl,
  permissionDenied,
  insufficientStorage,
  downloadFailed,
}

class DownloadState {
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final double speedBytesPerSec;
  final double remainingSeconds;
  final int downloadedBytes;
  final int totalBytes;
  final String? filePath;
  final DownloadErrorType errorType;
  final String errorMessage;

  const DownloadState({
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.speedBytesPerSec = 0.0,
    this.remainingSeconds = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.filePath,
    this.errorType = DownloadErrorType.none,
    this.errorMessage = '',
  });

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    double? speedBytesPerSec,
    double? remainingSeconds,
    int? downloadedBytes,
    int? totalBytes,
    String? filePath,
    DownloadErrorType? errorType,
    String? errorMessage,
  }) {
    return DownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      filePath: filePath ?? this.filePath,
      errorType: errorType ?? this.errorType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DownloadManager {
  http.Client? _httpClient;
  StreamController<DownloadState>? _stateController;
  DownloadState _currentState = const DownloadState();
  bool _isCancelled = false;

  Stream<DownloadState> get stateStream => _stateController?.stream ?? const Stream.empty();
  DownloadState get currentState => _currentState;

  Future<void> startDownload(String urlString) async {
    _isCancelled = false;
    _stateController ??= StreamController<DownloadState>.broadcast();

    final uri = Uri.tryParse(urlString);
    if (uri == null || (!uri.isScheme('HTTP') && !uri.isScheme('HTTPS'))) {
      _updateState(_currentState.copyWith(
        status: DownloadStatus.failed,
        errorType: DownloadErrorType.invalidUrl,
        errorMessage: 'Invalid APK URL provided.',
      ));
      return;
    }

    _updateState(const DownloadState(
      status: DownloadStatus.downloading,
      progress: 0.0,
    ));

    try {
      // Check network connectivity first
      try {
        final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 4));
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw SocketException('No Internet');
        }
      } on SocketException catch (_) {
        _updateState(_currentState.copyWith(
          status: DownloadStatus.failed,
          errorType: DownloadErrorType.noInternet,
          errorMessage: 'No Internet connection. Please check your network and try again.',
        ));
        return;
      } on TimeoutException catch (_) {
        _updateState(_currentState.copyWith(
          status: DownloadStatus.failed,
          errorType: DownloadErrorType.noInternet,
          errorMessage: 'Connection timed out. Please check your network.',
        ));
        return;
      }

      _httpClient = http.Client();
      final request = http.Request('GET', uri);
      final response = await _httpClient!.send(request);

      if (response.statusCode != 200) {
        _updateState(_currentState.copyWith(
          status: DownloadStatus.failed,
          errorType: DownloadErrorType.downloadFailed,
          errorMessage: 'Server returned HTTP status code ${response.statusCode}.',
        ));
        return;
      }

      final totalBytes = response.contentLength ?? 0;

      // Temporary file location
      final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final saveFile = File('${dir.path}/app_update_latest.apk');

      if (await saveFile.exists()) {
        await saveFile.delete();
      }

      final sink = saveFile.openWrite();
      int downloadedBytes = 0;
      final startTime = DateTime.now();
      int lastTimestamp = startTime.millisecondsSinceEpoch;
      int lastBytes = 0;
      double currentSpeed = 0.0;

      await for (final chunk in response.stream) {
        if (_isCancelled) {
          await sink.close();
          if (await saveFile.exists()) {
            await saveFile.delete();
          }
          _updateState(_currentState.copyWith(
            status: DownloadStatus.cancelled,
          ));
          return;
        }

        downloadedBytes += chunk.length;
        sink.add(chunk);

        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final timeDiff = (nowMs - lastTimestamp) / 1000.0;

        if (timeDiff >= 0.5) {
          final bytesDiff = downloadedBytes - lastBytes;
          currentSpeed = bytesDiff / timeDiff;
          lastTimestamp = nowMs;
          lastBytes = downloadedBytes;
        }

        final double progress = totalBytes > 0 ? (downloadedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;
        final double remainingBytes = (totalBytes - downloadedBytes).toDouble();
        final double remainingSecs = currentSpeed > 0 ? (remainingBytes / currentSpeed) : 0.0;

        _updateState(_currentState.copyWith(
          status: DownloadStatus.downloading,
          progress: progress,
          downloadedBytes: downloadedBytes,
          totalBytes: totalBytes,
          speedBytesPerSec: currentSpeed,
          remainingSeconds: remainingSecs,
        ));
      }

      await sink.flush();
      await sink.close();

      _updateState(_currentState.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        downloadedBytes: totalBytes > 0 ? totalBytes : downloadedBytes,
        totalBytes: totalBytes > 0 ? totalBytes : downloadedBytes,
        filePath: saveFile.path,
      ));
    } catch (e) {
      if (_isCancelled) return;
      
      String msg = e.toString();
      DownloadErrorType errorType = DownloadErrorType.downloadFailed;
      
      if (e is SocketException) {
        errorType = DownloadErrorType.noInternet;
        msg = 'No Internet connection. Please try again.';
      } else if (e is FileSystemException) {
        errorType = DownloadErrorType.insufficientStorage;
        msg = 'Insufficient storage space or permission denied.';
      }

      _updateState(_currentState.copyWith(
        status: DownloadStatus.failed,
        errorType: errorType,
        errorMessage: msg,
      ));
    }
  }

  void cancelDownload() {
    _isCancelled = true;
    _httpClient?.close();
    _updateState(_currentState.copyWith(
      status: DownloadStatus.cancelled,
    ));
  }

  void reset() {
    _isCancelled = false;
    _updateState(const DownloadState());
  }

  void _updateState(DownloadState state) {
    _currentState = state;
    _stateController?.add(state);
  }

  void dispose() {
    _stateController?.close();
    _httpClient?.close();
  }
}
