import 'package:flutter/material.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/ui/token/component/import_token.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImportTokenTile extends StatelessWidget {
  const ImportTokenTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(
        height: 20,
      ),
      Text(AppLocalizations.of(context)!.dontSeeYouToken),
      const SizedBox(
        height: 10,
      ),
      InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(ImportTokenScreen.route);
        },
        child: Text(
          AppLocalizations.of(context)!.importToken,
          style: const TextStyle(color: kPrimaryColor),
        ),
      ),
      const SizedBox(
        height: 20,
      )
    ]);
  }
}
