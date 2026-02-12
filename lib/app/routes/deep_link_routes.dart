import 'package:get/get.dart';
import 'app_links.dart';
import 'app_routes.dart';

class DeepLinkRoutes {
  /// Handle deep link navigation
  static void handleDeepLink(String url) {
    final parsed = AppLinks.parseDeepLink(url);
    if (parsed == null) return;

    final path = parsed['path'];
    final query = parsed['query'];

    switch (path) {
      case AppLinks.jobDetail:
        // Navigate to job detail with query params
        Get.toNamed(AppRoutes.jobDetail, arguments: query);
        break;
      case AppLinks.profile:
        Get.toNamed(AppRoutes.profile);
        break;
      case AppLinks.chat:
        Get.toNamed(AppRoutes.chat);
        break;
      default:
        Get.toNamed(AppRoutes.home);
    }
  }
}


