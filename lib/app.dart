import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:junto/core/routes/app_pages.dart';
import 'package:junto/core/routes/app_routes.dart';
import 'package:junto/app/core/theme/app_theme.dart';
import 'package:junto/config/flavor_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: FlavorConfig.appTitle,
      debugShowCheckedModeBanner: false,
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
      theme: AppTheme.darkTheme,
    );
  }

  String _getInitialRoute() {
    return Routes.SPLASH;
  }
}
