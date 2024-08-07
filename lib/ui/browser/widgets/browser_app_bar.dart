import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/ui/browser/model/web_view_model.dart';
import 'package:wallet_cryptomask/ui/browser/widgets/browser_url_field.dart';
import 'package:wallet_cryptomask/ui/shared/network_dart.dart';

class BrowserUrlBar extends StatefulWidget {
  final Function(String, WebViewModel) onUrlSubmit;
  final bool? certified;
  final String url;
  final Function() openDrawer;
  final WebViewModel webViewModel;
  const BrowserUrlBar(
      {super.key,
      required this.webViewModel,
      required this.onUrlSubmit,
      required this.certified,
      required this.url,
      required this.openDrawer});

  @override
  State<BrowserUrlBar> createState() => _BrowserUrlBarState();
}

class _BrowserUrlBarState extends State<BrowserUrlBar> {
  String walletConnectURL = "";
  double actionContainerWidth = 0;
  FocusNode urFocusNode = FocusNode();
  bool enableClear = false;
  TextEditingController urlController = TextEditingController();
  bool showUrl = false;
  OutlineInputBorder outlineBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: BorderRadius.all(
      Radius.circular(50.0),
    ),
  );

  @override
  void initState() {
    context.read<WebViewModel>().addListener(() {
      urlController.text = context.read<WebViewModel>().url.toString();
      urFocusNode.addListener(() {
        setState(() {
          enableClear = urFocusNode.hasFocus;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      foregroundColor: kPrimaryColor,
      backgroundColor: Colors.white,
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        if (kDebugMode)
          IconButton(
              onPressed: () {
                context
                    .read<WebViewModel>()
                    .webViewController
                    ?.webStorage
                    .localStorage
                    .clear();
              },
              icon: const Icon(
                Icons.clear,
                color: Colors.red,
              ))
      ],
      title: _buildSearchTextField(),
    );
  }

  Widget _buildSearchTextField() {
    return SizedBox(
        // height: 40.0,
        child: GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BrowserUrlField(
              onUrlSubmit: widget.onUrlSubmit,
              webViewModel: widget.webViewModel,
              certified: widget.certified,
              url: widget.url),
        ));
      },
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                  color: kPrimaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 14,
                    color: Colors.green,
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Text(
                    urlController.text.toString().contains(
                            "file:///android_asset/flutter_assets/assets/html/homepage.html")
                        ? "home.egon.wallet"
                        : Uri.parse(urlController.text).authority,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                  ),
                  const Icon(
                    Icons.lock,
                    size: 14,
                    color: Colors.transparent,
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 2,
            ),

            // const SizedBox(height: 10,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NetworkDot(
                  color: getWalletProvider(context).activeNetwork.dotColor,
                  radius: 10,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  getWalletProvider(context).activeNetwork.networkName,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  width: 5,
                ),
                const NetworkDot(
                  color: Colors.transparent,
                  radius: 10,
                ),
              ],
            ),
          ]),
    ));
  }
}
