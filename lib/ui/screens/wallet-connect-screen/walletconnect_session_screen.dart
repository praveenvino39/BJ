// ignore_for_file: empty_catches, use_build_context_synchronously

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectSessionScreen extends StatefulWidget {
  static const route = "WALLETCONNECT_SESSIONS";
  const WalletConnectSessionScreen({super.key});

  @override
  State<WalletConnectSessionScreen> createState() =>
      _WalletConnectSessionScreenState();
}

class _WalletConnectSessionScreenState
    extends State<WalletConnectSessionScreen> {
  bool isLoading = true;
  List<SessionData> sessions = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    setState(() {
      sessions = getWalletProvider(context).web3Wallet?.sessions.getAll() ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const WalletText(
          localizeKey: 'wcSessions',
          size: 16,
          fontWeight: FontWeight.w700,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final alert = StatefulBuilder(
                builder: (context, innerSetState) => AlertDialog(
                  backgroundColor: Colors.white,
                  content: SizedBox(
                    width: context.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const WalletText(
                          localizeKey: 'wcEndDialog',
                        ),
                        addHeight(SpacingSize.m),
                        Row(
                          children: [
                            Expanded(
                              child: WalletButton(
                                textSize: 14.0,
                                localizeKey: 'cancel',
                                onPressed: () => Get.back(),
                                type: WalletButtonType.outline,
                              ),
                            ),
                            Expanded(
                              child: WalletButton(
                                textSize: 14.0,
                                localizeKey: 'endAll',
                                onPressed: () async {
                                  try {
                                    for (var session in sessions) {
                                      await getWalletProvider(context)
                                          .web3Wallet
                                          ?.disconnectSession(
                                            topic: session.topic,
                                            reason: Errors.getSdkError(
                                              Errors.USER_DISCONNECTED,
                                            ),
                                          );
                                      await getWalletProvider(context)
                                          .web3Wallet
                                          ?.sessions
                                          .delete(
                                            session.topic,
                                          );
                                    }
                                  } catch (e) {
                                    log(e.toString());
                                  }
                                  setState(() {
                                    sessions.clear();
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
                  ),
                ),
              );
              showDialog(context: context, builder: (context) => alert);
            },
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: SizedBox(
        child: sessions.isNotEmpty
            ? ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        trailing: IconButton(
                            onPressed: () {
                              final alert = StatefulBuilder(
                                builder: (context, innerSetState) =>
                                    AlertDialog(
                                  backgroundColor: Colors.white,
                                  content: SizedBox(
                                    width: context.width,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        WalletText(
                                          localizeKey: getTextWithPlaceholder(
                                              context,
                                              key: 'endOne',
                                              string: sessions[index]
                                                  .peer
                                                  .metadata
                                                  .name),
                                        ),
                                        addHeight(SpacingSize.m),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: WalletButton(
                                                textSize: 14.0,
                                                localizeKey: 'cancel',
                                                onPressed: () => Get.back(),
                                                type: WalletButtonType.outline,
                                              ),
                                            ),
                                            Expanded(
                                              child: WalletButton(
                                                textSize: 14.0,
                                                localizeKey: 'end',
                                                onPressed: () async {
                                                  try {
                                                    getWalletProvider(context)
                                                        .web3Wallet!
                                                        .disconnectSession(
                                                          topic: sessions[index]
                                                              .topic,
                                                          reason: Errors
                                                              .getSdkError(
                                                            Errors
                                                                .USER_DISCONNECTED,
                                                          ),
                                                        )
                                                        .then((value) {
                                                      getWalletProvider(context)
                                                          .web3Wallet!
                                                          .sessions
                                                          .delete(
                                                              sessions[index]
                                                                  .topic);
                                                      setState(() {
                                                        sessions.remove(
                                                            sessions[index]);
                                                      });
                                                    });
                                                  } catch (e) {
                                                    log(e.toString());
                                                  }
                                                  setState(() {
                                                    sessions.remove(
                                                        sessions[index]);
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
                                  ),
                                ),
                              );
                              showDialog(
                                  context: context,
                                  builder: (context) => alert);
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                            )),
                        leading: sessions[index].peer.metadata.icons.isNotEmpty
                            ? CachedNetworkImage(
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                imageUrl:
                                    sessions[index].peer.metadata.icons[0],
                              )
                            : const Icon(Icons.public),
                        title: Text(
                          sessions[index].peer.metadata.name,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          sessions[index].peer.metadata.url,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const Divider()
                    ],
                  );
                },
              )
            : Center(
                child: WalletText(
                  localizeKey: getText(context, key: 'noWC'),
                ),
              ),
      ),
    );
  }
}
