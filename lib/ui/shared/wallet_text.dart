import 'package:flutter/material.dart';
import 'package:wallet/constant.dart';

class WalletText extends StatelessWidget {
  final String textContent;
  final double? size;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? align;
  final Function()? onTap;
  final double? height;
  const WalletText(this.textContent,
      {super.key,
      this.size,
      this.fontWeight,
      this.color,
      this.align,
      this.height,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        textContent,
        textAlign: align,
        style: TextStyle(
          fontSize: size,
          height: height,
          fontWeight: fontWeight,
          color: color ?? kPrimaryColor,
        ),
      ),
    );
  }
}
