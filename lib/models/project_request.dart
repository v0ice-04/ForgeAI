/// Model class for the project generation request
class ProjectRequest {
  final String projectName;
  final String description;
  final String category;
  final List<String> sections;

  ProjectRequest({
    required this.projectName,
    required this.description,
    required this.category,
    required this.sections,
  });

  /// Convert the model to JSON format for API request
  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'description': description,
      'category': category,
      'sections': sections,
    };
  }

  /// Create a ProjectRequest from JSON (if needed for future use)
  factory ProjectRequest.fromJson(Map<String, dynamic> json) {
    return ProjectRequest(
      projectName: json['projectName'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      sections: List<String>.from(json['sections'] as List),
    );
  }
}
