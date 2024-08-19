import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/screens/home-screen/home_screen.dart';
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
  final TextEditingController _password =
      TextEditingController(text: kDebugMode ? "11111111" : "");
  final GlobalKey<FormState> _privateKeyFormKey = GlobalKey();
  final TextEditingController _privateKey = TextEditingController();
  final TextEditingController _seedphrase = TextEditingController(
      text: kDebugMode
          ? "gospel balcony arrest panda creek steel cute two timber machine travel iron"
          : "");

  onImportAccountHandlerWithPK() async {
    final walletProvider = getWalletProvider(context);
    if (_privateKeyFormKey.currentState!.validate()) {
      walletProvider.showLoading();
      try {
        await walletProvider.importAccountFromPrivateKey(
            privateKey: _privateKey.text);
        walletProvider.hideLoading();
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        walletProvider.hideLoading();
        showErrorSnackBar(
            context, getText(context, key: 'error'), e.toString());
      }
    }
  }

  onImportAccountHandlerWithSeedphrase() async {
    final walletProvider = getWalletProvider(context);
    if (_privateKeyFormKey.currentState!.validate()) {
      walletProvider.showLoading();
      try {
        await walletProvider.importAccountFromSeedphraseOnboarding(
            seedphrase: _seedphrase.text, password: _password.text);
        await walletProvider.openWallet(password: _password.text);
        walletProvider.hideLoading();
        if (!mounted) return;
        context.pushAndRemoveUntil(
            removeUntil: bool, builder: () => const HomeScreen());
      } catch (e) {
        walletProvider.hideLoading();
        if (!mounted) return;
        showErrorSnackBar(
            context, getText(context, key: 'error'), e.toString());
      }
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
        body: getLiveWalletProvider(context).loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : getLiveWalletProvider(context).wallets.isNotEmpty
                ? Form(
                    key: _privateKeyFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        addHeight(SpacingSize.l),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: WalletTextField(
                            textFieldType: TextFieldType.input,
                            labelLocalizeKey: 'enterPrivateKey',
                            textEditingController: _privateKey,
                            validator: (String? string) {
                              if (string!.isEmpty) {
                                return getText(context,
                                    key: 'privateKeyNotEmpty');
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: WalletTextField(
                                  textFieldType: TextFieldType.input,
                                  textEditingController: _password,
                                  validator: (String? string) {
                                    if (string!.isEmpty) {
                                      return getText(context,
                                          key: 'passwordNotEmpty');
                                    }
                                    if (string.length < 8) {
                                      return getText(context,
                                          key: 'passwordAtleast');
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
                            onPressed: onImportAccountHandlerWithPK),
                        const SizedBox(
                          height: 170,
                        )
                      ],
                    ),
                  )
                : Form(
                    key: _privateKeyFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        addHeight(SpacingSize.l),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: WalletTextField(
                            textFieldType: TextFieldType.input,
                            labelLocalizeKey: 'seedphrase',
                            textEditingController: _seedphrase,
                            validator: (String? string) {
                              if (string!.isEmpty) {
                                return getText(context,
                                    key: 'privateKeyNotEmpty');
                              }
                              return null;
                            },
                          ),
                        ),
                        addHeight(SpacingSize.m),
                        Provider.of<WalletProvider>(context).wallets.isEmpty
                            ? addHeight(SpacingSize.s)
                            : const SizedBox(),
                        Provider.of<WalletProvider>(context).wallets.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: WalletTextField(
                                  textFieldType: TextFieldType.password,
                                  textEditingController: _password,
                                  validator: (String? string) {
                                    if (string!.isEmpty) {
                                      return getText(context,
                                          key: 'passwordNotEmpty');
                                    }
                                    if (string.length < 8) {
                                      return getText(context,
                                          key: 'passwordAtleast');
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
                            onPressed: onImportAccountHandlerWithSeedphrase),
                        const SizedBox(
                          height: 170,
                        )
                      ],
                    ),
                  ));
  }
}
