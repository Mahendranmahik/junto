import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseHelper {
  /// Initialize Firebase services
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Log custom events
  static Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    // Add Firebase Analytics logging here if needed
    // await FirebaseAnalytics.instance.logEvent(
    //   name: name,
    //   parameters: parameters,
    // );
  }

  /// Log non-fatal errors
  static Future<void> logError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stackTrace,
      reason: reason,
    );
  }
}


