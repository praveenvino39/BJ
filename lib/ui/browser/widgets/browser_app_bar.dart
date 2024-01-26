import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/cubit_helper.dart';
import 'package:wallet_cryptomask/ui/browser/model/web_view_model.dart';
import 'package:wallet_cryptomask/ui/browser/widgets/browser_url_field.dart';
import 'package:wallet_cryptomask/ui/home/component/account_change_sheet.dart';
import 'package:wallet_cryptomask/ui/home/component/avatar_component.dart';
import 'package:wallet_cryptomask/ui/shared/chain_change_sheet.dart';
// import 'package:wallet_cryptomask/ui/shared/chain_change_sheet.dart';

class BrowserUrlBar extends StatefulWidget {
  final Function(String, WebViewModel) onUrlSubmit;
  final bool? certified;
  final String url;
  final Function() openDrawer;
  final WebViewModel webViewModel;
  const BrowserUrlBar(
      {super.key,
      required this.webViewModel,
      required this.onUrlSubmit,
      required this.certified,
      required this.url,
      required this.openDrawer});

  @override
  State<BrowserUrlBar> createState() => _BrowserUrlBarState();
}

class _BrowserUrlBarState extends State<BrowserUrlBar> {
  double actionContainerWidth = 0;
  FocusNode urFocusNode = FocusNode();
  bool enableClear = false;
  TextEditingController urlController = TextEditingController();
  bool showUrl = false;
  OutlineInputBorder outlineBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: BorderRadius.all(
      Radius.circular(50.0),
    ),
  );

  @override
  void initState() {
    context.read<WebViewModel>().addListener(() {
      urlController.text = context.read<WebViewModel>().url.toString();
      urFocusNode.addListener(() {
        setState(() {
          enableClear = urFocusNode.hasFocus;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        if (state is WalletLoaded) {
          return Column(
            children: [
              AppBar(
                elevation: 0,
                foregroundColor: kPrimaryColor,
                backgroundColor: Colors.white,
                centerTitle: true,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: (() {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const AccountChangeSheet(
                            // from: "BROWSER",
                            ),
                      );
                    }),
                    child: AvatarWidget(
                        radius: 30,
                        address: state.wallet.privateKey.address.hex),
                  ),
                ),
                actions: [
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: (() {
                      showDialog(
                        context: context,
                        builder: (context) => const ChainChangeSheet(
                            // from: "BROWSER",
                            ),
                      );
                    }),
                    child: Image.asset(
                      getWalletLoadedState(context).currentNetwork.logo,
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
                title: _buildSearchTextField(),
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: kPrimaryColor,
              )
            ],
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  // Widget? _buildAppBarHomePageWidget() {
  //   return InkWell(
  //     onTap: () {
  //       showDialog(
  //           context: context, builder: (context) => const ChainChangeSheet());
  //     },
  //     child: const Center(
  //       child: AvatarWidget(
  //           radius: 30, address: "", imageUrl: "assets/images/coin.png"),
  //     ),
  //   );
  // }

  Widget _buildSearchTextField() {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is WalletLoaded) {
          return SizedBox(
              // height: 40.0,
              child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => BrowserUrlField(
                    onUrlSubmit: widget.onUrlSubmit,
                    webViewModel: widget.webViewModel,
                    certified: widget.certified,
                    url: widget.url),
              ));
            },
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        urlController.text.toString().contains(
                                "file:///android_asset/flutter_assets/assets/html/homepage.html")
                            ? "home.egon.wallet"
                            : Uri.parse(urlController.text).authority,
                        overflow: TextOverflow.fade,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.black),
                      ),
                      const Icon(
                        Icons.lock,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  // const SizedBox(height: 10,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NetworkDot(
                        color: state.currentNetwork.dotColor,
                        radius: 10,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        state.currentNetwork.networkName,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const NetworkDot(
                        color: Colors.transparent,
                        radius: 10,
                      ),
                    ],
                  ),
                ]),
          ));
        }
        return const Center(
          child: CircularProgressIndicator(
            color: kPrimaryColor,
          ),
        );
      },
    );
  }
}
