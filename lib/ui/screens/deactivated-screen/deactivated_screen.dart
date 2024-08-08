// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/core/remote/response-model/register_user.dart';
import 'package:wallet_cryptomask/core/socket/message_engine.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/screens/chat_screen/chat_screen.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

class DeactivatedScreen extends StatefulWidget {
  static const route = "deactivated_screen";
  const DeactivatedScreen({super.key});

  @override
  State<DeactivatedScreen> createState() => _DeactivatedScreenState();
}

class _DeactivatedScreenState extends State<DeactivatedScreen> {
  User user = Get.find<User>();

  @override
  void initState() {
    super.initState();
    final messageEngine = MessageEngine.getMessageEngine(context);
    if (user.token != null) {
      messageEngine.socketService.forId = user.id;
      messageEngine.setToken(user.token!);
    }
    messageEngine.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: WalletText(
                align: TextAlign.center,
                localizeKey: 'yourAccountDeactivated',
              ),
            ),
            addHeight(SpacingSize.m),
            WalletButton(
              onPressed: () {
                context.push(() => const ChatScreen());
              },
              type: WalletButtonType.filled,
              localizeKey: 'contactAdmin',
            )
          ],
        ),
      ),
    );
  }
}
