import 'dart:developer';

import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/core/remote/response-model/promotion.dart';
import 'package:wallet_cryptomask/ui/promotion_card.dart';

class UpdatesTab extends StatefulWidget {
  const UpdatesTab({super.key});

  @override
  State<UpdatesTab> createState() => _UpdatesTabState();
}

class _UpdatesTabState extends State<UpdatesTab> {
  Promotions? promotions;
  @override
  void initState() {
    super.initState();
    // loadPromotion();
    IO.Socket socket = IO.io(
        baseApiUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']).setExtraHeaders({}).build());
    socket.onConnect((_) {
      log('connect');
      loadPromotion();
      socket.emit('joinRoom', 'PROMOTION');
      socket.on('message', (data) {
        loadPromotion();
      });
    });

    socket.onError((data) {
      log(data.toString());
    });
  }

  loadPromotion() async {
    promotions = await getUpdates();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return promotions != null
        ? ListView.builder(
            itemCount: promotions!.data.length ?? 0,
            itemBuilder: (context, index) => PromotionCard(
                  body: promotions!.data[index].body,
                  title: promotions!.data[index].title,
                  ctaText: promotions!.data[index].ctaText,
                  ctaUrl: promotions!.data[index].ctaUrl,
                  imageUrl: baseApiUrl + promotions!.data[index].image,
                  openInDappBrowser: promotions!.data[index].openInDappBrowser,
                ))
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
