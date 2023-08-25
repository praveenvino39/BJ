import 'package:flutter/material.dart';

class NetworkSwitchSheet extends StatefulWidget {
  const NetworkSwitchSheet({Key? key}) : super(key: key);

  @override
  State<NetworkSwitchSheet> createState() => _NetworkSwitchSheetState();
}

class _NetworkSwitchSheetState extends State<NetworkSwitchSheet> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.grey.withAlpha(60),
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [],
            ),
          ),
        ),
      ),
    );
  }
}
