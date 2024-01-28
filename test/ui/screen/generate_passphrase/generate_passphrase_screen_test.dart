import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_cryptomask/ui/screens/confirm_passphrase/confirm_passphrase_screen.dart';
import 'package:wallet_cryptomask/ui/screens/generate_passphrase/generate_passphrase_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/utils/test_utils.dart';

void main() {
  testWidgets('GeneratePassphraseScreen - should render correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const GeneratePassPhraseScreen()));
    await tester.pump();

    expect(find.text('Write down your Secret Recovery Phrase'), findsOneWidget);
    expect(
        find.text(
            'This is your Secret RecoveryPhrase. Write it down on a paper and keep it in a safe place. You\'ll be asked to re-enter this phrase (in order) on the next step'),
        findsOneWidget);
    expect(
        find.text('Tap to reveal you Secret Recovery Phrase'), findsOneWidget);
    expect(
        find.text('Make sure no one is watching your screen'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets(
      'GeneratePassphraseScreen - should show Secret Recovery Phrase when taping on View button',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const GeneratePassPhraseScreen()));
    await tester.pump();

    final viewButton = find.text('View');
    await tester.tap(viewButton);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('passphrase-grid-view')), findsOneWidget);
  });

  testWidgets(
      'GeneratePassphraseScreen - should disable create wallet button when Secret Recovery Phrase is not viewed',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const GeneratePassPhraseScreen()));
    await tester.pump();

    final continueButton = find.byType(WalletButton);
    expect(tester.widget<WalletButton>(continueButton).onPressed, null);

    final viewButton = find.text('View');
    await tester.tap(viewButton);
    await tester.pumpAndSettle();
    expect(tester.widget<WalletButton>(continueButton).onPressed, isNotNull);
  });

  testWidgets(
      'GeneratePassphraseScreen - should navigate to ConfirmPasswordScreen when Secret Recovery Phrase is viewed',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const GeneratePassPhraseScreen()));
    await tester.pump();

    final continueButton = find.byType(WalletButton);
    expect(tester.widget<WalletButton>(continueButton).onPressed, null);

    final viewButton = find.text('View');
    await tester.tap(viewButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.byType(ConfirmPassPhraseScreen), findsOneWidget);
  });

  testWidgets('GeneratePassphraseScreen - should match snapshot',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWrapper(const GeneratePassPhraseScreen()));
    await tester.pump();
    await expectLater(find.byType(GeneratePassPhraseScreen),
        matchesGoldenFile('snapshot_test.png'));
  });
}
