import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/locale_provider/locale_provider.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

class GeneralSettingsScreen extends StatefulWidget {
  static String route = "general_setting_screen";
  const GeneralSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  @override
  Widget build(BuildContext context) {
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
        title: const Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 70, 10),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: WalletText(
                localizeKey: 'general',
                color: Colors.black,
                fontWeight: FontWeight.w300,
                size: 16,
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
            addHeight(SpacingSize.m),
            const WalletText(
                localizeKey: 'currentLanguage',
                size: 16,
                fontWeight: FontWeight.bold),
            addHeight(SpacingSize.xs),
            const WalletText(
              localizeKey: 'languageDescription',
            ),
            addHeight(SpacingSize.xs),
            DropdownButtonHideUnderline(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 1, color: kPrimaryColor)),
              child: DropdownButton<String>(
                  isExpanded: true,
                  value: getLiveLocalProvider(context).locale,
                  items: LocaleProvider.supportedLocales
                      .map<DropdownMenuItem<String>>(
                          (e) => DropdownMenuItem<String>(
                                value: e.languageCode,
                                child: Text(e.languageCode.toUpperCase()),
                              ))
                      .toList(),
                  onChanged: (value) {
                    Get.updateLocale(Locale(value ?? "en"));
                    getLocalProvider(context).changeLocale(value ?? "en");
                  }),
            ))
          ],
        ),
      ),
    );
  }
}
