import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/error_handler.dart';

class NotificationService {
  final FirebaseMessaging _fcm;

  NotificationService({FirebaseMessaging? fcm})
      : _fcm = fcm ?? FirebaseMessaging.instance;

  /// Requests FCM permissions and retrieves device token
  Future<String?> initializeFcm() async {
    try {
      if (kIsWeb) return null;

      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await _fcm.getToken();
        debugPrint('FCM Device Token retrieved: $token');

        // Handle foreground notifications
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Foreground Message received: ${message.notification?.title}');
        });

        return token;
      }
      return null;
    } catch (e) {
      debugPrint('Non-fatal FCM initialization error: $e');
      return null;
    }
  }
}
