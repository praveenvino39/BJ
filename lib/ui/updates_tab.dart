import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/core/remote/response-model/promotion.dart';
import 'package:wallet_cryptomask/ui/promotion_card.dart';

class UpdatesTab extends StatefulWidget {
  const UpdatesTab({super.key});

  @override
  State<UpdatesTab> createState() => _UpdatesTabState();
}

class _UpdatesTabState extends State<UpdatesTab> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Promotions?>(
      future: getUpdates(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data?.data.length ?? 0,
              itemBuilder: (context, index) => PromotionCard(
                    body: snapshot.data!.data[index].body,
                    title: snapshot.data!.data[index].title,
                    ctaText: snapshot.data!.data[index].ctaText,
                    ctaUrl: snapshot.data!.data[index].ctaUrl,
                    imageUrl: baseApiUrl + snapshot.data!.data[index].image,
                    openInDappBrowser:
                        snapshot.data!.data[index].openInDappBrowser,
                  ));
        }
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
