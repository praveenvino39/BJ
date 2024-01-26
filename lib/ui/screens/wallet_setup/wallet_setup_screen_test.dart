// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/mock/mock.dart';
import 'package:wallet_cryptomask/ui/onboard/component/create-password/bloc/create_wallet_cubit.dart';
import 'package:wallet_cryptomask/ui/screens/wallet_setup/wallet_setup_screen.dart';
import 'package:wallet_cryptomask/utils/test_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('WalletSetupScreen - should render correctly',
      (WidgetTester tester) async {
    when(mockCreateWalletCubit.state).thenReturn(CreateWalletInitial());
    await tester.pumpWidget(testWrapper(const WalletSetupScreen()));
    await tester.pump();

    expect(find.text(appName), findsOneWidget);
    expect(find.text('Wallet setup'), findsOneWidget);
    expect(find.text('Import an existing wallet or create a new one'),
        findsOneWidget);
    expect(find.text('Import using Secret Recovery Phrase'), findsOneWidget);
    expect(find.text('Create a new wallet'), findsOneWidget);
  });

  // testWidgets(
  //     'WalletSetupScreen - should navigate to WalletSetupScreen when Get Started Button is clicked',
  //     (WidgetTester tester) async {
  //   await tester.pumpWidget(testWrapper(const WalletSetupScreen()));
  //   await tester.pump();

  //   var importButton = find.text('Import using Secret Recovery Phrase');
  //   await tester.tap(importButton);
  //   await tester.pumpAndSettle();
  //   expect(find.byType(ImportAccount), findsOneWidget);
  // });

  // testWidgets('WalletSetupScreen - should match snapshot',
  //     (WidgetTester tester) async {
  //   await tester.pumpWidget(testWrapper(const WalletSetupScreen()));
  //   await tester.pump();
  //   await expectLater(
  //       find.byType(WalletSetupScreen), matchesGoldenFile('snapshot_test.png'));
  // });
}
