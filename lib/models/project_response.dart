/// Model class for the project generation response
class ProjectResponse {
  final bool success;
  final String message;
  final String projectId;

  ProjectResponse({
    required this.success,
    required this.message,
    required this.projectId,
  });

  /// Create a ProjectResponse from JSON received from API
  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      projectId: json['projectId'] as String,
    );
  }

  /// Convert the model to JSON format (if needed for future use)
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'projectId': projectId,
    };
  }
}
