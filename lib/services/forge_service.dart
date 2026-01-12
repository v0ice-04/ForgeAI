import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/generation_model.dart';
import '../models/project_status_model.dart';
import '../config/api_config.dart';

class ForgeService {
  Future<GenerationResponse> generateApplication(
      GenerationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return GenerationResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to generate application. Status: ${response.statusCode}, '
            'Response: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to ForgeAI backend: $e');
    }
  }

  /// Poll the status of a project generation
  Future<ProjectStatusResponse> getProjectStatus(String projectId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.statusUrl(projectId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ProjectStatusResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to get project status. Status: ${response.statusCode}, '
            'Response: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching project status: $e');
    }
  }
}
