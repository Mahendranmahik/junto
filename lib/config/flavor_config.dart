/// Flavor configuration to detect the current build flavor at runtime
class FlavorConfig {
  static const String dev = 'dev';
  static const String prod = 'prod';

  static String currentFlavor = prod; // Default to prod

  static bool get isDev => currentFlavor == dev;
  static bool get isProd => currentFlavor == prod;

  static String get appTitle {
    return isDev ? 'Junto Dev' : 'Junto';
  }

  static String get packageName {
    return isDev ? 'com.junto.app.dev' : 'com.junto.app';
  }
}
