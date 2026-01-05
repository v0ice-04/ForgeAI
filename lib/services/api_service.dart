import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_request.dart';
import '../models/project_response.dart';
import '../config/api_config.dart';

class ApiService {
  Future<ProjectResponse> generateProject(ProjectRequest request) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/generate');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ProjectResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to generate project. Status: ${response.statusCode}, '
            'Response: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }
}
