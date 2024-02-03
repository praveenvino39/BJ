import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class ReceiveSheet extends StatefulWidget {
  final String address;
  const ReceiveSheet({Key? key, required this.address}) : super(key: key);

  @override
  State<ReceiveSheet> createState() => _ReceiveSheetState();
}

class _ReceiveSheetState extends State<ReceiveSheet> {
  onCopyHandler() {
    copyAddressToClipBoard(widget.address, context);
  }

  onShareHandler() {
    shareSendUrl(widget.address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            )),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              addHeight(SpacingSize.xs),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withAlpha(60),
                ),
                width: 50,
                height: 4,
              ),
              addHeight(SpacingSize.s),
              const WalletText('', localizeKey: 'receive'),
              QrImageView(
                data: widget.address,
                version: QrVersions.auto,
                size: 200.0,
              ),
              addHeight(SpacingSize.xs),
              const WalletText('', localizeKey: 'scanAddressto'),
              addHeight(SpacingSize.s),
              const Expanded(child: SizedBox()),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 50),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: kPrimaryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(40)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    addWidth(SpacingSize.s),
                    Expanded(
                        flex: 1,
                        child: WalletText('',
                            localizeKey: showEllipse(widget.address))),
                    addHeight(SpacingSize.xs),
                    Expanded(
                      child: WalletButton(
                        buttonSize: WalletButtonSize.small,
                        localizeKey: 'copy',
                        onPressed: onCopyHandler,
                        textSize: 12,
                      ),
                    ),
                    addHeight(SpacingSize.xs),
                    InkWell(
                      onTap: onShareHandler,
                      child: const Icon(
                        Icons.share_outlined,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              addHeight(SpacingSize.m),
            ],
          ),
        ),
      ),
    );
  }
}
