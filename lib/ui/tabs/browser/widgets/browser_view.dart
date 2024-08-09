// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/route_manager.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/providers/browser_provider/browser_provider.dart';

class BrowserView extends StatefulWidget {
  final BrowserProvider webViewModel;
  final Function(String, BrowserProvider) onUrlSubmit;

  const BrowserView(
      {super.key, required this.webViewModel, required this.onUrlSubmit});

  @override
  State<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  InAppWebViewController? webViewController;
  double progress = 0;
  double progressFactor = 0;
  bool? certified;
  PullToRefreshController? pullToRefreshController;
  bool showHomeButton = false;
  bool showBrowser = true;
  WebUri? url;
  bool dissableProgressAnimation = false;
  bool isAttached = false;
  PullToRefreshController refreshController = PullToRefreshController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InAppWebView(
            initialSettings: InAppWebViewSettings(
                domStorageEnabled: true,
                allowFileAccess: true,
                useShouldOverrideUrlLoading: true,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true),
            onWebViewCreated: (controller) async {
              webViewController = controller;
              widget.webViewModel.webViewController = controller;
              loadHomepage();
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              log("HTTP ERROR OCCURED ===> ${errorResponse.statusCode}");
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              if (navigationAction.request.url.toString().contains("wc:")) {
                handleRequestToWalletConnect(
                    context, navigationAction.request.url!.uriValue);
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedError: (controller, request, error) {},
            onLoadStart: (controller, url) async {
              // checkRequestIsWalletConnect(url);
              var favIcons = await webViewController?.getFavicons();
              if (favIcons != null && favIcons.isNotEmpty) {
                widget.webViewModel.favicon = favIcons[0];
              }
              isAttached = false;
              widget.webViewModel.url = await controller.getUrl();
              setState(() {
                progress = 0.0;
                dissableProgressAnimation = false;
              });
              progressFactor = MediaQuery.of(context).size.width / 100;
              if (url != null && url.scheme == "https") {
                widget.webViewModel.isSecure = true;
              } else {
                widget.webViewModel.isSecure = false;
              }
              widget.webViewModel.webViewController = controller;
              setState(() {});
            },
            onProgressChanged: (controller, progress) async {
              widget.webViewModel.progress =
                  double.parse(progress.toString()) * progressFactor;
              this.progress =
                  double.parse(progress.toString()) * progressFactor;
              if (progress == 100) {
                widget.webViewModel.title =
                    await widget.webViewModel.webViewController?.getTitle() ??
                        "New page";
              }
              setState(() {});
            },
            onLoadStop: (controller, url) async {
              log(url.toString());
            },
          ),
        ),
        Container(
          width: progress,
          height: 2,
          color: kPrimaryColor,
        )
      ],
    );
  }

  void loadHomepage() async {
    widget.webViewModel.webViewController?.loadUrl(
        urlRequest:
            URLRequest(url: WebUri(dotenv.env['BROWSER_HOMEPAGE'] ?? "")));
  }
}

void handleRequestToWalletConnect(BuildContext context, url) async {
  if (url.queryParameters["symKey"] != null) {
    try {
      await getWalletProvider(context).web3Wallet!.pair(uri: url);
    } catch (e) {
      Get.dialog(AlertDialog(
        title: const Text("Error in connection"),
        content: Text(e.toString()),
      ));
    }
  }
}
