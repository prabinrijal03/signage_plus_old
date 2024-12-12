import 'package:flutter/material.dart';
// import 'package:slashplus/core/dependency_injection.dart';
import 'package:webview_flutter/webview_flutter.dart';

// import '../../../core/network/internet_checker.dart';

class LinkPreviewWidget extends StatefulWidget {
  final String url;
  final bool isPortrait;

  const LinkPreviewWidget(this.url, {super.key, required this.isPortrait});

  @override
  State<LinkPreviewWidget> createState() => _LinkPreviewWidgetState();
}

class _LinkPreviewWidgetState extends State<LinkPreviewWidget> {
  late WebViewController _controller;
  // late bool isConnected;
  @override
  void initState() {
    super.initState();
    // checkConnection();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(widget.url),
      );

    if (!widget.isPortrait) {
      _controller.setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.0.0 Safari/537.36");
    }
  }

  void checkConnection() async {
    // isConnected = await getInstance<NetworkInfoImpl>().isConnected;
  }

  @override
  Widget build(BuildContext context) {
    return
        // isConnected ?
        WebViewWidget(controller: _controller);
    // : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    //     Icon(Icons.wifi_off, color: Colors.red),
    //     Text("No internet connection", style: TextStyle(color: Colors.white)),
    //   ]);
  }
}
