// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/contact_provider/contact_provider.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/collectible_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/remote/response-model/register_user.dart';
import 'package:wallet_cryptomask/core/remote/response-model/settings_response.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/screens/amount-screen/amount_screen.dart';
import 'package:wallet_cryptomask/ui/screens/chat_screen/chat_screen.dart';
import 'package:wallet_cryptomask/ui/screens/home-screen/widgets/account_change_sheet.dart';
import 'package:wallet_cryptomask/ui/shared/avatar_widget.dart';
import 'package:wallet_cryptomask/ui/screens/scanner-screen/scanner_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

import '../contacts-screen/widgets/contact_tile.dart';

class TransferScreen extends StatefulWidget {
  static const route = "transfer_screen";
  String balance;
  final Token? token;
  final Collectible? collectible;
  TransferScreen(
      {Key? key, required this.balance, this.token, this.collectible})
      : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with SingleTickerProviderStateMixin {
  bool isAddressValid = false;
  TabController? tabContoller;

  final TextEditingController _address = TextEditingController();
  List<dynamic> recentTransactionAddress = [];
  final user = Get.find<User>();
  final settings = Get.find<Settings>();

  @override
  void initState() {
    tabContoller = TabController(length: 3, vsync: this);

    Hive.openBox("user_preference").then((box) {
      setState(() {
        recentTransactionAddress =
            box.get("RECENT-TRANSACTION-ADDRESS", defaultValue: []);
      });
    });

    super.initState();
  }

  onCancelHandler() async {
    Navigator.of(context).pop();
  }

  onAccountChangeHandler() {
    showModalBottomSheet(
        context: context, builder: (context) => const AccountChangeSheet());
  }

  onClearTextHandler() {
    _address.text = "";
    setState(() {
      isAddressValid = false;
    });
  }

  onQrPressHandler() {
    context.push(() => ScannerScreen(onQrDecode: (address) {
          Navigator.of(context).pop();

          _address.text = address;
          setState(() {
            isAddressValid = true;
          });
        }));
  }

  onAccountSelectHandler(address) {
    _address.text = address;
    setState(() {
      isAddressValid = true;
    });
  }

  onNextHandler() {
    if (widget.token != null) {
      context.push(
        () => AmountScreen(
            balance: double.parse(widget.balance),
            to: _address.text,
            token: widget.token!,
            from: Provider.of<WalletProvider>(context, listen: false)
                .activeWallet
                .wallet
                .privateKey
                .address
                .hex),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          shadowColor: Colors.white,
          elevation: 0,
          backgroundColor: Colors.white,
          title: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const WalletText(
                    localizeKey: 'to',
                    size: 16,
                    fontWeight: FontWeight.w200,
                    color: Colors.black),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                          color: Provider.of<WalletProvider>(context)
                              .activeNetwork
                              .dotColor,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    addWidth(SpacingSize.xs),
                    Text(
                      Provider.of<WalletProvider>(context)
                          .activeNetwork
                          .networkName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: 12,
                          color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
          leading: const IconButton(
              onPressed: null,
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              )),
          actions: [
            TextButton(
              onPressed: onCancelHandler,
              style: ButtonStyle(
                overlayColor: WidgetStateColor.resolveWith(
                    (states) => kPrimaryColor.withAlpha(30)),
              ),
              child:
                  const WalletText(localizeKey: 'cancel', color: kPrimaryColor),
            )
          ]),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                addHeight(SpacingSize.m),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const WalletText(localizeKey: 'from'),
                      addWidth(SpacingSize.s),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                  width: 1, color: Colors.grey.withAlpha(60))),
                          child: Row(
                            children: [
                              AvatarWidget(
                                radius: 40,
                                address: Provider.of<WalletProvider>(context)
                                    .activeWallet
                                    .wallet
                                    .privateKey
                                    .address
                                    .hex,
                              ),
                              addWidth(SpacingSize.s),
                              Expanded(
                                child: InkWell(
                                  onTap: onAccountChangeHandler,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Provider.of<WalletProvider>(context)
                                            .getAccountName(),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                          "${getText(context, key: 'balance')}: ${Provider.of<WalletProvider>(context).getNativeBalanceFormatted()}"),
                                    ],
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down)
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                addHeight(SpacingSize.s),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const WalletText(localizeKey: 'to'),
                      addWidth(SpacingSize.s),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _address,
                                onChanged: (enteredAdress) {
                                  setState(() {
                                    isAddressValid =
                                        isValidAddress(enteredAdress) &&
                                            enteredAdress.length == 42;
                                  });
                                },
                                validator: (String? string) {
                                  if (string?.isEmpty == true) {
                                    return getText(context,
                                        key: 'thisFieldNotEmpty');
                                  }
                                  if (string!.length != 42) {
                                    return getText(context,
                                        key: 'passwordMustContain');
                                  }
                                  return null;
                                },
                                cursorColor: kPrimaryColor,
                                decoration: InputDecoration(
                                    hintText: getText(context,
                                        key: 'searchPublicAddress'),
                                    hintStyle: const TextStyle(fontSize: 12),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 20),
                                    suffixIcon: isAddressValid
                                        ? SizedBox(
                                            width: 65,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 20,
                                                ),
                                                addWidth(SpacingSize.xs),
                                                InkWell(
                                                  onTap: onClearTextHandler,
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.black,
                                                    size: 20,
                                                  ),
                                                ),
                                                addWidth(SpacingSize.xs),
                                              ],
                                            ),
                                          )
                                        : IconButton(
                                            onPressed: onQrPressHandler,
                                            icon: const Icon(
                                              Icons.qr_code,
                                              color: kPrimaryColor,
                                            ),
                                          ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.withAlpha(70))),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: kPrimaryColor)),
                                    errorBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: kPrimaryColor)),
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide())),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                addHeight(SpacingSize.s),
                TabBar(
                  tabs: [
                    Tab(
                      text: getText(context, key: 'myContacts'),
                    ),
                    Tab(
                      text: getText(context, key: 'myAccount'),
                    ),
                    Tab(
                      text: getText(context, key: 'recent'),
                    ),
                  ],
                  controller: tabContoller,
                ),
                Expanded(
                    child: TabBarView(controller: tabContoller, children: [
                  ListView.builder(
                      itemCount:
                          getContactProviderLive(context).contacts.length,
                      itemBuilder: (context, index) {
                        final contact =
                            getContactProviderLive(context).contacts[index];
                        return ContactTile(
                            key: Key(contact.address),
                            name: contact.name,
                            address: contact.address,
                            network: "",
                            id: contact.id,
                            mode: "SELECT",
                            onChoose: (address) {
                              _address.text = address;
                              setState(() {
                                isAddressValid = true;
                              });
                            });
                      }),
                  ListView.builder(
                    itemCount:
                        Provider.of<WalletProvider>(context).wallets.length,
                    itemBuilder: ((context, index) => Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1,
                                      color: Colors.grey.withAlpha(70)))),
                          child: ListTile(
                            onTap: () {
                              onAccountSelectHandler(
                                  Provider.of<WalletProvider>(context,
                                          listen: false)
                                      .wallets[index]
                                      .wallet
                                      .privateKey
                                      .address
                                      .hex);
                            },
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 16),
                            title: Text(showEllipse(
                                Provider.of<WalletProvider>(context)
                                    .wallets[index]
                                    .wallet
                                    .privateKey
                                    .address
                                    .hex)),
                            leading: AvatarWidget(
                                radius: 30,
                                address: Provider.of<WalletProvider>(context)
                                    .wallets[index]
                                    .wallet
                                    .privateKey
                                    .address
                                    .hex),
                          ),
                        )),
                  ),
                  recentTransactionAddress.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            addHeight(SpacingSize.xxxl),
                            const WalletText(
                              localizeKey: 'noRecent',
                            )
                          ],
                        )
                      : ListView.builder(
                          itemCount: recentTransactionAddress.length,
                          itemBuilder: ((context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey.withAlpha(70)))),
                              child: ListTile(
                                onTap: () => onAccountSelectHandler(
                                    recentTransactionAddress[index]),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 16),
                                title: Text(showEllipse(
                                    recentTransactionAddress[index])),
                                leading: AvatarWidget(
                                  radius: 30,
                                  address: recentTransactionAddress[index],
                                ),
                              ),
                            );
                          }),
                        )
                ])),
                user.isTransactionBlocked
                    ? renderAlert(context, 'contactAdmin', () {
                        context.push(() => const ChatScreen());
                      }, localizeKey: 'adminBlockYourTransaction')
                    : SafeArea(
                        child: WalletButton(
                            type: WalletButtonType.filled,
                            localizeKey: 'next',
                            onPressed: isAddressValid ? onNextHandler : null),
                      ),
                addHeight(SpacingSize.xl)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
