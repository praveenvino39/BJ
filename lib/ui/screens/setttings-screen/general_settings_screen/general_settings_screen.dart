import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/core/providers/locale_provider/locale_provider.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

class GeneralSettingsScreen extends StatefulWidget {
  static String route = "general_setting_screen";
  const GeneralSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  String locale = "en";

  @override
  void initState() {
    final localProvider = getLocalProvider(context);

    localProvider.getLocale().then((value) {
      setState(() {
        locale = value;
      });
    });

    super.initState();
  }

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
            addHeight(SpacingSize.m),
            Text(
              AppLocalizations.of(context)!.currentLanguage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            addHeight(SpacingSize.xs),
            Text(AppLocalizations.of(context)!.languageDescription),
            addHeight(SpacingSize.xs),
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
                    getLocalProvider(context).changeLocale(value ?? "en");
                    setState(() {
                      locale = value!;
                    });
                  }),
            ))
          ],
        ),
      ),
    );
  }
}
