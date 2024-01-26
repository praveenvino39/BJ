import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/ui/home/home_screen.dart';
import 'package:wallet_cryptomask/ui/onboard/component/circle_stepper.dart';
import 'package:wallet_cryptomask/ui/onboard/component/confirm-passphrase/confirm_passphrase.dart';
import 'package:wallet_cryptomask/ui/onboard/component/create-password/create_password_component.dart';
import 'package:wallet_cryptomask/ui/onboard/component/setup-passpharse/setup_passphrase_screen.dart';

import '../../constant.dart';
import '../onboard/component/create-password/bloc/create_wallet_cubit.dart';

class CreateWalletScreen extends StatefulWidget {
  static String route = "create_wallet_screen";

  const CreateWalletScreen({Key? key}) : super(key: key);

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  int currentIndex = 0;
  List<String> passphrase = [];
  String password = "";

  nextStep() {
    setState(() {
      currentIndex += 1;
    });
  }

  getPassphrase(List<String> newPhasephrase) {
    setState(() {
      passphrase = newPhasephrase;
    });
  }

  getPassword(String newPassword) {
    setState(() {
      password = newPassword;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return BlocConsumer<CreateWalletCubit, CreateWalletState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            title: const Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 70, 10),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    appName,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                        letterSpacing: 5),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleStepper(
                      currentIndex: currentIndex,
                    ),
                    Expanded(
                      child: BlocListener<CreateWalletCubit, CreateWalletState>(
                        listener: (context, state) {
                          if (state is CreateWalletSuccess) {
                            Navigator.pushNamed(context, HomeScreen.route,
                                arguments: {"password": password});
                          }
                        },
                        child: currentIndex == 0
                            ? CreatePasswordCmp(
                                onNext: nextStep,
                                getPassword: getPassword,
                              )
                            : currentIndex == 1
                                ? SetupPassphraseScreen(
                                    onNext: nextStep,
                                    getPassphrase: getPassphrase)
                                : ConfirmPassphrase(
                                    passpharse: passphrase,
                                    password: password,
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
