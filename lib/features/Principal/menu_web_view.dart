import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewSection extends StatefulWidget {
  final WebViewController controller;

  const WebViewSection({super.key, required this.controller});

  @override
  State<WebViewSection> createState() => _WebViewSectionState();
}

class _WebViewSectionState extends State<WebViewSection> {
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: WebViewWidget(controller: widget.controller),
    );
  }
}
