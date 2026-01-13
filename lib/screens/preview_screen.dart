import 'dart:async'; // Added for Timer
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../services/api_service.dart';
import '../services/forge_service.dart'; // Added for pollProjectStatus
import '../config/api_config.dart';
import '../widgets/web_preview/web_preview_pane.dart';

class PreviewScreen extends StatefulWidget {
  final String? projectId;
  final String? jobId;
  final bool isGenerating;

  const PreviewScreen({
    super.key,
    this.projectId,
    this.jobId,
    this.isGenerating = false,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ApiService _apiService = ApiService();
  final ForgeService _forgeService = ForgeService();

  bool _isRegenerating = false;
  bool _isInitialGeneration = false;
  String? _generationError;
  Timer? _pollTimer;
  String? _currentProjectId;

  // Track refresh state for the preview iframe
  Key _previewKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _currentProjectId = widget.projectId;

    // Set initial state based on whether we're generating
    if (widget.isGenerating || widget.jobId != null) {
      _isInitialGeneration = true;
      _messages.add({
        'role': 'assistant',
        'text': 'Generating your project... This may take a moment.',
      });
      _startPolling();
    } else {
      _messages.add({
        'role': 'assistant',
        'text':
            'Welcome! Your project has been generated. How can I help you refine it?',
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _chatController.dispose();
    super.dispose();
  }

  void _startPolling() {
    if (widget.jobId == null && widget.projectId == null) {
      setState(() {
        _generationError = "No Job ID or Project ID provided.";
        _isInitialGeneration = false;
      });
      return;
    }

    // Poll every 2 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        // If we have a Job ID, check job status.
        // If only Project ID, assume we aren't generating anymore or use legacy status (which we mapped to job status in service, but that might fail if ID formats differ).
        // New flow uses Job ID.
        if (widget.jobId != null) {
          final status = await _forgeService.getJobStatus(widget.jobId!);

          if (!mounted) return;

          if (status.isCompleted) {
            timer.cancel();
            setState(() {
              _isInitialGeneration = false;
              _currentProjectId = status.projectId;
              _messages.add({
                'role': 'assistant',
                'text': 'Project generated successfully! displaying preview...',
              });
              _refreshPreview();
            });
          } else if (status.isFailed) {
            timer.cancel();
            setState(() {
              _isInitialGeneration = false;
              _generationError = status.error ?? 'Unknown error occurred';
              _messages.add({
                'role': 'assistant',
                'text': 'Generation failed: $_generationError',
              });
            });
          }
        } else {
          // Legacy/Direct mode - if we have projectId but flag says generating?
          // We shouldn't be here in new flow. Stop polling.
          timer.cancel();
          setState(() => _isInitialGeneration = false);
        }
      } catch (e) {
        // Log error but continue polling (network glitches happen)
        print('Polling error: $e');
      }
    });
  }

  void _refreshPreview() {
    setState(() {
      _previewKey = UniqueKey();
    });
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    // Ensure we have a project ID before editing
    if (_currentProjectId == null) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _chatController.clear();
      _isRegenerating = true;
    });

    try {
      await _apiService.editProject(_currentProjectId!, text);

      // Successfully regenerated
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'Changes applied! Refreshing preview...',
        });
        _isRegenerating = false;
        _refreshPreview(); // Force iframe reload
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'Error applying changes: $e',
        });
        _isRegenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF00F0FF), size: 20),
            const SizedBox(width: 12),
            Text(
              'FORGE AI EDITOR',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 1.2,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'Project: ${_currentProjectId != null && _currentProjectId!.length >= 8 ? _currentProjectId!.substring(0, 8).toUpperCase() : "..."}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel: Chat / Prompt UI
          SizedBox(
            width: 380,
            child: Column(
              children: [
                // Chat Messages
                Expanded(
                  child: Container(
                    color: const Color(0xFF0F172A),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg['role'] == 'user';
                        return _buildChatBubble(msg['text'] ?? '', isUser);
                      },
                    ),
                  ),
                ),

                // Chat Input box at bottom
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    border: Border(
                      top: BorderSide(color: Color(0xFF334155), width: 1),
                    ),
                  ),
                  child: Card(
                    elevation: 4,
                    color: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Ask AI to edit...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send_rounded,
                                color: Color(0xFF00F0FF)),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Vertical Divider
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFF334155),
          ),

          // Right Panel: Live Preview
          Expanded(
            child: Container(
              color: const Color(0xFFF5F6FA), // Neutral workspace background
              child: Column(
                children: [
                  // Browser-like Toolbar
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.language,
                            size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Live Website Preview',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        _buildToolbarButton(
                          icon: Icons.refresh_rounded,
                          tooltip: 'Refresh',
                          onPressed: _refreshPreview,
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _currentProjectId == null
                              ? null
                              : () {
                                  web.window.open(
                                      ApiConfig.previewUrl(_currentProjectId!),
                                      '_blank');
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF334155),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.open_in_new, size: 14),
                          label: const Text('',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _currentProjectId == null
                              ? null
                              : () {
                                  web.window.open(
                                      ApiConfig.downloadUrl(_currentProjectId!),
                                      '_blank');
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Export',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  // Preview Content (The "Card" Container)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Stack(
                            children: [
                              if (_isInitialGeneration)
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(
                                        color: Color(0xFF00F0FF),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'FORGING PROJECT...',
                                        style: TextStyle(
                                          color: const Color(0xFF1E293B)
                                              .withOpacity(0.8),
                                          letterSpacing: 3.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (_generationError != null)
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Colors.red, size: 48),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Generation Failed',
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _generationError!,
                                        style: const TextStyle(
                                            color: Colors.black54),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              else if (_currentProjectId != null)
                                WebPreviewWeb(
                                  key: _previewKey,
                                  url: ApiConfig.previewUrl(_currentProjectId!),
                                )
                              else
                                const Center(
                                    child: Text("Waiting for Project ID...")),

                              // Overlay for regeneration (editing)
                              if (_isRegenerating)
                                Container(
                                  color: Colors.black.withOpacity(0.4),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircularProgressIndicator(
                                          color: Color(0xFF00F0FF),
                                          strokeWidth: 3,
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E293B),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'REGENERATING...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              letterSpacing: 1.5,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            if (isUser)
              BoxShadow(
                color: const Color(0xFF4F46E5).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
