// ignore: depend_on_referenced_packages
// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_cryptomask/ui/onboard/component/create-password/bloc/create_wallet_cubit.dart';
import 'package:wallet_cryptomask/ui/screens/wallet_setup/wallet_setup_screen.dart';
import 'package:wallet_cryptomask/ui/screens/onboarding/onboard_screen.dart';
import 'package:wallet_cryptomask/utils/test_utils.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('OnboardScreen - should render correctly',
      (WidgetTester tester) async {
    final mockCreateWalletCubit = MockCreateWalletCubit();

    when(mockCreateWalletCubit.state).thenReturn(CreateWalletInitial());
    await tester.pumpWidget(testWrapper(const OnboardScreen(),
        mockProvider: mockCreateWalletCubit));
    // await tester.pump();

    // expect(find.byKey(const Key('app-name-text')), findsOneWidget);
    // expect(find.byKey(const Key('introduction-slides')), findsOneWidget);
    // expect(find.byKey(const Key('get-started-button')), findsOneWidget);
  });
  // testWidgets(
  //     'OnboardScreen - should navigate to WalletSetupScreen when Get Started Button is clicked',
  //     (WidgetTester tester) async {
  //   await tester.pumpWidget(testWrapper(const OnboardScreen()));
  //   await tester.pump();

  //   var getStartedButton = find.byKey(const Key('get-started-button'));
  //   await tester.tap(getStartedButton);
  //   await tester.pumpAndSettle();
  //   expect(find.byType(WalletSetupScreen), findsOneWidget);
  // });
  // testWidgets('OnboardScreen - should match snapshot',
  //     (WidgetTester tester) async {
  //   await tester.pumpWidget(testWrapper(const OnboardScreen()));
  //   await tester.pump();
  //   await expectLater(
  //       find.byType(OnboardScreen), matchesGoldenFile('snapshot_test.png'));
  // });
}
