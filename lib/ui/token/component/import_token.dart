import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/collectible-bloc/cubit/collectible_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/ui/token/component/custom_token.dart';
import 'package:wallet/ui/token/component/search_import_token.dart';

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
    return BlocConsumer<CollectibleCubit, CollectibleState>(
      listener: (context, state) {},
      builder: (context, state) {
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
                      const Text("Import tokens",
                          style: TextStyle(
                              fontWeight: FontWeight.w200,
                              color: Colors.black)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                color: getWalletLoadedState(context)
                                    .currentNetwork
                                    .dotColor,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            getWalletLoadedState(context)
                                .currentNetwork
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
                      text: "SEARCH",
                    ),
                    Tab(
                      text: "CUSTOM TOKEN",
                    )
                  ]),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  const SearchImportToken(),
                  CustomToken(
                    state: getWalletLoadedState(context),
                  )
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
