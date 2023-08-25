// ignore_for_file: overridden_fields

part of 'wallet_cubit.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletErased extends WalletState {}

// ignore: must_be_immutable
class WalletLoaded extends WalletState {
  Wallet wallet;
  double balanceInUSD;
  double balanceInNative = 0.0;
  Web3Client web3client;
  Network currentNetwork;
  List<WalletModel> availabeWallet;
  String? password;
  List<Token> tokens = [];
  List<Collectible> collectibles = [];
  List<String> pendingTransaction = [];
  String currency = "usd";
  WalletLoaded({
    required this.wallet,
    required this.balanceInUSD,
    required this.web3client,
    required this.currentNetwork,
    required this.availabeWallet,
    required this.tokens,
    required this.collectibles,
    required this.pendingTransaction,
    required this.currency,
    this.password,
  });
}

class WalletUnlocked extends WalletLoaded {
  @override
  String? password;
  WalletUnlocked(
      {required super.wallet,
      required super.balanceInUSD,
      required super.web3client,
      required super.currentNetwork,
      required super.availabeWallet,
      required super.tokens,
      required super.collectibles,
      required super.pendingTransaction,
      required super.currency,
      this.password}) {
    super.password = password;
  }
}

class WalletNetworkChanged extends WalletLoaded {
  @override
  String? password;
  WalletNetworkChanged(
      {required super.wallet,
      required super.balanceInUSD,
      required super.web3client,
      required super.currentNetwork,
      required super.availabeWallet,
      required super.tokens,
      required super.pendingTransaction,
      required super.collectibles,
      required super.currency,
      this.password}) {
    super.password = password;
  }
}

class WalletImported extends WalletLoaded {
  @override
  String? password;
  WalletImported(
      {required super.wallet,
      required super.balanceInUSD,
      required super.web3client,
      required super.currentNetwork,
      required super.availabeWallet,
      required super.tokens,
      required super.pendingTransaction,
      required super.currency,
      required super.collectibles,
      this.password}) {
    super.password = password;
  }
}

class WalletTokenAdded extends WalletLoaded {
  @override
  String? password;
  WalletTokenAdded(
      {required super.wallet,
      required super.balanceInUSD,
      required super.web3client,
      required super.currentNetwork,
      required super.pendingTransaction,
      required super.availabeWallet,
      required super.tokens,
      required super.currency,
      required super.collectibles,
      this.password}) {
    super.password = password;
  }
}

class WalletCollectibleAdded extends WalletLoaded {
  @override
  String? password;
  WalletCollectibleAdded(
      {required super.wallet,
      required super.balanceInUSD,
      required super.web3client,
      required super.currentNetwork,
      required super.pendingTransaction,
      required super.availabeWallet,
      required super.tokens,
      required super.currency,
      required super.collectibles,
      this.password}) {
    super.password = password;
  }
}

class WalletCollectibleNotOwned extends WalletLoaded {
  @override
  String? password;
  WalletCollectibleNotOwned(
      {required super.wallet,
      required super.balanceInUSD,
      required super.web3client,
      required super.currentNetwork,
      required super.pendingTransaction,
      required super.availabeWallet,
      required super.tokens,
      required super.currency,
      required super.collectibles,
      this.password}) {
    super.password = password;
  }
}

class WalletCollectiblesLoaded extends WalletLoaded {
  @override
  String? password;
  WalletCollectiblesLoaded(
      {required super.wallet,
      required super.balanceInUSD,
      required super.pendingTransaction,
      required super.web3client,
      required super.currentNetwork,
      required super.availabeWallet,
      required super.tokens,
      required super.currency,
      required super.collectibles,
      this.password}) {
    super.password = password;
  }
}

class WalletTokenLoading extends WalletLoaded {
  @override
  String? password;
  WalletTokenLoading(
      {required super.wallet,
      required super.balanceInUSD,
      required super.web3client,
      required super.pendingTransaction,
      required super.currentNetwork,
      required super.availabeWallet,
      required super.tokens,
      required super.currency,
      required super.collectibles,
      this.password}) {
    super.password = password;
  }
}

class WalletTokenLoaded extends WalletLoaded {
  @override
  String? password;
  WalletTokenLoaded(
      {required super.wallet,
      required super.balanceInUSD,
      required super.web3client,
      required super.pendingTransaction,
      required super.currentNetwork,
      required super.availabeWallet,
      required super.tokens,
      required super.currency,
      required super.collectibles,
      this.password}) {
    super.password = password;
  }
}

class WalletAccountChanged extends WalletLoaded {
  @override
  String? password;
  WalletAccountChanged(
      {required super.wallet,
      required super.balanceInUSD,
      required super.pendingTransaction,
      required super.web3client,
      required super.currentNetwork,
      required super.availabeWallet,
      required super.tokens,
      required super.currency,
      required super.collectibles,
      this.password}) {
    super.password = password;
  }
}

class WalletSendTransactionSuccess extends WalletLoaded {
  @override
  String? password;
  String? transactionHash;
  WalletSendTransactionSuccess(
      {required super.wallet,
      required super.balanceInUSD,
      required super.pendingTransaction,
      required super.web3client,
      required super.currentNetwork,
      required super.availabeWallet,
      required super.tokens,
      required super.currency,
      required super.collectibles,
      this.transactionHash,
      this.password}) {
    super.password = password;
  }
}

class WalletSendTransactionFailed extends WalletLoaded {
  @override
  String? password;
  String error;
  WalletSendTransactionFailed(
      {required super.wallet,
      required super.balanceInUSD,
      required super.pendingTransaction,
      required super.web3client,
      required super.currentNetwork,
      required super.availabeWallet,
      required super.tokens,
      required super.currency,
      required super.collectibles,
      this.password,
      required this.error}) {
    super.password = password;
  }
}
class WalletCurrencyChanged extends WalletLoaded {
  @override
  String? password;
  WalletCurrencyChanged(
      {required super.wallet,
      required super.balanceInUSD,
      required super.pendingTransaction,
      required super.web3client,
      required super.currentNetwork,
      required super.availabeWallet,
      required super.tokens,
      required super.currency,
      required super.collectibles,
      this.password}) {
    super.password = password;
  }
}

class WalletLogout extends WalletState {}
