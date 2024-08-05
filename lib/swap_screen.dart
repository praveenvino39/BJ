import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SwapScreenUniswap extends StatefulWidget {
  const SwapScreenUniswap({super.key});

  @override
  State<SwapScreenUniswap> createState() => _SwapScreenUniswapState();
}

class _SwapScreenUniswapState extends State<SwapScreenUniswap> {
  bool started = false;

  @override
  void initState() {
    super.initState();
    startServer();
  }

  void startServer() async {
    await InAppLocalhostServer(
            port: 4001,
            documentRoot: 'assets/swap',
            shared: true,
            directoryIndex: "index.html")
        .start();
    setState(() {
      started = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: started
            ? InAppWebView(
                onReceivedError: (controller, request, error) {
                  log(error.description);
                },
                initialUrlRequest: URLRequest(
                    url: WebUri.uri(
                        Uri.parse("http://localhost:4001/index.html"))),
              )
            : const Center(
                child: Text("Starting server"),
              ));
  }
}
