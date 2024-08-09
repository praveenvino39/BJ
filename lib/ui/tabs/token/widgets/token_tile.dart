import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/ui/shared/avatar_widget.dart';

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
    return ListTile(
      leading: AvatarWidget(
        radius: 50,
        address: widget.tokenAddress,
        iconType: "identicon",
        imageUrl: widget.imageUrl,
      ),
      title: Text(
        widget.symbol,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.balance.toStringAsFixed(6),
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            "\$${widget.balanceInFiat.toStringAsFixed(6)}",
            style: const TextStyle(fontSize: 10, color: Colors.black),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black,
      ),
    );
  }
}
