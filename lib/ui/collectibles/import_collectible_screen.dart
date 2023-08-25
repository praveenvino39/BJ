
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/collectible-bloc/cubit/collectible_cubit.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/core/model/collectible_model.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImportCollectibleScreen extends StatefulWidget {
  static const String route = "import_collectible_screen";
  const ImportCollectibleScreen({Key? key}) : super(key: key);

  @override
  State<ImportCollectibleScreen> createState() =>
      _ImportCollectibleScreenState();
}

class _ImportCollectibleScreenState extends State<ImportCollectibleScreen> {
  final TextEditingController _tokenAddress = TextEditingController();
  final TextEditingController _tokenIDController = TextEditingController();
  final TextEditingController _tokenName = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey();

  @override
  void initState() {
    _tokenAddress.addListener(() async {
      if (_tokenAddress.text.length == 42) {
        _tokenName.text = await context
            .read<WalletCubit>()
            .getCollectibleDetails(_tokenAddress.text);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CollectibleCubit, CollectibleState>(
      listener: (context, state) {
        if (state is CollectibleAdded) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("NFT added successfully"),
            backgroundColor: Colors.green,
          ));
        }
        if (state is CollectibleError) {
          // Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            content: Text(
                AppLocalizations.of(context)!.nftOwnedSomeone),
            backgroundColor: Colors.red,
          ));
        }
        // log(state.toString());
        // if (state is WalletCollectibleAdded) {
        //   Navigator.of(context).pop();
        //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //     content: Text("NFT added successfully"),
        //     backgroundColor: Colors.green,
        //   ));
        // }

        // if (state is WalletCollectibleNotOwned) {
        //   // Navigator.of(context).pop();
        //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //     content: Text(
        //         "NFT is owned by someone, You can only import NFT that you owned"),
        //     backgroundColor: Colors.red,
        //   ));
        // }
      },
      builder: (context, state) {
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
                          style: const  TextStyle(
                              fontWeight: FontWeight.w200,
                              color: Colors.black)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                color: getWalletLoadedState(context)
                                    .currentNetwork
                                    .dotColor,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            getWalletLoadedState(context).currentNetwork.networkName,
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
                    padding:  const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)!.tokenAddress,
                      style:  const TextStyle(fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      maxLength: 42,
                      controller: _tokenAddress,
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
                    padding:  const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)!.tokenName,
                      style:  const TextStyle(fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _tokenName,
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
                    padding: const  EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)!.tokenID,
                      style: const  TextStyle(fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _tokenIDController,
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
                            textContent: "Cancel",
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      ),
                      Expanded(
                        child: WalletButton(
                          type: WalletButtonType.filled,
                          textContent: "Import",
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              context.read<CollectibleCubit>().addCollectibles(
                                  collectible: Collectible(
                                    description: "",
                                    name: _tokenName.text,
                                    tokenId: _tokenIDController.text,
                                    tokenAddress: _tokenAddress.text,
                                  ),
                                  address: getWalletLoadedState(context)
                                      .wallet
                                      .privateKey
                                      .address
                                      .hex,
                                  network: getWalletLoadedState(context)
                                      .currentNetwork);
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
      },
    );
  }
}
