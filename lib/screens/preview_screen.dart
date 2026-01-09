import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../widgets/web_preview/web_preview_pane.dart';

class PreviewScreen extends StatefulWidget {
  final String projectId;

  const PreviewScreen({super.key, required this.projectId});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ApiService _apiService = ApiService();
  bool _isRegenerating = false;

  // Track refresh state for the preview iframe
  Key _previewKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'text':
          'Welcome! Your project has been generated. How can I help you refine it?',
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

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _chatController.clear();
      _isRegenerating = true;
    });

    try {
      await _apiService.editProject(widget.projectId, text);

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
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: Text(
          'FORGE AI EDITOR: ${widget.projectId.substring(0, 8).toUpperCase()}',
          style: const TextStyle(
            color: Color(0xFF00F0FF),
            letterSpacing: 2.0,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1F35),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00F0FF)),
            onPressed: _refreshPreview,
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel: Chat / Prompt UI (30%)
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Color(0xFF1A1F35),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Chat Messages
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg['role'] == 'user';
                        return _buildChatBubble(msg['text'] ?? '', isUser);
                      },
                    ),
                  ),

                  // Chat Input
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFF1A1F35),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ask AI to edit...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: const Color(0xFF0A0E17),
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00F0FF), Color(0xFF7000FF)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Panel: Live Preview (iframe) (70%)
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                WebPreviewWithDownload(
                  key: _previewKey,
                  url: ApiConfig.previewUrl(widget.projectId),
                  zipUrl: ApiConfig.downloadUrl(widget.projectId),
                ),
                if (_isRegenerating)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF00F0FF),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'AI IS REFORGING...',
                            style: TextStyle(
                              color: const Color(0xFF00F0FF),
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color:
                                      const Color(0xFF00F0FF).withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF7000FF) : const Color(0xFF1A1F35),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          border: isUser
              ? null
              : Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
