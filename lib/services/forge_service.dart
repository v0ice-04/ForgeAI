import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/generation_model.dart';

class ForgeService {
  // Updated to use local Spring Boot backend
  static const String _baseUrl = 'http://localhost:8080';

  Future<GenerationResponse> generateApplication(
      GenerationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
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
}
