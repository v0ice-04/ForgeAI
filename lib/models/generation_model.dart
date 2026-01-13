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

class GenerationResponse {
  final String? jobId;
  final String? projectId;
  final String status; // "QUEUED" | "PROCESSING" | "COMPLETED" | "FAILED"
  final String? message;
  final String? previewUrl;
  final String? zipUrl;
  final String? error;

  GenerationResponse({
    this.jobId,
    this.projectId,
    required this.status,
    this.message,
    this.previewUrl,
    this.zipUrl,
    this.error,
  });

  factory GenerationResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested result from backend GenerationJob
    final result = json['result'] as Map<String, dynamic>?;

    return GenerationResponse(
      jobId: json['jobId'] as String?,
      projectId: json['projectId'] as String? ?? result?['projectId'],
      status: json['status'] as String? ?? 'QUEUED',
      message: json['errorMessage'] as String? ?? result?['message'],
      previewUrl: result?['previewUrl'],
      zipUrl: result?['zipUrl'],
      error: json['errorMessage'] as String? ?? result?['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'projectId': projectId,
      'status': status,
      if (message != null) 'message': message,
      if (previewUrl != null) 'previewUrl': previewUrl,
      if (zipUrl != null) 'zipUrl': zipUrl,
      if (error != null) 'error': error,
    };
  }

  bool get isProcessing => status == 'QUEUED' || status == 'PROCESSING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
}
