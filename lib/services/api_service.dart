import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/project_request.dart';
import '../models/project_response.dart';
import '../config/api_config.dart';

/// Singleton API service that persists beyond widget lifecycle.
/// This ensures HTTP requests survive navigation and widget disposal.
class ApiService {
  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  // Factory constructor returns the same instance
  factory ApiService() {
    return _instance;
  }

  // Private constructor
  ApiService._internal();

  Future<ProjectResponse> generateProject(ProjectRequest request) async {
    final startTime = DateTime.now();
    developer.log('🚀 API: Starting generation request', name: 'ApiService');

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/generate');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      final duration = DateTime.now().difference(startTime);
      developer.log(
          '✅ API: Generation request completed in ${duration.inSeconds}s',
          name: 'ApiService');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ProjectResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to generate project. Status: ${response.statusCode}, '
            'Response: ${response.body}');
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      developer.log(
          '❌ API: Generation request failed after ${duration.inSeconds}s: $e',
          name: 'ApiService');
      throw Exception('Error connecting to backend: $e');
    }
  }

  Future<ProjectResponse> editProject(String projectId, String message) async {
    final startTime = DateTime.now();
    developer.log('🚀 API: Starting edit request for project $projectId',
        name: 'ApiService');

    try {
      final url = Uri.parse(ApiConfig.editUrl(projectId));

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      final duration = DateTime.now().difference(startTime);
      developer.log('✅ API: Edit request completed in ${duration.inSeconds}s',
          name: 'ApiService');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ProjectResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to edit project. Status: ${response.statusCode}, '
            'Response: ${response.body}');
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      developer.log(
          '❌ API: Edit request failed after ${duration.inSeconds}s: $e',
          name: 'ApiService');
      throw Exception('Error connecting to backend: $e');
    }
  }
}
