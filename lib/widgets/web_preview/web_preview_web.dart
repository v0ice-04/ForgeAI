// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class WebPreviewPane extends StatefulWidget {
  final String url;
  const WebPreviewPane({super.key, required this.url});

  @override
  State<WebPreviewPane> createState() => _WebPreviewPaneState();
}

class _WebPreviewPaneState extends State<WebPreviewPane> {
  late final String viewId;

  @override
  void initState() {
    super.initState();

    viewId = "iframe-${DateTime.now().millisecondsSinceEpoch}";

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final iframe = html.IFrameElement()
        ..src = widget.url
        ..style.border = "none"
        ..style.width = "100%"
        ..style.height = "100%"
        ..allow =
            "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        ..allowFullscreen = true;
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      key: ValueKey(viewId),
      viewType: viewId,
    );
  }
}
