import 'package:flutter/material.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/main.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  bool isLoading = false;

  onRetryHandler() async {
    setState(() {
      isLoading = !isLoading;
    });
    await loadAppSettings();
    final screen = await getInitialWidget();
    if (mounted) {
      context.pushAndRemoveUntil(
        removeUntil: bool,
        builder: () => screen,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WalletText(
              localizeKey: 'somethingWentWrongInitial',
              size: 22,
              align: TextAlign.center,
            ),
            addHeight(SpacingSize.m),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  )
                : WalletButton(
                    type: WalletButtonType.filled,
                    onPressed: onRetryHandler,
                    localizeKey: 'retry',
                  )
          ],
        ),
      ),
    );
  }
}
