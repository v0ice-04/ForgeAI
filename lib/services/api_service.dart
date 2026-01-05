import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_request.dart';
import '../models/project_response.dart';

/// Service class to handle API communication with the backend
class ApiService {
  // Configurable base URL - change this if your backend runs on a different host/port
  static const String baseUrl = 'http://localhost:8080';

  /// Send a POST request to generate a project
  ///
  /// Takes a [ProjectRequest] object and returns a [ProjectResponse]
  /// Throws an exception if the request fails
  Future<ProjectResponse> generateProject(ProjectRequest request) async {
    try {
      // Construct the full API endpoint URL
      final url = Uri.parse('$baseUrl/api/generate');

      // Make the POST request with JSON body
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      // Check if the request was successful (status code 200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse the JSON response
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ProjectResponse.fromJson(jsonData);
      } else {
        // Handle error responses from the server
        throw Exception(
            'Failed to generate project. Status code: ${response.statusCode}, '
            'Response: ${response.body}');
      }
    } catch (e) {
      // Re-throw the exception with more context
      throw Exception('Error connecting to backend: $e');
    }
  }
}
