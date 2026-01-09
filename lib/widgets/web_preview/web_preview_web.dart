// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class WebPreviewWeb extends StatelessWidget {
  final String url;

  WebPreviewWeb({super.key, required this.url}) {
    ui.platformViewRegistry.registerViewFactory(
      'preview-iframe',
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: 'preview-iframe');
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
    return Stack(
      children: [
        WebPreviewWeb(url: url),
        Positioned(
          top: 16,
          right: 16,
          child: ElevatedButton.icon(
            onPressed: () {
              html.window.open(zipUrl, '_blank');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.download),
            label: const Text(
              'Download',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
