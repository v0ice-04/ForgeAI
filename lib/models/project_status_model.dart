/// Model for project status polling response
class ProjectStatusResponse {
  final String status; // "processing" | "completed" | "failed"
  final String? previewUrl;
  final String? zipUrl;
  final String? error;
  final double? progress; // Optional: 0.0 to 1.0

  ProjectStatusResponse({
    required this.status,
    this.previewUrl,
    this.zipUrl,
    this.error,
    this.progress,
  });

  factory ProjectStatusResponse.fromJson(Map<String, dynamic> json) {
    return ProjectStatusResponse(
      status: json['status'] as String? ?? 'processing',
      previewUrl: json['previewUrl'] as String?,
      zipUrl: json['zipUrl'] as String?,
      error: json['error'] as String?,
      progress: json['progress'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (previewUrl != null) 'previewUrl': previewUrl,
      if (zipUrl != null) 'zipUrl': zipUrl,
      if (error != null) 'error': error,
      if (progress != null) 'progress': progress,
    };
  }

  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
