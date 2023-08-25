
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constant.dart';
import 'dart:io' show Platform;

enum WalletButtonType { outline, filled }

class WalletButtonWithIcon extends StatefulWidget {
  final String textContent;
  final Function()? onPressed;
  final WalletButtonType type;
  final Widget icon;
  const WalletButtonWithIcon(
      {Key? key,
      required this.textContent,
      required this.onPressed,
      required this.icon,
      this.type = WalletButtonType.outline})
      : super(key: key);

  @override
  State<WalletButtonWithIcon> createState() => _WalletButtonWithIconState();
}

class _WalletButtonWithIconState extends State<WalletButtonWithIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: kIsWeb || Platform.isMacOS ? const EdgeInsets.symmetric( horizontal: 17.0, vertical: 22) : const EdgeInsets.symmetric( horizontal: 17.0, vertical: 10),
            primary: widget.type == WalletButtonType.filled
                ? widget.onPressed != null
                    ? Colors.white
                    : Colors.grey
                : kPrimaryColor,
            backgroundColor: widget.type == WalletButtonType.filled
                ? widget.onPressed != null ? kPrimaryColor : kPrimaryColor.withAlpha(80)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            side: widget.type == WalletButtonType.outline
                ? const BorderSide(width: 1.0, color: kPrimaryColor)
                : null,
          ),
          onPressed: widget.onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 4,),
              Text(
                widget.textContent,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
