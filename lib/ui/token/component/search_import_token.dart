import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/token-bloc/cubit/token_cubit.dart';
import 'package:wallet_cryptomask/core/bloc/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/core.dart';
import 'package:wallet_cryptomask/core/cubit_helper.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/ui/home/component/avatar_component.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class TopTokens extends StatefulWidget {
  const TopTokens({Key? key}) : super(key: key);

  @override
  State<TopTokens> createState() => _TopTokensState();
}

class _TopTokensState extends State<TopTokens> {
  TextEditingController searchToken = TextEditingController();
  Token? selectedToken;

  @override
  void initState() {
    searchToken.addListener(() {});
    super.initState();
  }

  onImportHandler() {
    Provider.of<WalletProvider>(context, listen: false).showLoading();
    Provider.of<TokenProvider>(context, listen: false)
        .addToken(
            address: Provider.of<WalletProvider>(context, listen: false)
                .activeWallet
                .wallet
                .privateKey
                .address
                .hex,
            network: Provider.of<WalletProvider>(context, listen: false)
                .activeNetwork,
            token: selectedToken!)
        .then((value) {
      Provider.of<WalletProvider>(context, listen: false).hideLoading();
      Navigator.of(context).pop();
      showPositiveSnackBar(context, 'Imported', 'Token imported successfully');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<WalletProvider>(context, listen: false)
            .activeNetwork
            .isMainnet
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              addHeight(SpacingSize.s),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context)!.top20Token,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              addHeight(SpacingSize.xs),
              Expanded(
                  child: ListView.builder(
                      itemCount: Core.topERC20Tokens.length,
                      itemBuilder: (context, index) => Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color: selectedToken?.tokenAddress ==
                                          Core.topERC20Tokens[index]
                                              .tokenAddress
                                      ? kPrimaryColor
                                      : Colors.grey.withAlpha(60)),
                              borderRadius: BorderRadius.circular(10),
                              color: selectedToken?.tokenAddress ==
                                      Core.topERC20Tokens[index].tokenAddress
                                  ? kPrimaryColor.withAlpha(70)
                                  : Colors.transparent,
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              onTap: () {
                                setState(() {
                                  selectedToken = Core.topERC20Tokens[index];
                                });
                              },
                              leading: AvatarWidget(
                                  radius: 40,
                                  imageUrl: Core.topERC20Tokens[index].imageUrl,
                                  address:
                                      Core.topERC20Tokens[index].tokenAddress),
                              title: Text(Core.topERC20Tokens[index].symbol),
                            ),
                          ))),
              addHeight(SpacingSize.xs),
              Consumer<WalletProvider>(
                builder: (context, value, child) {
                  if (value.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return WalletButton(
                      type: WalletButtonType.filled,
                      localizeKey: 'importToken',
                      onPressed:
                          selectedToken != null ? onImportHandler : null);
                },
              ),
              addHeight(SpacingSize.s),
            ],
          )
        : Center(
            child: Text(AppLocalizations.of(context)!.thisFeatureInMainnet),
          );
  }
}
