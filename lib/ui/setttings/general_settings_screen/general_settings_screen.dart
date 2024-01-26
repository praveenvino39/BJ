import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/locale_provider/cubit/locale_cubit.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';

class GeneralSettingsScreen extends StatefulWidget {
  static String route = "general_setting_screen";
  const GeneralSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  String vsCurrency = "usd";
  String locale = "en";

  @override
  void initState() {
    context.read<WalletCubit>().getCurrenctCurrency().then((value) {
      setState(() {
        vsCurrency = value;
      });
    });
    context.read<LocaleCubit>().getLocale().then((value) {
      setState(() {
        locale = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {
        if (state is WalletCurrencyChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              elevation: 10,
              backgroundColor: Colors.green,
              content: Text("Prefered currency changed"),
            ),
          );
        }
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
            title: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 70, 10),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.general,
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
                  AppLocalizations.of(context)!.currencyConversion,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(AppLocalizations.of(context)!.displayFiat),
                const SizedBox(
                  height: 7,
                ),
                FutureBuilder<List<String>?>(
                    future: getSupportedVsCurrency(),
                    builder: (context, snapshot) {
                      return DropdownButtonHideUnderline(
                          child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: kPrimaryColor)),
                        child: DropdownButton<String>(
                            isExpanded: true,
                            value: vsCurrency,
                            items: snapshot.data
                                ?.map<DropdownMenuItem<String>>(
                                    (e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(e.toUpperCase()),
                                        ))
                                .toList(),
                            onChanged: (value) {
                              context
                                  .read<WalletCubit>()
                                  .changeVsCurrency(value!);
                              setState(() {
                                vsCurrency = value;
                              });
                            }),
                      ));
                    }),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  AppLocalizations.of(context)!.currentLanguage,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(AppLocalizations.of(context)!.languageDescription),
                const SizedBox(
                  height: 7,
                ),
                DropdownButtonHideUnderline(
                    child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 1, color: kPrimaryColor)),
                  child: DropdownButton<String>(
                      isExpanded: true,
                      value: locale,
                      items: AppLocalizations.supportedLocales
                          .map<DropdownMenuItem<String>>(
                              (e) => DropdownMenuItem<String>(
                                    value: e.languageCode,
                                    child: Text(e.languageCode.toUpperCase()),
                                  ))
                          .toList(),
                      onChanged: (value) {
                        Get.updateLocale(Locale(value ?? "en"));
                        context.read<LocaleCubit>().changeLocale(value ?? "en");
                        setState(() {
                          locale = value!;
                        });
                      }),
                ))
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
