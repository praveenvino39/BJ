// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'dart:developer' as debug_print;
import 'dart:math';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:wallet_cryptomask/core/ERC20.dart';
import 'package:wallet_cryptomask/core/abi.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/core.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:web3dart/web3dart.dart';

part 'token_state.dart';

class TokenCubit extends Cubit<TokenState> {
  final Box userPreferenceBox;
  late Web3Client web3client;
  // final Web3Client web3;
  TokenCubit({required this.userPreferenceBox}) : super(TokenInitial());

  setupWeb3Client(Web3Client web3client) {
    debug_print.log("TOKEN CLIENT SETUP DONE");
    this.web3client = web3client;
  }

  loadToken({required String address, required Network network}) async {
    debug_print.log("LOAD TOKEN INITIATED for $address");
    String tokenStorageKey =
        getTokenStorageKey(address: address, network: network);
    debug_print.log(tokenStorageKey);
    List<dynamic> tokens = userPreferenceBox.get(tokenStorageKey) ?? [];
    for (var token in tokens) {
      (token as Token).balance =
          (await getTokenBalance(token, address, network)).toDouble();
    }
    emit(TokenLoaded(tokens: tokens.cast<Token>()));
  }

  addToken(
      {required String address,
      required Network network,
      required Token token}) async {
    String tokenStoragekey =
        getTokenStorageKey(address: address, network: network);
    List<dynamic> tokens = userPreferenceBox.get(tokenStoragekey) ?? [];
    debug_print.log(tokenStoragekey);

    if (tokens.contains(token)) {
      emit(TokenAdded(tokens: tokens.cast<Token>()));
      return;
    }
    var tokenBalance = await getTokenBalance(token, address, network);
    token.balance = tokenBalance.toDouble();
    tokens.add(token);
    for (var tokenObj in Core.tokenList) {
      if ((tokenObj as dynamic)["symbol"].toString().toLowerCase() ==
          token.symbol.toLowerCase()) {
        token.coinGeckoID = (tokenObj as dynamic)["id"];
        break;
      }
    }
    debug_print.log(jsonEncode(token));
    userPreferenceBox.put(tokenStoragekey, tokens);
    emit(TokenAdded(tokens: tokens.cast<Token>()));
  }

  String getTokenStorageKey({required address, required Network network}) {
    return "TOKEN-$address-${network.networkName}";
  }

  sendTokenTransaction(
      String to,
      double value,
      int gasLimit,
      double selectedPriority,
      double selectedMaxFee,
      Token selectedToken,
      DeployedContract deployedContract,
      Wallet wallet,
      Network network) async {
    try {
      String tokenStorageKey = getTokenStorageKey(
          address: wallet.privateKey.address.hex, network: network);
      BigInt chainID = await web3client.getChainId();
      var sendResult = await web3client.sendTransaction(
          wallet.privateKey,
          Transaction(
            maxGas: gasLimit,
            gasPrice: network.chainId == 144
                ? EtherAmount.inWei(BigInt.parse("2"))
                : null,
            maxPriorityFeePerGas: network.supportsEip1559
                ? EtherAmount.fromUnitAndValue(
                    EtherUnit.wei, (selectedPriority * pow(10, 9)).toInt())
                : null,
            maxFeePerGas: network.supportsEip1559
                ? EtherAmount.fromUnitAndValue(
                    EtherUnit.wei, (selectedMaxFee * pow(10, 9)).toInt())
                : null,
            to: EthereumAddress.fromHex(selectedToken.tokenAddress),
            data: deployedContract.function("transfer").encodeCall([
              EthereumAddress.fromHex(to),
              BigInt.from((value * pow(10, selectedToken.decimal))),
            ]),
          ),
          chainId: chainID.toInt());
      debug_print.log("TRANSACTION RESULT ====> $sendResult");
      List<dynamic> tokensDy = userPreferenceBox.get(tokenStorageKey);
      WalletCubit.showTransactionStatus(sendResult, web3client);
      Hive.openBox("user_preference").then((box) {
        List<dynamic> recentAddresses =
            box.get("RECENT-TRANSACTION-ADDRESS", defaultValue: []);
        if (recentAddresses.contains(to)) {
          recentAddresses.remove(to);
        }
        recentAddresses.add(to);
        box.put("RECENT-TRANSACTION-ADDRESS", recentAddresses);
      });
      emit(TokenTransfered(tokens: tokensDy.cast<Token>()));
      debug_print.log(
          "$selectedPriority $selectedMaxFee TRANSACTION HASH $sendResult");
    } catch (e) {
      debug_print.log((e as dynamic).toString());
      emit(TokenError(error: e.toString()));
    }
  }

