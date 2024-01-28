import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet_cryptomask/core/create_wallet_provider/create_wallet_provider.dart';
import 'package:wallet_cryptomask/mock/mock.dart';
import 'package:wallet_cryptomask/ui/home/home_screen.dart';
import 'package:wallet_cryptomask/ui/screens/confirm_passphrase/confirm_passphrase_screen.dart';
import 'package:wallet_cryptomask/ui/screens/onboarding/onboard_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/utils/test_utils.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  testWidgets('ConfirmPassphraseScreen - should render correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const ConfirmPassPhraseScreen()));
    await tester.pump();

    expect(find.text('Select each word in the order it was presented to you'),
        findsOneWidget);
    expect(
        find.byKey(const Key('passphrase-options-grid-view')), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.byKey(const Key('passphrase-blank-grid-view')), findsOneWidget);
    expect(find.text('Create Wallet'), findsOneWidget);
  });

  testWidgets(
      'ConfirmPassphraseScreen - should enable create wallet button when all the words are filed',
      (WidgetTester tester) async {
    final createWalletProvider =
        CreateWalletProvider(const FlutterSecureStorage());
    final passphrase =
        'fitness page delay best estate rapid shrug fury song admit budget output feel connect clinic'
            .split(' ');
    createWalletProvider.setPassphrase(passphrase);
    await tester.pumpWidget(testWrapper(const ConfirmPassPhraseScreen(),
        mockProvider: createWalletProvider));
    await tester.pump();
    final createWalletButton = find.byType(WalletButton);
    expect(tester.widget<WalletButton>(createWalletButton).onPressed, null);
    for (var i = 0; i < 12; i++) {
      await tester.ensureVisible(find.byKey(Key('option-$i')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('option-$i')));
      await tester.pumpAndSettle();
    }
    expect(
        tester.widget<WalletButton>(createWalletButton).onPressed, isNotNull);
  });

  testWidgets(
      'ConfirmPassphraseScreen - should throw error when words are filed in mismatched order',
      (WidgetTester tester) async {
    String password = '12345678';
    const MethodChannel channel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        return password;
      }
      return {};
    });
    final passphrase =
        'truth charge tilt you ladder begin toast ice donkey ugly recall traffic'
            .split(' ');
    final createWalletProvider =
        CreateWalletProvider(const FlutterSecureStorage());
    createWalletProvider.setPassphrase(passphrase);
    await tester.pumpWidget(testWrapper(const ConfirmPassPhraseScreen(),
        mockProvider: createWalletProvider));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      final optionKey = find.text(passphrase[i]);
      await tester.ensureVisible(optionKey);
      await tester.pumpAndSettle();
      await tester.tap(optionKey);
      await tester.pumpAndSettle();
    }

    final wordBeforeLast = find.text('traffic');
    await tester.ensureVisible(wordBeforeLast);
    await tester.pumpAndSettle();
    await tester.tap(wordBeforeLast);
    await tester.pumpAndSettle();

    final lastWord = find.text('recall');
    await tester.ensureVisible(lastWord);
    await tester.pumpAndSettle();
    await tester.tap(lastWord);
    await tester.pumpAndSettle();

    final createWalletButton = find.byType(WalletButton);
    await tester.ensureVisible(createWalletButton);
    await tester.pumpAndSettle();
    await tester.tap(createWalletButton);
    await tester.pumpAndSettle();
    expect(find.text('invalid mnemonic'), findsOneWidget);
    await expectLater(find.byType(ConfirmPassPhraseScreen),
        matchesGoldenFile('snapshot_test.png'));
  });

  testWidgets(
      'ConfirmPassphraseScreen - should create wallet when words are filed in original order',
      (WidgetTester tester) async {
    String password = '12345678';
    const MethodChannel channel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        return password;
      }
      return {};
    });
    Hive.init(".");
    final passphrase =
        'truth charge tilt you ladder begin toast ice donkey ugly recall traffic'
            .split(' ');
    final createWalletProvider = MockCreateWalletProvider();
    createWalletProvider.setPassword(password);
    createWalletProvider.setPassphrase(passphrase);
    when(createWalletProvider.getPassphrase()).thenReturn(passphrase);
    when(createWalletProvider.getPassword()).thenReturn(password);
    await tester.pumpWidget(testWrapper(const ConfirmPassPhraseScreen(),
        mockProvider: createWalletProvider));
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      final optionKey = find.text(passphrase[i]);
      await tester.ensureVisible(optionKey);
      await tester.pumpAndSettle();
      await tester.tap(optionKey);
      await tester.pumpAndSettle();
    }
    final createWalletButton = find.byType(WalletButton);
    await tester.ensureVisible(createWalletButton);
    await tester.pumpAndSettle();
    await tester.tap(createWalletButton);
    await tester.pumpAndSettle();
  });
}
