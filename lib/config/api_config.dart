/// Configuration class for API-related constants
class ApiConfig {
  /// The base URL for the backend API
  /// Publicly deployed URL: https://breakable-hedwig-bb121-194c7ef8.koyeb.app/
  static const String baseUrl =
      'https://breakable-hedwig-bb121-194c7ef8.koyeb.app';

  /// Endpoint for generating a project
  static const String generateEndpoint = '/api/generate';

  /// Get the full URL for the generate project endpoint
  static String get generateUrl => '$baseUrl$generateEndpoint';
}
