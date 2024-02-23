// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/route_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/cubit_helper.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/core/web3wallet_service.dart';
import 'package:wallet_cryptomask/ui/browser/model/web_view_model.dart';
import 'package:wallet_cryptomask/ui/browser/widgets/browser_url_field.dart';
import 'package:wallet_cryptomask/ui/dapp_widgets/dapp_resolver.dart';

class BrowserView extends StatefulWidget {
  final WebViewModel webViewModel;
  final Function(String, WebViewModel) onUrlSubmit;

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
  WC2Service web3service =
      GetIt.I<WC2Service>(instanceName: walletConnectSingleTon);

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
    return BlocListener<WalletCubit, WalletState>(
      listener: (context, state) async {
        if (state is WalletNetworkChanged) {
          web3service.initHandlers(
              getWalletLoadedState(context).currentNetwork.nameSpace,
              state.currentNetwork.chainId.toString());
          webViewController?.postWebMessage(
              message: WebMessage(
                data: jsonEncode({
                  "method": "wallet_networkChanged",
                  "data": {
                    "rpc": state.currentNetwork.url,
                    "chainId": state.currentNetwork.chainId
                  }
                }),
              ),
              targetOrigin: WebUri("*"));
        }
        if (state is WalletAccountChanged) {
          webViewController?.postWebMessage(
              message: WebMessage(
                data: jsonEncode({
                  "method": "wallet_accountChanged",
                  "data": state.wallet.privateKey.address.hex
                }),
              ),
              targetOrigin: WebUri("*"));
        }
      },
      child: Column(
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
                      navigationAction.request.url!.uriValue);
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
                await attachWalletHandler();
                widget.webViewModel.progress =
                    double.parse(progress.toString()) * progressFactor;
                this.progress =
                    double.parse(progress.toString()) * progressFactor;
                if (progress == 100) {
                  // widget.webViewModel.webViewController
                  //     ?.evaluateJavascript(source: "localStorage.clear()");
                  widget.webViewModel.title =
                      await widget.webViewModel.webViewController?.getTitle() ??
                          "New page";
                }
                log("PAGE LOADING =====> ");
                setState(() {});
              },
              onLoadStop: (controller, url) async {
                log(url.toString());
              },
              // initialUrlRequest: URLRequest(url: widget.webViewModel.url),
            ),
          ),
          Container(
            width: progress,
            height: 2,
            color: kPrimaryColor,
          )
        ],
      ),
    );
  }

  attachWalletHandler() async {
    log("DAPP REQUEST ====> $isAttached");
    await widget.webViewModel.webViewController?.evaluateJavascript(
        source:
            'window.rpc = "${getWalletLoadedState(context).currentNetwork.url}"',
        contentWorld: ContentWorld.PAGE);
    await widget.webViewModel.webViewController?.evaluateJavascript(
        source:
            'window.chainId = ${getWalletLoadedState(context).currentNetwork.chainId}',
        contentWorld: ContentWorld.PAGE);

    webViewController?.injectJavascriptFileFromAsset(
        assetFilePath: "assets/provider/provider.js");
    Box box = await Hive.openBox("user_preference");
    DappResolver dappResolver = DappResolver(box: box);
    widget.webViewModel.webViewController?.addJavaScriptHandler(
        handlerName: 'wallet',
        callback: (args) async {
          var request = args[0];
          if (request == "metamask_showAutocomplete") {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BrowserUrlField(
                  onUrlSubmit: widget.onUrlSubmit,
                  webViewModel: widget.webViewModel,
                  certified: certified,
                  url: url?.toString() ?? ""),
            ));
          }
          if (request == "open_url_bar") {
            log("console from dart =====> ${args[0]}");
            widget.onUrlSubmit(args[1], widget.webViewModel);
            return null;
          }
          if (walletMethods.contains(request["method"])) {
            try {
              dynamic result = await dappResolver.processRequest(request,
                  context: context, webViewModel: widget.webViewModel);
              return jsonEncode(result);
            } catch (e) {
              return jsonEncode({
                "method": request["method"],
                "data": {
                  "code": 4001,
                  "message": "Request rejected by user",
                  "name": 'User Rejected Request'
                }
              });
            }
          } else {
            var repsonse = await callBlockChain(
                request, getWalletLoadedState(context).currentNetwork.url);
            return jsonEncode(repsonse["result"]);
          }
        });
  }

  void loadHomepage() async {
    widget.webViewModel.webViewController
        ?.loadUrl(urlRequest: URLRequest(url: WebUri(homepageUrl)));
  }

  void handleRequestToWalletConnect(Uri url) async {
    if (url.queryParameters["symKey"] != null) {
      try {
        await web3service.web3Wallet!.pair(uri: url);
      } catch (e) {
        Get.dialog(AlertDialog(
          title: const Text("Error in connection"),
          content: Text(e.toString()),
        ));
      }
    }
  }
}
