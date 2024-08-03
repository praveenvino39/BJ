import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/contact_provider/contact_provider.dart';
import 'package:wallet_cryptomask/core/bloc/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/ui/amount/amount_screen.dart';
import 'package:wallet_cryptomask/ui/contacts/add_contact.dart';
import 'package:wallet_cryptomask/ui/home/component/avatar_component.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';

class ContactTile extends StatefulWidget {
  final String name;
  final String address;
  final String network;
  final String id;
  final String mode;
  final Function(String) onChoose;
  const ContactTile({
    Key? key,
    required this.name,
    required this.address,
    required this.network,
    required this.onChoose,
    required this.id,
    required this.mode,
  }) : super(key: key);

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  ExpansionTileController expansionTileController = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      controller: expansionTileController,
      onExpansionChanged: widget.mode == "SELECT"
          ? (value) {
              expansionTileController.collapse();
              widget.onChoose(widget.address);
            }
          : null,
      leading: AvatarWidget(
        radius: 30,
        address: widget.address,
      ),
      title: Text(widget.name),
      textColor: Colors.black,
      iconColor: kPrimaryColor,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.address,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: Text(widget.network),
      children: [
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () {
                final walletProvider = getWalletProvider(context);
                final tokenProvider = getTokenProvider(context);
                context.push(
                  () => AmountScreen(
                    balance: walletProvider.nativeBalance,
                    from: walletProvider.getCurrentAccountAddress(),
                    to: widget.address,
                    token: tokenProvider.tokens[0],
                  ),
                );
              },
              style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  foregroundColor: MaterialStateProperty.all(kPrimaryColor),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent)),
              child: Text(AppLocalizations.of(context)!.send),
            ),
            TextButton(
              onPressed: () {
                Get.bottomSheet(AddContact(
                  mode: "UPDATE",
                  address: widget.address,
                  name: widget.name,
                  id: widget.id,
                ));
              },
              style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  foregroundColor: MaterialStateProperty.all(kPrimaryColor),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent)),
              child: const WalletText(
                "",
                localizeKey: 'update',
              ),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const WalletText(
                                "",
                                localizeKey: "deleteWarning",
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: 130,
                                    child: WalletButton(
                                      textSize: 14.0,
                                      localizeKey: 'cancel',
                                      textContent: '',
                                      onPressed: () {
                                        Get.back();
                                      },
                                      type: WalletButtonType.outline,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: 130,
                                    child: WalletButton(
                                      textSize: 14.0,
                                      textContent: "",
                                      localizeKey: 'delete',
                                      onPressed: () {
                                        getContactProvider(context)
                                            .deleteContacts(
                                                address: widget.address,
                                                alreadyExist: () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: WalletText(
                                                      "",
                                                      localizeKey:
                                                          'contactExist',
                                                    ),
                                                    backgroundColor:
                                                        kPrimaryColor,
                                                  ));
                                                });
                                        Get.back();
                                      },
                                      type: WalletButtonType.filled,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ));
              },
              style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  foregroundColor: MaterialStateProperty.all(kPrimaryColor),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent)),
              child: const WalletText(
                "",
                localizeKey: 'delete',
              ),
            ),
          ],
        )
      ],
    );
  }
}
