import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class InstallerService {
  static const MethodChannel _channel = MethodChannel('com.library.management/installer');

  /// Requests Android to install the APK file at [filePath].
  static Future<bool> installApk(String filePath) async {
    try {
      // First try native Android Intent via MethodChannel
      final bool success = await _channel.invokeMethod('installApk', {
        'filePath': filePath,
      });
      return success;
    } on PlatformException catch (_) {
      // Fallback via content/file URL launcher
      try {
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
      return false;
    } catch (_) {
      return false;
    }
  }
}
