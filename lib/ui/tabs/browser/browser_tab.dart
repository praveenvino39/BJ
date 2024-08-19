// ignore_for_file: deprecated_member_use, must_be_immutable

import 'dart:developer';
import 'dart:io';

import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/core/providers/browser_provider/browser_provider.dart';
import 'package:wallet_cryptomask/ui/tabs/browser/widgets/browser_app_bar.dart';
import 'package:wallet_cryptomask/ui/tabs/browser/widgets/browser_tab_view.dart';
import 'package:wallet_cryptomask/ui/tabs/browser/widgets/browser_view.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';
import 'package:webview_flutter/webview_flutter.dart' as native;

class BrowserTab extends StatefulWidget {
  static const route = "browser_screen";
  int index;
  BrowserTab({super.key, required this.index});

  @override
  State<BrowserTab> createState() => _BrowserTabState();
}

class _BrowserTabState extends State<BrowserTab> with ClipboardListener {
  native.WebViewController? webViewController_;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;
  double progressFactor = 0;
  bool? certified;
  PullToRefreshController? pullToRefreshController;
  WebUri homePage = WebUri(dotenv.env['BROWSER_HOMEPAGE'] ?? "");
  bool showHomeButton = false;
  bool showBrowser = true;
  List<BrowserView> tabs = [];
  Widget? selectedTab;
  int homeIndex = 0;
  int selectedIndex = 0;
  String currentPage = dotenv.env['BROWSER_HOMEPAGE'] ?? "";

  OutlineInputBorder outlineBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: BorderRadius.all(
      Radius.circular(50.0),
    ),
  );

  gotoHome() {
    (selectedTab as BrowserView)
        .webViewModel
        .webViewController
        ?.loadUrl(urlRequest: URLRequest(url: homePage));
  }

  reloadPage() {
    (selectedTab as BrowserView).webViewModel.webViewController?.loadUrl(
        urlRequest:
            URLRequest(url: (selectedTab as BrowserView).webViewModel.url));
  }

  clearCache() {
    (selectedTab as BrowserView)
        .webViewModel
        .webViewController
        ?.webStorage
        .localStorage
        .clear();
  }

  @override
  void initState() {
    if (Platform.isIOS) {
      clipboardWatcher.addListener(this);
      clipboardWatcher.start();
    }

    tabs.add(BrowserView(
        webViewModel: BrowserProvider(
            progress: 0, url: WebUri(dotenv.env['BROWSER_HOMEPAGE'] ?? "")),
        onUrlSubmit: onUrlSumbit));

    selectedTab = tabs.first;
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
    setState(() {});
    super.initState();
  }

  createNewTab() {
    log("CREATING NEW TAB");
    log(tabs.toString());

    var newTab = BrowserView(
      key: GlobalKey(),
      webViewModel: BrowserProvider(url: WebUri("https://www.google.com")),
      onUrlSubmit: onUrlSumbit,
    );

    tabs.add(newTab);
    setState(() {
      currentPage = tabs.last.webViewModel.url.toString();
      selectedTab = tabs.last;
      selectedIndex = tabs.length - 1;
    });
    log(tabs.toString());
  }

  openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void dispose() {
    clipboardWatcher.removeListener(this);
    clipboardWatcher.stop();
    super.dispose();
  }

  @override
  void onClipboardChanged() async {
    ClipboardData? newClipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (newClipboardData != null &&
        newClipboardData.text != null &&
        newClipboardData.text!.startsWith("wc:")) {
      try {
        if (mounted) {
          handleRequestToWalletConnect(
              context, Uri.parse(newClipboardData.text!));
        }
      } catch (e) {
        log(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => (selectedTab as BrowserView).webViewModel,
      child: WillPopScope(
        onWillPop: widget.index == 1
            ? () async {
                tabs[0].webViewModel.webViewController?.goBack();
                return false;
              }
            : () async => true,
        child: Scaffold(
          key: _scaffoldKey,
          bottomNavigationBar: SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {
                        tabs[0].webViewModel.webViewController?.goBack();
                      },
                      icon: const Icon(Icons.arrow_back_ios)),
                  IconButton(
                      onPressed: () {
                        tabs[0].webViewModel.webViewController?.goForward();
                      },
                      icon: const Icon(Icons.arrow_forward_ios)),
                  IconButton(
                      onPressed: () {
                        tabs[0].webViewModel.webViewController?.loadUrl(
                            urlRequest:
                                URLRequest(url: WebUri(homePage.toString())));
                      },
                      icon: const Icon(Icons.home)),
                  IconButton(
                      onPressed: () {
                        log("RELOADING");
                        tabs[0].webViewModel.webViewController?.reload();
                      },
                      icon: const Icon(Icons.restart_alt)),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          showBrowser = false;
                        });
                      },
                      icon: const Icon(Icons.tab)),
                ],
              )),
          appBar: PreferredSize(
              preferredSize: const Size(double.infinity, 57),
              child: Consumer<BrowserProvider>(
                builder: (context, value, child) => BrowserUrlBar(
                    onUrlSubmit: onUrlSumbit,
                    webViewModel: value,
                    openDrawer: openDrawer,
                    url: currentPage,
                    certified: value.isSecure),
              )),
          body: SafeArea(
            child: Consumer<BrowserProvider>(
              builder: (context, value, child) => Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Stack(
                    children: [
                      IndexedStack(
                        index: selectedIndex,
                        children: [...tabs],
                      ),
                      !showBrowser
                          ? BrowserTabView(
                              createNewTab: createNewTab,
                              selectTab: (tab, index) {
                                setState(() {
                                  selectedIndex = index;
                                  selectedTab = tab;
                                  showBrowser = true;
                                });
                              },
                              onClose: (tab) {
                                tabs.remove(tab);
                                setState(() {});
                              },
                              tabs: tabs,
                            )
                          : const SizedBox()
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  onUrlSumbit(String value, BrowserProvider? webViewController) {
    if (value.split(".").length > 1) {
      var url = WebUri(value.trim());
      if (url.scheme.startsWith("http") && !Util.isLocalizedContent(url)) {
        (selectedTab as BrowserView)
            .webViewModel
            .webViewController!
            .loadUrl(urlRequest: URLRequest(url: url));
      }
      if (!url.scheme.startsWith("http")) {
        (selectedTab as BrowserView).webViewModel.webViewController!.loadUrl(
                urlRequest: URLRequest(
              url: WebUri("https://${value.trim()}"),
            ));
      }

      return;
    }
    String googleSearchUrl = "https://www.google.com/search?q=$value";
    (selectedTab as BrowserView)
        .webViewModel
        .webViewController
        ?.loadUrl(urlRequest: URLRequest(url: WebUri(googleSearchUrl)));
    FocusManager.instance.primaryFocus!.unfocus();
  }
}
