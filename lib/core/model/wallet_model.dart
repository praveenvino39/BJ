import 'package:web3dart/credentials.dart';

class WalletModel {
  double balance;
  Wallet wallet;
  String accountName;

  WalletModel({required this.balance, required this.wallet, required this.accountName});
}
