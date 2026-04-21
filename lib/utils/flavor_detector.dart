import 'package:package_info_plus/package_info_plus.dart';
import 'package:junto/config/flavor_config.dart';

class FlavorDetector {
  /// Detect flavor from package name at runtime
  static Future<String> detectFlavor() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;

      // Check if package name contains '.dev' for dev flavor
      if (packageName.contains('.dev')) {
        return FlavorConfig.dev;
      }
      return FlavorConfig.prod;
    } catch (e) {
      // Fallback to environment variable or default to prod
      const String flavor = String.fromEnvironment(
        'FLAVOR',
        defaultValue: 'prod',
      );
      return flavor;
    }
  }
}
