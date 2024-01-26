import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/ui/browser/model/web_view_model.dart';

class BrowserUrlField extends StatefulWidget {
  static const route = "browser_url_bar";
  final Function(String, WebViewModel) onUrlSubmit;
  final bool? certified;
  final WebViewModel webViewModel;
  final String url;
  const BrowserUrlField(
      {super.key,
      required this.webViewModel,
      required this.certified,
      required this.onUrlSubmit,
      required this.url});

  @override
  State<BrowserUrlField> createState() => _BrowserUrlFieldState();
}

class _BrowserUrlFieldState extends State<BrowserUrlField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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
    super.initState();
    urlController.text = widget.url;
    if (urlController.text.isNotEmpty) {
      enableClear = true;
    }
    _controller = AnimationController(vsync: this);
    urFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withAlpha(240),
      body: SizedBox(
        // height: 40,
        child: Column(
          children: [
            const SizedBox(
              height: 56,
            ),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: TextFormField(
                    onFieldSubmitted: (value) {
                      widget.onUrlSubmit(value.trim(), widget.webViewModel);
                      Navigator.of(context).pop();
                    },
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        enableClear = false;
                      } else {
                        enableClear = true;
                      }
                      setState(() {});
                    },
                    keyboardType: TextInputType.url,
                    autofocus: false,
                    controller: urlController,
                    focusNode: urFocusNode,
                    textInputAction: TextInputAction.go,
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                          splashRadius: 30,
                          onPressed: () async {
                            Box box = await Hive.openBox("user_preference");
                            box.put("connected-sites", []);
                          },
                          icon: const Icon(
                            FontAwesomeIcons.google,
                            size: 20,
                            color: kPrimaryColor,
                          )),
                      contentPadding: const EdgeInsets.only(
                          left: 0, top: 10.0, right: 10.0, bottom: 10.0),
                      filled: true,
                      fillColor: Colors.white,
                      border: outlineBorder,
                      suffixIconColor: kPrimaryColor,
                      suffixIcon: enableClear
                          ? IconButton(
                              onPressed: () {
                                urlController.text = "";
                                enableClear = false;
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.black.withAlpha(50),
                              ))
                          : const SizedBox(),
                      focusedBorder: outlineBorder,
                      enabledBorder: outlineBorder,
                      hintText: "Search or type a web address",
                      hintStyle: const TextStyle(
                          color: Colors.black54, fontSize: 12.0),
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 12.0),
                  ),
                ),
                const SizedBox(
                  width: 16,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
