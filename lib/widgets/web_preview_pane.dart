import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

/// A widget that renders a web preview using an <iframe> via HtmlElementView.
/// This is specifically designed for Flutter Web.
class WebPreviewPane extends StatefulWidget {
  final String previewUrl;

  const WebPreviewPane({super.key, required this.previewUrl});

  @override
  State<WebPreviewPane> createState() => _WebPreviewPaneState();
}

class _WebPreviewPaneState extends State<WebPreviewPane> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _registerFactory();
  }

  @override
  void didUpdateWidget(WebPreviewPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.previewUrl != widget.previewUrl) {
      _registerFactory();
    }
  }

  void _registerFactory() {
    // Generate a unique view ID based on the URL to ensure it reloads correctly
    _viewId =
        'iframe-${widget.previewUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = widget.previewUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow =
              "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          ..allowFullscreen = true;
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      key: ValueKey(_viewId),
      viewType: _viewId,
    );
  }
}
