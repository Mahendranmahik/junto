import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:junto/config/firebase_config.dart';
import 'package:junto/config/flavor_config.dart';

class FirebaseHelper {
  /// Initialize Firebase services with flavor-specific configuration
  static Future<void> initialize({required String flavor}) async {
    // Set the current flavor
    FlavorConfig.currentFlavor = flavor;

    // Get the appropriate Firebase options based on flavor
    final firebaseOptions = FirebaseConfig.getOptions(flavor: flavor);

    // Initialize Firebase with flavor-specific configuration
    await Firebase.initializeApp(options: firebaseOptions);

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Log custom events
  static Future<void> logEvent(
    String name,
    Map<String, dynamic>? parameters,
  ) async {
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
