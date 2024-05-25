// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class DeactivatedScreen extends StatefulWidget {
  static const route = "deactivated_screen";
  const DeactivatedScreen({super.key});

  @override
  State<DeactivatedScreen> createState() => _DeactivatedScreenState();
}

class _DeactivatedScreenState extends State<DeactivatedScreen> {
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
                '',
                align: TextAlign.center,
                localizeKey: 'yourAccountDeactivated',
              ),
            ),
            addHeight(SpacingSize.m),
            WalletButton(
              onPressed: () {},
              type: WalletButtonType.filled,
              localizeKey: 'contactAdmin',
            )
          ],
        ),
      ),
    );
  }
}
