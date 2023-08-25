

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/utils.dart';
import 'package:web3dart/crypto.dart';


class SecuritySettingsScreen extends StatefulWidget {
  static const route = "security_settings_screen";
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool showPrivateKey = false;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {

      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            title:  Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 70, 10),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.security,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                 Text(
                  AppLocalizations.of(context)!.showPrivateKey,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 7,
                ),
                 InkWell(
                  onLongPress: (){
                    setState(() {
                      showPrivateKey = true;
                      copyAddressToClipBoard(bytesToHex(getWalletLoadedState(context).wallet.privateKey.privateKey), context, isPk: true);
                    });
                  },
                  onTap: (){
                    setState(() {
                      showPrivateKey = true;
                    });
                  },
                   child: Text( !showPrivateKey ?
                      AppLocalizations.of(context)!.tapHereToReveal : bytesToHex(getWalletLoadedState(context).wallet.privateKey.privateKey)),
                 ),
                const SizedBox(
                  height: 7,
                ),
                const SizedBox(
                  height: 20,
                
                ),
                const SizedBox(
                  height: 7,
                )
                
                // FutureBuilder<List<String>?>(
                //     future: getSupportedVsCurrency(),
                //     builder: (context, snapshot) {
                //       return DropdownButtonHideUnderline(
                //           child: Container(
                //         padding: const EdgeInsets.symmetric(horizontal: 10),
                //         decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(5),
                //             border: Border.all(width: 1, color: kPrimaryColor)),
                //         child: DropdownButton<String>(
                //             isExpanded: true,
                //             value: vsCurrency,
                //             items: snapshot.data
                //                 ?.map<DropdownMenuItem<String>>(
                //                     (e) => DropdownMenuItem<String>(
                //                           value: e,
                //                           child: Text(e.toUpperCase()),
                //                         ))
                //                 .toList(),
                //             onChanged: (value) => {
                //                   setState(() {
                //                     vsCurrency = value!;
                //                   })
                //                 }),
                //       ));
                //     })
              ],
            ),
          ),
        );
      },
    );
  }
}