  swapToken({
    required String swapType,
    required Web3Client web3client,
    required String tokenFrom,
    required String tokenTo,
    required EtherAmount amount,
    required BigInt fee,
    required String recipient,
    required BigInt amountOut,
    required WalletLoaded currentState,
  }) async {
    try {
      const routerContractAddress =
          "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

      //APPROVING ROUTER TO TRANSACT FROM TOKEN
      Erc20 token = Erc20(
          address: EthereumAddress.fromHex(swapType == "ETH2TOKEN"
              ? currentState.currentNetwork.wrappedTokenAddress
              : tokenFrom),
          client: web3client,
          chainId: (await web3client.getChainId()).toInt());
      await token.approve(
        EthereumAddress.fromHex(routerContractAddress),
        amount.getValueInUnitBI(EtherUnit.wei),
        credentials: currentState.wallet.privateKey,
        transaction: Transaction(),
      );

      //SWAPING TOKEN
      ContractAbi contractAbi =
          ContractAbi.fromJson(jsonEncode(UNISWAP_SWAP_ROUTER), "");
      DeployedContract deployedContract = DeployedContract(
          contractAbi, EthereumAddress.fromHex(routerContractAddress));
      if (swapType == "ETH2TOKEN") {
        debug_print.log("SWAPING ETH FOR TOKEN");
        var swapResult = await web3client.sendTransaction(
            currentState.wallet.privateKey,
            Transaction.callContract(
              gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
              maxFeePerGas: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
              maxPriorityFeePerGas:
                  EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
              maxGas: 1000000,
              value: amount,
              contract: deployedContract,
              function: deployedContract.function("swapETHForExactTokens"),
              parameters: [
                amountOut,
                [
                  EthereumAddress.fromHex(tokenFrom),
                  EthereumAddress.fromHex(tokenTo),
                ],
                EthereumAddress.fromHex(recipient),
                BigInt.from(DateTime.now()
                    .add(const Duration(minutes: 10))
                    .millisecondsSinceEpoch),
              ],
            ),
            chainId: (await web3client.getChainId()).toInt());
        debug_print.log(swapResult);
      }
      if (swapType == "TOKEN2TOKEN") {
        debug_print.log(amount.toString());
        var swapResult = await web3client.sendTransaction(
            currentState.wallet.privateKey,
            Transaction.callContract(
              gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
              maxFeePerGas: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
              maxPriorityFeePerGas:
                  EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
              maxGas: 1000000,
              value: amount,
              contract: deployedContract,
              function: deployedContract.function("swapExactTokensForTokens"),
              parameters: [
                amountOut,
                BigInt.one,
                [
                  EthereumAddress.fromHex(tokenFrom),
                  EthereumAddress.fromHex(tokenTo),
                ],
                EthereumAddress.fromHex(recipient),
                BigInt.from(DateTime.now()
                    .add(const Duration(minutes: 10))
                    .millisecondsSinceEpoch),
              ],
            ),
            chainId: (await web3client.getChainId()).toInt());
        debug_print.log(swapResult);
      }
      if (swapType == "TOKEN2ETH") {
        debug_print.log(swapType);
        var swapResult = await web3client.sendTransaction(
            currentState.wallet.privateKey,
            Transaction.callContract(
              gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
              maxFeePerGas: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
              maxPriorityFeePerGas:
                  EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
              maxGas: 1000000,
              // value: amount,
              contract: deployedContract,
              function: deployedContract.function("swapTokensForExactETH"),
              parameters: [
                amountOut,
                amount.getValueInUnitBI(EtherUnit.wei),
                [
                  EthereumAddress.fromHex(tokenFrom),
                  EthereumAddress.fromHex(tokenTo),
                ],
                EthereumAddress.fromHex(recipient),
                BigInt.from(DateTime.now()
                    .add(const Duration(minutes: 10))
                    .millisecondsSinceEpoch),
              ],
            ),
            chainId: (await web3client.getChainId()).toInt());
        debug_print.log(swapResult);
      }
      List<dynamic> tokensDy = userPreferenceBox.get(getTokenStorageKey(
              address: currentState.wallet.privateKey.address.hex,
              network: currentState.currentNetwork)) ??
          [];
      emit(TokenTransfered(tokens: tokensDy.cast<Token>()));
    } catch (e) {
      emit(TokenError(error: e.toString()));
    }
  }

  Future<Decimal> getTokenBalance(
      Token token, String address, Network network) async {
    Erc20 erc20Token = Erc20(
        address: EthereumAddress.fromHex(token.tokenAddress),
        client: web3client,
        chainId: network.chainId);
    var balance = await erc20Token.balanceOf(EthereumAddress.fromHex(address));
    var decimalValue = Decimal.parse(balance.toString());
    return (decimalValue / Decimal.fromInt(pow(10, token.decimal).toInt()))
        .toDecimal();
  }

  void deleteToken(
      {required Token token,
      required String address,
      required Network network}) {
    String tokenStorageKey =
        getTokenStorageKey(address: address, network: network);
    List<dynamic> tokensDy = userPreferenceBox.get(tokenStorageKey) ?? [];
    tokensDy.remove(token);
    userPreferenceBox.put(tokenStorageKey, tokensDy);
    emit(TokenDeleted(tokens: tokensDy.cast<Token>()));
  }

  Future<List<String>> getTokenInfo(
      {required String tokenAddress, required Network network}) async {
    Erc20 erc20Token = Erc20(
        address: EthereumAddress.fromHex(tokenAddress),
        client: web3client,
        chainId: network.chainId);
    String decimal = ((await erc20Token.decimals()).toString());
    String symbol = await erc20Token.symbol();

    return [decimal, symbol];
  }
}
