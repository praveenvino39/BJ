import 'package:flutter/material.dart';
import 'package:wallet/config.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/ui/setttings/general_settings_screen/general_settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet/ui/setttings/security_settings_screen/security_settings_screen.dart';
import 'package:wallet/ui/webview/web_view_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const route = "settings_screen";
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                AppLocalizations.of(context)!.settings,
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
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(GeneralSettingsScreen.route);
                },
                title: Text(AppLocalizations.of(context)!.general),
                subtitle: Text(
                    AppLocalizations.of(context)!.generalDescription),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.withAlpha(60),
              ),
              ListTile(
                onTap: () =>Navigator.of(context).pushNamed(SecuritySettingsScreen.route),
                title:  Text(AppLocalizations.of(context)!.security),
                subtitle: Text(AppLocalizations.of(context)!.securityDescription),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.withAlpha(60),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.withAlpha(60),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.withAlpha(60),
              ),
              InkWell(onTap: (){
                Navigator.of(context).pushNamed(WebViewScreen.router, arguments: {"title": "About", "url": aboutUrl});
              },child: ListTile(title: Text(AppLocalizations.of(context)!.about(AppLocalizations.of(context)!.appName)))),
            ],
          ),
        ),
      ),
    );
  }
}
