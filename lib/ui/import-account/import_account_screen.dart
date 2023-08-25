import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/ui/home/home_screen.dart';
import 'package:wallet/ui/onboard/component/create-password/bloc/create_wallet_cubit.dart';
import 'package:wallet/ui/shared/wallet_button.dart';

class ImportAccount extends StatefulWidget {
  static const route = "import_account";
  const ImportAccount({Key? key}) : super(key: key);

  @override
  State<ImportAccount> createState() => _ImportAccountState();
}

class _ImportAccountState extends State<ImportAccount> {
  final TextEditingController _passphrase = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _privateKeyFormKey = GlobalKey();
  final TextEditingController _privateKey = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateWalletCubit, CreateWalletState>(
            listener: (context, state) {
          if (state is CreateWalletSuccess) {
            Navigator.pushNamedAndRemoveUntil(
                context, HomeScreen.route, (route) => false,
                arguments: {"password": _password.text});
          }
        })
      ],
      child: BlocConsumer<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state is WalletImported) {
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
              content: Row(
                children: const [
                  Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Account imported",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              backgroundColor: Colors.green,
            ));
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.of(context).pop();
            });
          }
        },
        builder: (context, state) {
          if (state is WalletLoaded) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
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
                        "Import account",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              body: Form(
                key: _privateKeyFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Privatekey"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: _privateKey,
                        validator: (String? string) {
                          if (string!.isEmpty) {
                            return "Privakey shouldn't be empty";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            hintText: "Enter Privatekey",
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kPrimaryColor)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kPrimaryColor)),
                            border:
                                OutlineInputBorder(borderSide: BorderSide())),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    WalletButton(
                        type: WalletButtonType.filled,
                        textContent: "Import account",
                        onPressed: () {
                          if (_privateKeyFormKey.currentState!.validate()) {
                            context
                                .read<WalletCubit>()
                                .importAccountFromPrivateKey(_privateKey.text,
                                    onsuccess: () {
                              Navigator.of(context).pop();
                            }, alreadyExist: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("You're trying to import account that already exist"),
                                backgroundColor: Colors.red,
                              ));
                            });
                          }
                        }),
                    const SizedBox(
                      height: 170,
                    )
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
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
                      "Import account",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Secret Recovery Phrase"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _passphrase,
                      validator: (String? string) {
                        if (string!.isEmpty) {
                          return "Passphrase shouldn't be empty";
                        }
                        if (string.trim().split(" ").length != 12) {
                          return "Invalid passphrase";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          hintText: "Enter your Secret Recovery Pharse",
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor)),
                          border: OutlineInputBorder(borderSide: BorderSide())),
                    ),
                  ),
                  state is! WalletLoaded
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Password"),
                        )
                      : const SizedBox(),
                  state is! WalletLoaded
                      ? const SizedBox(
                          height: 10,
                        )
                      : const SizedBox(),
                  state is! WalletLoaded
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _password,
                            validator: (String? string) {
                              if (string!.isEmpty) {
                                return "Password shouldn't be empty";
                              }
                              if (string.length < 8) {
                                return "Password atleast contain 8 character";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                hintText: "Enter new password",
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kPrimaryColor)),
                                errorBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kPrimaryColor)),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide())),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 20,
                  ),
                  WalletButton(
                      type: WalletButtonType.filled,
                      textContent: "Import Wallet",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (state is WalletLoaded) {
                            context.read<WalletCubit>().createNewAccount(
                                _passphrase.text,
                                isImported: true);
                          } else {
                            context
                                .read<CreateWalletCubit>()
                                .createWalletFromPassPhrase(
                                    _passphrase.text, _password.text);
                          }
                        }
                      }),
                  const SizedBox(
                    height: 170,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
