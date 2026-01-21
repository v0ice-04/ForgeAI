import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/generation_model.dart';
import '../config/api_config.dart';

/// Specialized service for handling generation-specific API calls.
/// Maps backend JSON responses to the [GenerationResponse] model.
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
  Future<GenerationResponse> getJobStatus(String jobId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.jobUrl(jobId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return GenerationResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to get job status. Status: ${response.statusCode}, '
            'Response: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching job status: $e');
    }
  }

  /// Poll the status of a project generation (Deprecated: Use getJobStatus)
  Future<GenerationResponse> getProjectStatus(String projectId) async {
    // Legacy support or redirects if needed
    return getJobStatus(
        projectId); // Assuming projectId might be treated as jobId in some contexts or this is unused
  }
}
