import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/remote/http.dart';
import 'package:wallet/core/remote/response-model/transaction_log_result.dart';
import 'package:wallet/ui/block-web-view/block_web_view.dart';
import 'package:wallet/ui/transaction-history/widget/transaction_tile.dart';
import 'package:wallet/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TransactionHistoryScreen extends StatefulWidget {
  static const route = "transaction_history_screen";
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
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
                      const Text("Transaction history",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                              color: Colors.black)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                color: (state as WalletLoaded)
                                    .currentNetwork
                                    .dotColor,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            state.currentNetwork.networkName,
                            style:const  TextStyle(
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
          body: RefreshIndicator(
            color: kPrimaryColor,
            onRefresh: () async => getTransactionLog(
                state.wallet.privateKey.address.hex, state.currentNetwork),
            child: FutureBuilder<List<TransactionResult>?>(
              future: getTransactionLog(
                  state.wallet.privateKey.address.hex, state.currentNetwork),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                    itemCount: snapshot.data?.length,
                                    itemBuilder: (context, index) {
                                      var date =
                                          DateTime.fromMicrosecondsSinceEpoch(
                                              int.parse(snapshot
                                                      .data![index]
                                                      .timeStamp) *
                                                  1000000);
                                      return TransactionTile(date: date, data: snapshot.data![index]);
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        BlockWebView.router,
                                        arguments: {
                                          "title": state
                                              .currentNetwork
                                              .networkName,
                                          "url": viewAddressOnEtherScan(
                                              state.currentNetwork,
                                              state.wallet.privateKey.address
                                                  .hex)
                                        });
                                  },
                                  child:const  Text(
                                    "View full history on Explorer",
                                    style: TextStyle(color: kPrimaryColor),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : Center(
                          child: Text(
                            AppLocalizations.of(context)!.youHaveNoTransaction,
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
