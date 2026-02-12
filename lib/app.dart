import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:junto/core/routes/app_pages.dart';
import 'package:junto/core/routes/app_routes.dart';
import 'package:junto/app/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "chat now ",
      debugShowCheckedModeBanner: false,
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
      theme: AppTheme.darkTheme,
    );
  }

  String _getInitialRoute() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return Routes.HOME;
    } else {
      return Routes.LOGIN;
    }
  }
}
