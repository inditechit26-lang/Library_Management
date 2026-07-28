import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initializes all required Firebase services safely
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase Core safely
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configure Firestore Settings with Offline Persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Initialize App Check (Debug provider for dev mode)
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: kDebugMode
              ? AndroidProvider.debug
              : AndroidProvider.playIntegrity,
          appleProvider: kDebugMode
              ? AppleProvider.debug
              : AppleProvider.deviceCheck,
        );
      } catch (e) {
        debugPrint('App Check initialization non-fatal warning: $e');
      }

      // Initialize Crashlytics
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(!kDebugMode);
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }

      _initialized = true;
      debugPrint('Firebase successfully initialized with offline persistence.');
    } catch (e, stack) {
      debugPrint('Firebase initialize warning / fallback: $e');
      if (kDebugMode) {
        debugPrint(stack.toString());
      }
    }
  }

  /// Analytics instance helper
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  /// Firestore instance helper
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
