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

/// Response from Spring Boot backend (async job)
class GenerationResponse {
  final String projectId;
  final String status; // "processing" | "completed" | "failed"
  final String? message;
  final String? previewUrl;
  final String? zipUrl;
  final String? error;

  GenerationResponse({
    required this.projectId,
    required this.status,
    this.message,
    this.previewUrl,
    this.zipUrl,
    this.error,
  });

  factory GenerationResponse.fromJson(Map<String, dynamic> json) {
    return GenerationResponse(
      projectId: json['projectId'] as String? ?? '',
      status: json['status'] as String? ?? 'processing',
      message: json['message'] as String?,
      previewUrl: json['previewUrl'] as String?,
      zipUrl: json['zipUrl'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'status': status,
      if (message != null) 'message': message,
      if (previewUrl != null) 'previewUrl': previewUrl,
      if (zipUrl != null) 'zipUrl': zipUrl,
      if (error != null) 'error': error,
    };
  }

  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
