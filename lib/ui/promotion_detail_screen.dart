import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/remote/response-model/promotion.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class PromotionDetailScreen extends StatelessWidget {
  static const route = "promotion_detail_screen";
  final Promotion promotion;
  const PromotionDetailScreen({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: const [
          SizedBox(
            width: 40,
          )
        ],
        backgroundColor: Colors.white,
        title: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(promotion.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w200, color: Colors.black)),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ],
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: kPrimaryColor,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: CachedNetworkImage(imageUrl: promotion.image)),
              ],
            ),
            addHeight(SpacingSize.s),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WalletText(
                "",
                fontWeight: FontWeight.w500,
                size: 18,
                localizeKey: promotion.title,
              ),
            ),
            addHeight(SpacingSize.s),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WalletText(
                "",
                fontWeight: FontWeight.w500,
                localizeKey: promotion.body,
              ),
            ),
            addHeight(SpacingSize.s),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WalletButton(
                textContent: "",
                onPressed: () async {
                  final ctaUri = Uri.parse(promotion.ctaUrl);
                  if (promotion.openInDappBrowser) {
                    return;
                  }
                  if (await canLaunchUrl(ctaUri)) {
                    launchUrl(ctaUri);
                  }
                },
                localizeKey: promotion.ctaText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
