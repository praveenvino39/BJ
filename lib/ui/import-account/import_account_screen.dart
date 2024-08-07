import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';
import 'package:wallet_cryptomask/utils/utils.dart';

class ImportAccount extends StatefulWidget {
  static const route = "import_account";
  const ImportAccount({Key? key}) : super(key: key);

  @override
  State<ImportAccount> createState() => _ImportAccountState();
}

class _ImportAccountState extends State<ImportAccount> {
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _privateKeyFormKey = GlobalKey();
  final TextEditingController _privateKey = TextEditingController();

  onImportAccountHandler() {
    if (_privateKeyFormKey.currentState!.validate()) {
      if (Provider.of<WalletProvider>(context, listen: false).wallets.isEmpty) {
        Provider.of<WalletProvider>(context, listen: false)
            .importAccountFromPrivateKeyOnboarding(
                privateKey: _privateKey.text, password: _password.text)
            .then((value) {
          Navigator.of(context).pop();
        }).catchError((e) {
          showErrorSnackBar(context, 'Error', e);
        });
        return;
      }
      Provider.of<WalletProvider>(context, listen: false)
          .importAccountFromPrivateKey(privateKey: _privateKey.text)
          .then((value) {
        Navigator.of(context).pop();
      }).catchError((e) {
        showErrorSnackBar(context, 'Error', e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 70, 10),
          child: Center(
            child: Text(
              "Import account",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _privateKeyFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            addHeight(SpacingSize.l),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Privatekey"),
            ),
            addHeight(SpacingSize.s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _privateKey,
                validator: (String? string) {
                  if (string!.isEmpty) {
                    return "Privakey shouldn't be empty";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    hintText: "Enter Privatekey",
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor)),
                    border: OutlineInputBorder(borderSide: BorderSide())),
              ),
            ),
            addHeight(SpacingSize.m),
            Provider.of<WalletProvider>(context).wallets.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Password"),
                  )
                : const SizedBox(),
            Provider.of<WalletProvider>(context).wallets.isEmpty
                ? addHeight(SpacingSize.s)
                : const SizedBox(),
            Provider.of<WalletProvider>(context).wallets.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _password,
                      validator: (String? string) {
                        if (string!.isEmpty) {
                          return "Password shouldn't be empty";
                        }
                        if (string.length < 8) {
                          return "Password atleast contain 8 character";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          hintText: "Enter new password",
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor)),
                          border: OutlineInputBorder(borderSide: BorderSide())),
                    ),
                  )
                : const SizedBox(),
            addHeight(SpacingSize.m),
            WalletButton(
                type: WalletButtonType.filled,
                localizeKey: 'importAccount',
                onPressed: onImportAccountHandler),
            const SizedBox(
              height: 170,
            )
          ],
        ),
      ),
    );
  }
}
