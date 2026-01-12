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

  /// Get the preview URL for a project (always points to index.html)
  static String previewUrl(String projectId) =>
      '$baseUrl/api/projects/$projectId/preview/index.html';

  /// Get the edit endpoint for a project
  static String editUrl(String projectId) =>
      '$baseUrl/api/projects/$projectId/edit';

  /// Get the status endpoint for polling project generation status
  static String statusUrl(String projectId) =>
      '$baseUrl/api/project/$projectId/status';

  /// Get the download URL (ZIP) for a project
  static String downloadUrl(String projectId) =>
      '$baseUrl/api/projects/$projectId/download';
}
