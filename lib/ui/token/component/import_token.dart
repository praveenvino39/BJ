import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/collectible-bloc/cubit/collectible_cubit.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/cubit_helper.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/token/component/custom_token.dart';
import 'package:wallet_cryptomask/ui/token/component/search_import_token.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class ImportTokenScreen extends StatefulWidget {
  static const String route = "import_token_screen";
  const ImportTokenScreen({Key? key}) : super(key: key);

  @override
  State<ImportTokenScreen> createState() => _ImportTokenScreenState();
}

class _ImportTokenScreenState extends State<ImportTokenScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 70, 10),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Column(
                children: [
                  const WalletText(
                    '',
                    localizeKey: "Import tokens",
                    textVarient: TextVarient.body1,
                    fontWeight: FontWeight.w200,
                  ),
                  addHeight(SpacingSize.xs),
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
                      WalletText(
                        '',
                        localizeKey: Provider.of<WalletProvider>(context)
                            .activeNetwork
                            .networkName,
                        textVarient: TextVarient.body3,
                        fontWeight: FontWeight.w100,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
              controller: _tabController,
              labelColor: kPrimaryColor,
              indicatorColor: kPrimaryColor,
              labelStyle: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(
                  text: "Top Tokens",
                ),
                Tab(
                  text: "CUSTOM TOKEN",
                )
              ]),
          Expanded(
            child: TabBarView(controller: _tabController, children: const [
              TopTokens(),
              // SizedBox()
              CustomToken()
            ]),
          ),
        ],
      ),
    );
  }
}
