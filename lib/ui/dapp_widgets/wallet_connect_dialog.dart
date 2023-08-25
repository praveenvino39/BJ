
import 'package:flutter/material.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/ui/shared/wallet_button.dart';

class WalletConnectDialog extends StatelessWidget {
  final Function(String) onConnect;
  final TextEditingController _uriController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  WalletConnectDialog({super.key, required this.onConnect});

  

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Connect to WalletConnect Session",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _uriController,
                  validator: (String? string) {
                    if (string!.isEmpty) {
                      return "Uri shouldn't be empty";
                    }
                    try {
                      Uri.parse(_uriController.text);
                      return null;
                    } catch (e) {
                      return "Invalid WalletConnect uri";
                    }
                  },
                  decoration: const InputDecoration(
                      hintText: "Enter WalletConnect URI",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      border: OutlineInputBorder(borderSide: BorderSide())),
                ),
                const SizedBox(
                  height: 20,
                ),
                WalletButton(
                  textContent: "Connect",
                  onPressed: () {
                   if( _formKey.currentState?.validate() ?? false) {
                    onConnect(_uriController.text);
                   }
                  },
                )
              ],
            ),
          ),
        ));
  }
}
