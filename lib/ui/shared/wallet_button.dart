import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';

enum WalletButtonType { outline, filled }

enum WalletButtonSize { small, medium, large }

class WalletButton extends StatefulWidget {
  final Function()? onPressed;
  final WalletButtonType type;
  final String? localizeKey;
  final bool fullWidth;
  final double textSize;
  final WalletButtonSize buttonSize;
  const WalletButton(
      {Key? key,
      required this.onPressed,
      this.textSize = 14,
      this.buttonSize = WalletButtonSize.medium,
      this.fullWidth = true,
      this.localizeKey,
      this.type = WalletButtonType.outline})
      : super(key: key);

  @override
  State<WalletButton> createState() => _WalletButtonState();
}

class _WalletButtonState extends State<WalletButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.type == WalletButtonType.filled
                ? widget.onPressed != null
                    ? Colors.white
                    : Colors.grey
                : kPrimaryColor,
            padding: kIsWeb || Platform.isMacOS
                ? widget.buttonSize == WalletButtonSize.small
                    ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10)
                    : const EdgeInsets.symmetric(horizontal: 17.0, vertical: 22)
                : widget.buttonSize == WalletButtonSize.small
                    ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10)
                    : const EdgeInsets.symmetric(
                        horizontal: 17.0, vertical: 10),
            backgroundColor: widget.type == WalletButtonType.filled
                ? widget.onPressed != null
                    ? kPrimaryColor
                    : kPrimaryColor.withAlpha(80)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            side: widget.type == WalletButtonType.outline
                ? const BorderSide(width: 1.0, color: kPrimaryColor)
                : null,
          ),
          onPressed: widget.onPressed,
          child: Text(
            getText(context, key: widget.localizeKey!),
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: widget.textSize),
          ),
        ),
      ),
    );
  }
}
