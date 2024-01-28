import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';

enum TextVarient {
  hero,
  heading,
  subHeading,
  body1,
  body2,
  body3,
  body4,
  body5,
  body6
}

class WalletText extends StatelessWidget {
  final String? textContent;
  final double? size;
  final FontWeight? fontWeight;
  final TextVarient? textVarient;
  final Color? color;
  final String? localizeKey;
  final TextAlign? align;
  final Function()? onTap;
  final bool? center;
  final String? placeholderLocalizeKey;
  final double? height;
  final bool? bold;
  final bool? underline;

  const WalletText(this.textContent,
      {super.key,
      this.size,
      this.fontWeight,
      this.color,
      this.localizeKey,
      this.align,
      this.bold = false,
      this.underline = false,
      this.height,
      this.placeholderLocalizeKey,
      this.center = false,
      this.textVarient,
      this.onTap});

  double getTextSize(TextVarient textVarient) {
    switch (textVarient) {
      case TextVarient.hero:
        return 25;
      case TextVarient.heading:
        return 22;
      case TextVarient.body1:
        return 16;
      case TextVarient.body2:
        return 14;
      case TextVarient.body3:
        return 12;
      case TextVarient.body4:
        return 10;
      case TextVarient.body5:
        return 8;
      case TextVarient.body6:
        return 6;
      case TextVarient.subHeading:
        return 20;
    }
  }

  FontWeight getTextWeight(TextVarient textVarient) {
    if (bold!) {
      return FontWeight.bold;
    }
    switch (textVarient) {
      case TextVarient.hero:
        return FontWeight.bold;
      case TextVarient.heading:
        return FontWeight.bold;
      case TextVarient.body1:
        return FontWeight.w400;
      case TextVarient.body2:
        return FontWeight.w400;
      case TextVarient.body3:
        return FontWeight.w400;
      case TextVarient.body4:
        return FontWeight.w400;
      case TextVarient.body5:
        return FontWeight.w400;
      case TextVarient.body6:
        return FontWeight.w400;
      case TextVarient.subHeading:
        return FontWeight.w600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        placeholderLocalizeKey != null
            ? getTextWithPlaceholder(context,
                key: localizeKey!,
                string: getText(context, key: placeholderLocalizeKey!))
            : getText(context, key: localizeKey!),
        textAlign: center! ? TextAlign.center : align,
        style: TextStyle(
          fontSize: textVarient != null ? getTextSize(textVarient!) : size,
          height: height,
          decoration: underline! ? TextDecoration.underline : null,
          fontWeight:
              textVarient != null ? getTextWeight(textVarient!) : fontWeight,
          color: color ?? Colors.black,
        ),
      ),
    );
  }
}
