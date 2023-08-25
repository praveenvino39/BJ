import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:wallet/ui/home/component/avatar_component.dart';

class TokenTile extends StatefulWidget {
  final String symbol;
  final Decimal balance;
  final double balanceInFiat;
  final String tokenAddress;
  final int decimal;
  final String? imageUrl;
  const TokenTile(
      {Key? key,
      required this.symbol,
      required this.balance,
      required this.balanceInFiat,
      required this.tokenAddress,
      required this.decimal,
      this.imageUrl})
      : super(key: key);

  @override
  State<TokenTile> createState() => _TokenTileState();
}

class _TokenTileState extends State<TokenTile> {


  @override
  Widget build(BuildContext context) {
    return  ListTile(
      leading:AvatarWidget(radius: 50, address: widget.tokenAddress, iconType: "identicon",imageUrl: widget.imageUrl,),
      title: Text(
        "${widget.balance.toStringAsFixed(18).split(".")[0]}.${widget.balance.toStringAsFixed(18).split(".")[1].substring(0,4)} ${widget.symbol.toUpperCase()}",
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: Text(
        "\$${widget.balanceInFiat}",
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      trailing:const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black,
      ),
    );
  }
}
