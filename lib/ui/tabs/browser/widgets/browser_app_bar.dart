import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/providers/browser_provider/browser_provider.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/tabs/browser/widgets/browser_url_field.dart';
import 'package:wallet_cryptomask/ui/shared/network_dart.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

class BrowserUrlBar extends StatefulWidget {
  final Function(String, BrowserProvider) onUrlSubmit;
  final bool? certified;
  final String url;
  final Function() openDrawer;
  final BrowserProvider webViewModel;
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
    context.read<BrowserProvider>().addListener(() {
      urlController.text = context.read<BrowserProvider>().url.toString();
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
      title: _buildSearchTextField(),
    );
  }

  Widget _buildSearchTextField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.more_vert,
          color: Colors.transparent,
        ),
        addWidth(SpacingSize.xs),
        Expanded(
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
                              ? "http://www.google.com"
                              : Uri.parse(urlController.text).authority,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NetworkDot(
                        color:
                            getWalletProvider(context).activeNetwork.dotColor,
                        radius: 10,
                      ),
                      addWidth(SpacingSize.xxs),
                      Text(
                        getWalletProvider(context).activeNetwork.networkName,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      addWidth(SpacingSize.xxs),
                      const NetworkDot(
                        color: Colors.transparent,
                        radius: 10,
                      ),
                    ],
                  ),
                ]),
          ),
        ),
        addWidth(SpacingSize.xs),
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () {
                context
                    .read<BrowserProvider>()
                    .webViewController
                    ?.webStorage
                    .localStorage
                    .clear();
              },
              child: const WalletText(
                localizeKey: 'clearBrowserStorage',
              ),
            )
          ],
          child: const Icon(
            Icons.more_vert,
            color: Colors.red,
          ),
        )
      ],
    );
  }
}
