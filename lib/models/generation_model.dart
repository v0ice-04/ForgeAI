class GenerationRequest {
  final String applicationType;
  final String projectName;
  final String description;
  final String category;
  final List<String> sections;
  final String themeColor;

  GenerationRequest({
    required this.applicationType,
    required this.projectName,
    required this.description,
    required this.category,
    required this.sections,
    required this.themeColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'description': description,
      'category': category,
      'sections': sections,
      // Note: applicationType and themeColor are not sent to backend
      // based on your API specification, but kept in model for UI use
    };
  }
}

/// Response from Spring Boot backend
class GenerationResponse {
  final bool success;
  final String message;
  final String projectId;

  GenerationResponse({
    required this.success,
    required this.message,
    required this.projectId,
  });

  factory GenerationResponse.fromJson(Map<String, dynamic> json) {
    return GenerationResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'projectId': projectId,
    };
  }
}
