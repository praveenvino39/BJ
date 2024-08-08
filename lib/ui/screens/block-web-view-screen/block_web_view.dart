import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

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
  @override
  Widget build(BuildContext context) {
    log(widget.url);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
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
          child: WalletText(
              localizeKey: widget.isTransaction
                  ? 'transactionHistory'
                  : "${widget.title} ${getText(context, key: 'explorer')}",
              color: kPrimaryColor,
              size: 16),
        ),
      ),
      body: InAppWebView(
          initialUrlRequest: URLRequest(
        url: WebUri(widget.url),
      )),
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
