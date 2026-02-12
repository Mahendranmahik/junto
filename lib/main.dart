import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:junto/app.dart';
import 'package:junto/di/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setupLocator();
  runApp(const MyApp());
}
