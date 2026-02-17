import 'package:flutter/material.dart';
import 'package:junto/app.dart';
import 'package:junto/di/locator.dart';
import 'package:junto/firebase_helper.dart';
import 'package:junto/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FirebaseHelper.initialize();
  await setupLocator();
  await initializeNotifications();
  await setupFirebaseMessaging();
  
  runApp(const MyApp());
}
