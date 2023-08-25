
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/ui/browser/widgets/browser_view.dart';

class BrowserTabView extends StatefulWidget {
  final List<BrowserView> tabs;
  final Function(BrowserView) onClose;
  final Function(BrowserView, int index) selectTab;

  const BrowserTabView(
      {super.key,
      required this.tabs,
      required this.onClose,
      required this.selectTab});

  @override
  State<BrowserTabView> createState() => _BrowserTabViewState();
}

class _BrowserTabViewState extends State<BrowserTabView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.tabs.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    widget.selectTab(widget.tabs[index], index);
                  },
                  child: Dismissible(
                    onDismissed: (direction) {
                      widget.onClose(widget.tabs[index]);
                    },
                    key: GlobalKey(),
                    child: TabTile(
                      browserView: widget.tabs[index],
                      onClose: (tab) {
                        widget.onClose(tab);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TabTile extends StatefulWidget {
  final Function(BrowserView) onClose;
  final BrowserView browserView;
  const TabTile({Key? key, required this.browserView, required this.onClose})
      : super(key: key);

  @override
  State<TabTile> createState() => _TabTileState();
}

class _TabTileState extends State<TabTile> {
  Uint8List? image;
  String title = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(40),
                    border:
                        Border.all(width: 1, color: Colors.grey.withAlpha(40))),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Image.asset(widget.browserView.webViewModel.favicon?.url.toString() ?? "", width: 30, height: 30, errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.public);
                    },),
                    const SizedBox(width: 10,),
                    Expanded(
                        child: Text(widget.browserView.webViewModel.title ??
                            "New tab")),
                    IconButton(
                        splashRadius: 10,
                        onPressed: () {
                          widget.onClose(widget.browserView);
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 14,
                        ))
                  ],
                ),
              ),
              Container(
                color: kPrimaryColor,
                height: 150,
                child: widget.browserView.webViewModel.screenshot != null
                    ? Image.memory(
                        widget.browserView.webViewModel.screenshot!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      )
                    : Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(child: Text("New tab"))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
