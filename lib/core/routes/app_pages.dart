import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:junto/core/routes/app_routes.dart';
import 'package:junto/modules/auth/bindings/auth_binding.dart';
import 'package:junto/modules/auth/views/login_view.dart';
import 'package:junto/modules/chat/bindings/chat_binding.dart';
import 'package:junto/modules/chat/views/chat_view.dart';
import 'package:junto/modules/home/bindings/home_binding.dart';
import 'package:junto/modules/home/views/home_view.dart';
import 'package:junto/modules/settings/bindings/settings_binding.dart';
import 'package:junto/modules/settings/views/settings_view.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
