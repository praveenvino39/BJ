import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/token/component/import_token.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class ImportTokenTile extends StatefulWidget {
  const ImportTokenTile({Key? key}) : super(key: key);

  @override
  State<ImportTokenTile> createState() => _ImportTokenTileState();
}

class _ImportTokenTileState extends State<ImportTokenTile> {
  onTokenTapHandler() {
    Navigator.of(context).pushNamed(ImportTokenScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      addHeight(SpacingSize.s),
      const WalletText('', localizeKey: 'dontSeeYouToken'),
      addHeight(SpacingSize.xs),
      InkWell(
        onTap: onTokenTapHandler,
        child: const WalletText(
          '',
          localizeKey: 'importToken',
          color: kPrimaryColor,
        ),
      ),
      addHeight(SpacingSize.s),
    ]);
  }
}
