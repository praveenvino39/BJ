import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlockWebView extends StatefulWidget {
  static const router = "block_web_view";
  final String url;
  final String title;
  final bool isTransaction;

  const BlockWebView(
      {Key? key,
      required this.url,
      required this.title,
      this.isTransaction = false})
      : super(key: key);

  @override
  State<BlockWebView> createState() => _BlockWebViewState();
}

class _BlockWebViewState extends State<BlockWebView> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    log(widget.url);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon:const  Icon(
              Icons.arrow_back,
              color: kPrimaryColor,
            )),
        elevation: 1,
        shadowColor: Colors.white,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () => shareBlockViewerUrl(widget.url),
              icon: const Icon(
                Icons.share,
                color: kPrimaryColor,
              ))
        ],
        title: Center(
          child: Text(
            widget.isTransaction ? "Transaction History" : "${widget.title} Explorer",
            style: const TextStyle(color: kPrimaryColor, fontSize: 16),
          ),
        ),
      ),
      body: WebView(
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        onPageFinished: (url) =>
            widget.isTransaction ? _controller.scrollTo(0, 1800) : {},
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

class BlockWebViewArg {
  String title;
  String url;
  bool isTransaction;
  BlockWebViewArg(
      {required this.title, required this.url, this.isTransaction = false});

  static BlockWebViewArg fromObject(Object arguments) {
    return BlockWebViewArg(
      title: (arguments as dynamic)["title"],
      url: (arguments as dynamic)["url"],
      isTransaction:
          (arguments as dynamic)["isTransaction"] != null ? true : false,
    );
  }
}
