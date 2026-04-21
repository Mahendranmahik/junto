import 'package:flutter/material.dart';
import 'package:junto/app.dart';
import 'package:junto/di/locator.dart';
import 'package:junto/firebase_helper.dart';
import 'package:junto/utils/flavor_detector.dart';
import 'package:junto/config/flavor_config.dart';
import 'package:junto/core/services/notification_service.dart';
import 'package:junto/core/services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect the current flavor (dev or prod)
  final detectedFlavor = await FlavorDetector.detectFlavor();

  // Set the current flavor in FlavorConfig
  FlavorConfig.currentFlavor = detectedFlavor;

  // Initialize Firebase with the correct configuration for the detected flavor
  await FirebaseHelper.initialize(flavor: detectedFlavor);
  await RemoteConfigService.instance.initialize();
  await setupLocator();
  await initializeNotifications();
  await setupFirebaseMessaging();

  runApp(const MyApp());
}
