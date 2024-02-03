import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

enum TextFieldType { input, password }

class WalletTextField extends StatefulWidget {
  final TextFieldType textFieldType;
  final String labelLocalizeKey;
  final String? Function(String?)? validator;
  final TextEditingController? textEditingController;
  final int? maxLength;
  const WalletTextField(
      {super.key,
      required this.textFieldType,
      required this.labelLocalizeKey,
      this.validator,
      this.maxLength,
      this.textEditingController});

  @override
  State<WalletTextField> createState() => _WalletTextFieldState();
}

class _WalletTextFieldState extends State<WalletTextField> {
  bool showPassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.textFieldType == TextFieldType.password) {
      setState(() {
        showPassword = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WalletText(
              "",
              localizeKey: widget.labelLocalizeKey,
              textVarient: TextVarient.body2,
            ),
            widget.textFieldType == TextFieldType.password
                ? InkWell(
                    onTap: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    child: const WalletText(
                      "",
                      localizeKey: "show",
                      textVarient: TextVarient.body2,
                    ))
                : const SizedBox(),
          ],
        ),
        addHeight(SpacingSize.xs),
        TextFormField(
          maxLength: widget.maxLength,
          controller: widget.textEditingController,
          validator: widget.validator,
          cursorColor: kPrimaryColor,
          obscureText: !showPassword,
          decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor)),
              border: OutlineInputBorder(borderSide: BorderSide())),
        ),
      ],
    );
  }
}
