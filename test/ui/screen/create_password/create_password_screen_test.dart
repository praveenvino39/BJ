import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_cryptomask/core/create_wallet_provider/create_wallet_provider.dart';
import 'package:wallet_cryptomask/ui/screens/create_password/create_password_screen.dart';
import 'package:wallet_cryptomask/ui/screens/generate_passphrase/generate_passphrase_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/utils/test_utils.dart';

void main() {
  testWidgets('CreatePasswordScreen - should render correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const CreatePasswordScreen()));
    await tester.pump();

    expect(find.byKey(const Key('circle-stepper')), findsOneWidget);
    expect(find.byKey(const Key('create-password-text')), findsOneWidget);
    expect(
        find.text('This password will unlock your wallet only on this device.'),
        findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byKey(const Key('terms-agreement-section')), findsOneWidget);
    expect(find.byKey(const Key('create-wallet-button')), findsOneWidget);
  });

  testWidgets(
      'CreatePasswordScreen - should throw error when password and confirm password field is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const CreatePasswordScreen()));
    await tester.pump();
    final passwordTextField = find.byKey(const Key('password-text-field'));
    final confirmTextField =
        find.byKey(const Key('confirm-password-text-field'));
    await tester.enterText(passwordTextField, '');
    await tester.enterText(confirmTextField, '');
    await tester.pump();

    var createPasswordButton = find.byKey(const Key('create-wallet-button'));
    await tester.ensureVisible(createPasswordButton);
    await tester.pumpAndSettle();
    await tester.tap(createPasswordButton);
    await tester.pumpAndSettle();

    expect(find.text('This filed shouldn\'t be empty'), findsWidgets);
  });

  testWidgets(
      'CreatePasswordScreen - should throw error when terms is not accepted',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const CreatePasswordScreen()));
    await tester.pump();
    final passwordTextField = find.byKey(const Key('password-text-field'));
    final confirmTextField =
        find.byKey(const Key('confirm-password-text-field'));
    await tester.enterText(passwordTextField, '12345678');
    await tester.enterText(confirmTextField, '12345678');
    await tester.pump();

    var createPasswordButton = find.byType(WalletButton);
    await tester.ensureVisible(createPasswordButton);
    await tester.pumpAndSettle();
    await tester.tap(createPasswordButton);
    await tester.pump();

    expect(
        find.text('You must to accept the terms and condition to use Phimask'),
        findsOneWidget);
  });

  testWidgets(
      'CreatePasswordScreen - should navigate to GeneratePassphraseScreen when the form is valid',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const CreatePasswordScreen(),
        mockProvider: CreateWalletProvider(const FlutterSecureStorage())));
    await tester.pump();
    final passwordTextField = find.byKey(const Key('password-text-field'));
    final confirmTextField =
        find.byKey(const Key('confirm-password-text-field'));
    await tester.enterText(passwordTextField, '12345678');
    await tester.enterText(confirmTextField, '12345678');
    await tester.tap(find.byType(Checkbox));

    await tester.pump();

    var createPasswordButton = find.byType(WalletButton);
    await tester.ensureVisible(createPasswordButton);
    await tester.pumpAndSettle();
    await tester.tap(createPasswordButton);
    await tester.pumpAndSettle();

    expect(find.byType(GeneratePassPhraseScreen), findsOneWidget);
  });

  testWidgets('CreatePasswordScreen - should match snapshot',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const CreatePasswordScreen()));
    await tester.pump();
    await expectLater(find.byType(CreatePasswordScreen),
        matchesGoldenFile('snapshot_test.png'));
  });
}
