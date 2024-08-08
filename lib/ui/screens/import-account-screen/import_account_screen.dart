import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text_field.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

class ImportAccountScreen extends StatefulWidget {
  static const route = "import_account";
  const ImportAccountScreen({Key? key}) : super(key: key);

  @override
  State<ImportAccountScreen> createState() => _ImportAccountScreenState();
}

class _ImportAccountScreenState extends State<ImportAccountScreen> {
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
          showErrorSnackBar(context, getText(context, key: 'error'), e);
        });
        return;
      }
      Provider.of<WalletProvider>(context, listen: false)
          .importAccountFromPrivateKey(privateKey: _privateKey.text)
          .then((value) {
        Navigator.of(context).pop();
      }).catchError((e) {
        showErrorSnackBar(context, getText(context, key: 'error'), e);
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
            child: WalletText(
              localizeKey: 'importAccount',
              color: Colors.black,
              fontWeight: FontWeight.w300,
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
              child: WalletText(
                localizeKey: 'privateKey',
              ),
            ),
            addHeight(SpacingSize.s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: WalletTextField(
                textFieldType: TextFieldType.input,
                labelLocalizeKey: 'enterPrivateKey',
                textEditingController: _privateKey,
                validator: (String? string) {
                  if (string!.isEmpty) {
                    return getText(context, key: 'privateKeyNotEmpty');
                  }
                  return null;
                },
              ),
            ),
            addHeight(SpacingSize.m),
            Provider.of<WalletProvider>(context).wallets.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: WalletText(
                      localizeKey: 'password',
                    ),
                  )
                : const SizedBox(),
            Provider.of<WalletProvider>(context).wallets.isEmpty
                ? addHeight(SpacingSize.s)
                : const SizedBox(),
            Provider.of<WalletProvider>(context).wallets.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: WalletTextField(
                      textFieldType: TextFieldType.input,
                      textEditingController: _password,
                      validator: (String? string) {
                        if (string!.isEmpty) {
                          return getText(context, key: 'passwordNotEmpty');
                        }
                        if (string.length < 8) {
                          return getText(context, key: 'passwordAtleast');
                        }
                        return null;
                      },
                      labelLocalizeKey: 'enterNewPassword',
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
