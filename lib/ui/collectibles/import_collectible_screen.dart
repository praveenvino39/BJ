import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/collectible_provider/collectible_provider.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/collectible_model.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/utils.dart';

class ImportCollectibleScreen extends StatefulWidget {
  static const String route = "import_collectible_screen";
  const ImportCollectibleScreen({Key? key}) : super(key: key);

  @override
  State<ImportCollectibleScreen> createState() =>
      _ImportCollectibleScreenState();
}

class _ImportCollectibleScreenState extends State<ImportCollectibleScreen> {
  final TextEditingController _collectibleAddress = TextEditingController();
  final TextEditingController _collectibleIDController =
      TextEditingController();
  final TextEditingController _collectibleName = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey();

  @override
  void initState() {
    _collectibleAddress.addListener(() async {
      if (_collectibleAddress.text.length == 42) {
        final name =
            await Provider.of<CollectibleProvider>(context, listen: false)
                .getCollectibleDetails(
                    _collectibleAddress.text,
                    Provider.of<WalletProvider>(context, listen: false)
                        .activeNetwork);
        _collectibleName.text = name;
      }
    });
    super.initState();
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
        title: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 70, 10),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.importCollectible,
                      style: const TextStyle(
                          fontWeight: FontWeight.w200, color: Colors.black)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                            color: Provider.of<WalletProvider>(context)
                                .activeNetwork
                                .dotColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        Provider.of<WalletProvider>(context)
                            .activeNetwork
                            .networkName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w100,
                            fontSize: 12,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formkey,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          // width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 0,
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context)!.tokenAddress,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  maxLength: 42,
                  controller: _collectibleAddress,
                  validator: (String? string) {
                    if (string?.isEmpty == true) {
                      return AppLocalizations.of(context)!.thisFieldNotEmpty;
                    }
                    return null;
                  },
                  cursorColor: kPrimaryColor,
                  decoration: const InputDecoration(
                      hintText: "0x...",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      border: OutlineInputBorder(borderSide: BorderSide())),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context)!.tokenName,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _collectibleName,
                  validator: (String? string) {
                    if (string?.isEmpty == true) {
                      return AppLocalizations.of(context)!.thisFieldNotEmpty;
                    }
                    return null;
                  },
                  cursorColor: kPrimaryColor,
                  decoration: const InputDecoration(
                      hintText: "Cryptoguys",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      border: OutlineInputBorder(borderSide: BorderSide())),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context)!.tokenID,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _collectibleIDController,
                  validator: (String? string) {
                    if (string!.isEmpty == true) {
                      return "This field shouldn't be empty";
                    }
                    return null;
                  },
                  cursorColor: kPrimaryColor,
                  decoration: const InputDecoration(
                      hintText: "0",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      border: OutlineInputBorder(borderSide: BorderSide())),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: WalletButton(
                        localizeKey: "cancel",
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ),
                  Expanded(
                    child: WalletButton(
                      type: WalletButtonType.filled,
                      localizeKey: "import",
                      onPressed: () async {
                        if (_formkey.currentState!.validate()) {
                          Provider.of<CollectibleProvider>(context,
                                  listen: false)
                              .addCollectibles(
                                  collectible: Collectible(
                                    description: "",
                                    name: _collectibleName.text,
                                    tokenId: _collectibleIDController.text,
                                    tokenAddress: _collectibleAddress.text,
                                  ),
                                  address: Provider.of<WalletProvider>(context,
                                          listen: false)
                                      .activeWallet
                                      .wallet
                                      .privateKey
                                      .address
                                      .hex,
                                  network: Provider.of<WalletProvider>(context,
                                          listen: false)
                                      .activeNetwork)
                              .then((value) {
                            showPositiveSnackBar(context, "Collectible added",
                                "${_collectibleName.text} is added to the portfolio");
                            Navigator.of(context).pop();
                          }).catchError((e) {
                            showErrorSnackBar(context,
                                "Error in adding Collectible", e.toString());
                          });
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
