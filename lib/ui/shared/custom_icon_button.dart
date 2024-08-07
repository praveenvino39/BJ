import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';

class CustomIconButton extends StatelessWidget {
  final Function() onPressed;
  final String localizeKey;
  final IconData iconData;
  const CustomIconButton(
      {super.key,
      required this.onPressed,
      required this.localizeKey,
      required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: kPrimaryColor,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              iconData,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
        WalletText(
          '',
          localizeKey: localizeKey,
          textVarient: TextVarient.body3,
        )
      ],
    );
  }
}
