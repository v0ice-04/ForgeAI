import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/project_request.dart';
import '../models/project_response.dart';

/// A service class to handle project generation API calls.
///
/// This class follows clean architecture principles and provides
/// a reusable way to interact with the ForgeAI backend.
class GenerateService {
  final http.Client _client;

  /// Constructor with an optional http client for dependency injection (useful for testing)
  GenerateService({http.Client? client}) : _client = client ?? http.Client();

  /// Synchronously sends a POST request to generate a project.
  ///
  /// Takes a [ProjectRequest] and returns a [ProjectResponse].
  /// Throws an exception with a descriptive message if the request fails.
  Future<ProjectResponse> generateProject(ProjectRequest request) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConfig.generateUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on http.ClientException catch (e) {
      throw Exception('Network error occurred: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Handles the HTTP response and parses it into a [ProjectResponse].
  ProjectResponse _handleResponse(http.Response response) {
    // Check for successful status codes (2xx)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProjectResponse.fromJson(data);
      } catch (e) {
        throw Exception('Failed to parse response data: $e');
      }
    } else {
      // Handle non-200 responses
      String errorMessage = 'Server error (${response.statusCode})';
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }
      } catch (_) {
        // Fallback to default if body isn't JSON
      }
      throw Exception(errorMessage);
    }
  }

  /// Closes the client when the service is no longer needed.
  void dispose() {
    _client.close();
  }
}
