class AppLinks {
  // Deep link schemes
  static const String scheme = 'junto';
  static const String host = 'app.junto.com';

  // Deep link paths
  static const String jobDetail = '/job';
  static const String profile = '/profile';
  static const String chat = '/chat';

  /// Parse deep link URL
  static Map<String, String>? parseDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme == scheme || uri.host == host) {
        return {
          'path': uri.path,
          'query': uri.query,
        };
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}


