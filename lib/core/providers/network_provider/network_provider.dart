import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';

NetworkProvider getNetworkProvider(BuildContext context) =>
    Provider.of<NetworkProvider>(context, listen: false);

NetworkProvider getLiveNetworkProvider(BuildContext context) =>
    Provider.of<NetworkProvider>(context);

class NetworkProvider extends ChangeNotifier {
  final String infuraKey;
  List<Network> networks = [];

  NetworkProvider({required this.infuraKey}) {
    networks = loadNetworks();
    notifyListeners();
  }

  loadNetworks() {
    return [
      Network(
          nameSpace: "eip155",
          networkName: "Ethereum mainnet",
          url: "https://mainnet.infura.io/v3/$infuraKey",
          symbol: "ETH",
          currency: "ETH",
          supportsEip1559: true,
          chainId: 1,
          logo: "assets/images/eth.png",
          apiKey: "R4UWZSAHBDVC95DACN4E7XVHMUXQ8ETI5B",
          wrappedTokenAddress: "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6",
          isMainnet: true,
          addressViewUrl: "https://etherscan.io/address/",
          transactionViewUrl: "https://etherscan.io/tx/",
          dotColor: Colors.yellow,
          priceId: "ethereum",
          etherscanApiBaseUrl: "https://api.etherscan.io/"),
      Network(
          networkName: "Polygon Mainnet",
          url: "https://polygon-rpc.com",
          symbol: "MATIC",
          currency: "MATIC",
          supportsEip1559: true,
          logo: "assets/images/polygon.png",
          nameSpace: "eip155",
          chainId: 137,
          priceId: "matic-network",
          apiKey: "VNWSPE7JSB49YSFA2HX1K7UKSPTN1CWD47",
          wrappedTokenAddress: "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6",
          isMainnet: true,
          addressViewUrl: "https://polygonscan.com/address/",
          transactionViewUrl: "https://polygonscan.com/tx/",
          dotColor: const Color(0xff8247e5),
          etherscanApiBaseUrl: "https://api.polygonscan.com/"),
    ];
  }
}
