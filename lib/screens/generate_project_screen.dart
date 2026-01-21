import 'package:flutter/material.dart';
import '../models/project_request.dart';
import '../services/api_service.dart';
import 'preview_screen.dart';

/// A simplified screen primarily used for testing the project generation API.
/// It provides a basic UI to trigger generation without the full form of HomeScreen.
class GenerateProjectScreen extends StatefulWidget {
  const GenerateProjectScreen({super.key});

  @override
  State<GenerateProjectScreen> createState() => _GenerateProjectScreenState();
}

class _GenerateProjectScreenState extends State<GenerateProjectScreen> {
  final ApiService _apiService = ApiService();

  // State variables
  bool _isLoading = false;
  String? _responseMessage;
  String? _projectId;
  String? _errorMessage;

  /// Handle the "Generate Project" button press
  Future<void> _generateProject() async {
    // Prevent duplicate requests
    if (_isLoading) return;

    // Clear previous results
    setState(() {
      _isLoading = true;
      _responseMessage = null;
      _projectId = null;
      _errorMessage = null;
    });

    // Create a sample request (you can modify this to use form inputs)
    final request = ProjectRequest(
      projectName: 'ForgeAI',
      description: 'AI generated website',
      category: 'Website',
      sections: ['Home', 'About'],
    );

    // Navigate to PreviewScreen IMMEDIATELY
    // This prevents the user from accidentally canceling the request
    if (mounted) {
      // Generate a temporary project ID for navigation
      final tempProjectId =
          'generating-${DateTime.now().millisecondsSinceEpoch}';

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewScreen(
            projectId: tempProjectId,
            isGenerating: true, // Pass flag to show loading state
          ),
        ),
      );
    }

    // Fire the API request in the background
    // The request will complete even if the user navigates away
    _apiService.generateProject(request).then((response) {
      // Update state with response (though user has already navigated away)
      if (mounted) {
        setState(() {
          _isLoading = false;
          _responseMessage = response.message;
          _projectId = response.projectId;
        });
      }

      // Note: The preview screen will handle showing the actual project
      // once generation completes
    }).catchError((e) {
      // Handle errors silently or show a snackbar
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ForgeAI - Project Generator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Logo/Title
            const Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'ForgeAI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI-Powered Project Generator',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),

            // Generate Button
            ElevatedButton(
              onPressed: _isLoading ? null : _generateProject,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Generate Project',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
            const SizedBox(height: 32),

            // Response Display
            if (_responseMessage != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Success!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Message: $_responseMessage',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Project ID: $_projectId',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Error Display
            if (_errorMessage != null) ...[
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
