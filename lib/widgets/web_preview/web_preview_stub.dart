import 'package:flutter/material.dart';

class WebPreviewPane extends StatelessWidget {
  final String url;
  const WebPreviewPane({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.web_asset_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Live preview is only available in Web version.\n\nOpen in browser:\n$url",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class WebPreviewWeb extends StatelessWidget {
  final String url;
  const WebPreviewWeb({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return const WebPreviewPane(url: '');
  }
}

class WebPreviewWithDownload extends StatelessWidget {
  final String url;
  final String zipUrl;

  const WebPreviewWithDownload({
    super.key,
    required this.url,
    required this.zipUrl,
  });

  @override
  Widget build(BuildContext context) {
    return const WebPreviewPane(url: '');
  }
}
