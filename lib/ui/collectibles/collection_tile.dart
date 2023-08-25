import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wallet/ui/token-dashboard-screen/token_dashboard_screen.dart';

class CollectionTile extends StatefulWidget {
  final String symbol;
  final String tokenAddress;
  final String? imageUrl;
  final String tokenID;
  final String? description;
  const CollectionTile(
      {Key? key,
      required this.symbol,
      required this.tokenAddress,
      required this.tokenID,
      required this.description,
      this.imageUrl})
      : super(key: key);

  @override
  State<CollectionTile> createState() => _CollectionTileState();
}

class _CollectionTileState extends State<CollectionTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(TokenDashboardScreen.route, arguments: {
          "token": widget.tokenAddress,
          "isCollectible": true,
          "tokenId": widget.tokenID
        });
      },
      leading: CachedNetworkImage(
        imageUrl: widget.imageUrl != null && widget.imageUrl!.contains("http")
            ? widget.imageUrl!
            : "https://ipfs.io/ipfs/${widget.imageUrl}",
        width: 70,
        height: 70,
        fit: BoxFit.fitWidth,
      ),
      title: Text(
        "${widget.symbol} #${widget.tokenID}",
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Text(
            widget.description != null ? widget.description! : "",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black),
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
