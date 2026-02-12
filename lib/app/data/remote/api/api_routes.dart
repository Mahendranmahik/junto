class ApiRoutes {
  // Base URL
  static const String baseUrl = 'https://api.example.com/v1';

  // Auth routes
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Job routes
  static const String jobs = '/jobs';
  static String jobById(String id) => '/jobs/$id';
  static const String createJob = '/jobs';
  static String updateJob(String id) => '/jobs/$id';
  static String deleteJob(String id) => '/jobs/$id';

  // Customer routes
  static const String customers = '/customers';
  static String customerById(String id) => '/customers/$id';
}


