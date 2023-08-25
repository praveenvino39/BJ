import 'package:flutter/material.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  static const router = "web_view_screen";
  final String url;
  final String title;

  const WebViewScreen(
      {Key? key,
      required this.url,
      required this.title
      })
      : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  @override
  Widget build(BuildContext context) {
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
          child: Text(widget.title,
            style: const TextStyle(color: kPrimaryColor, fontSize: 16),
          ),
        ),
      ),
      body: WebView(
        onWebViewCreated: (WebViewController webViewController) {
        },
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
