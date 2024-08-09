import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_transaction_response.dart';
import 'package:wallet_cryptomask/ui/screens/block-web-view-screen/block_web_view.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/screens/transaction-history-screen/widget/transaction_tile.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

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
                      localizeKey: 'transactionHistory',
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
                            // color: (state as WalletLoaded)
                            //     .currentNetwork
                            //     .dotColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      addWidth(SpacingSize.xs),
                      WalletText(
                        localizeKey: Provider.of<WalletProvider>(context)
                            .getAccountName(),
                        textVarient: TextVarient.body3,
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
        onRefresh: () async => getTokenProvider(context).getTransactions(
            address: Provider.of<WalletProvider>(context)
                .activeWallet
                .wallet
                .privateKey
                .address
                .hex,
            network: Provider.of<WalletProvider>(context).activeNetwork),
        child: FutureBuilder<List<MoralisTransaction>>(
          future: getTokenProvider(context).getTransactions(
              address: Provider.of<WalletProvider>(context)
                  .activeWallet
                  .wallet
                  .privateKey
                  .address
                  .hex,
              network: Provider.of<WalletProvider>(context).activeNetwork),
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
                                  // Define the format of the input date string
                                  DateFormat dateFormat = DateFormat(
                                      "EEE MMM dd yyyy HH:mm:ss 'GMT'Z");

                                  // Parse the date string to DateTime
                                  DateTime date = dateFormat.parse(
                                      snapshot.data![index].blockTimestamp
                                          .replaceAll(
                                              RegExp(r' \([^)]*\)'), ''),
                                      true);

                                  return TransactionTile(
                                      date: date, data: snapshot.data![index]);
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                context.push(
                                  () => BlockWebView(
                                      title: getWalletProvider(context)
                                          .activeNetwork
                                          .networkName,
                                      url: viewAddressOnEtherScan(
                                          getWalletProvider(context)
                                              .activeNetwork,
                                          getWalletProvider(context)
                                              .activeWallet
                                              .wallet
                                              .privateKey
                                              .address
                                              .hex)),
                                );
                              },
                              child: const SafeArea(
                                child: WalletText(
                                    localizeKey: 'viewFullHistory',
                                    color: kPrimaryColor),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : const Center(
                      child: WalletText(
                          localizeKey: 'youHaveNoTransaction',
                          size: 18,
                          color: Colors.grey),
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
  }
}
