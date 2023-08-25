import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserTab {
  final InAppWebView inAppWebView;
  InAppWebViewController? webViewController;
  BrowserTab({required this.inAppWebView, this.webViewController});
}
