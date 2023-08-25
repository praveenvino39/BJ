import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:wallet/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReceiveSheet extends StatelessWidget {
  final String address;
  const ReceiveSheet({Key? key, required this.address}) : super(key: key);

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
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withAlpha(60),
                ),
                width: 50,
                height: 4,
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(AppLocalizations.of(context)!.receive),
              QrImage(
                data: address,
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(AppLocalizations.of(context)!.scanAddressto),
              const SizedBox(
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 50),
                // width: MediaQuery.of(context).size.width / 1.8,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.orange.shade100.withAlpha(90),
                    borderRadius: BorderRadius.circular(40)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(showEllipse(address)),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: WalletButton(
                        buttonSize: WalletButtonSize.small,
                        textContent: AppLocalizations.of(context)!.copy,
                        onPressed: () =>
                            copyAddressToClipBoard(address, context),
                        textSize: 12,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () => shareSendUrl(address),
                      child: const Icon(
                        Icons.share_outlined,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
