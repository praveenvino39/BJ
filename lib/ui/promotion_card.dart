import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_cryptomask/core/remote/response-model/promotion.dart';
import 'package:wallet_cryptomask/ui/promotion_detail_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';

class PromotionCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String body;
  final bool openInDappBrowser;
  final String ctaUrl;
  final String ctaText;
  const PromotionCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.body,
    required this.openInDappBrowser,
    required this.ctaUrl,
    required this.ctaText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(PromotionDetailScreen.route, arguments: {
          "promotion": Promotion(
            body: body,
            ctaText: ctaText,
            ctaUrl: ctaUrl,
            openInDappBrowser: openInDappBrowser,
            priorityIndex: 0,
            title: title,
            id: 0,
            image: imageUrl,
          )
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WalletText(
                "",
                fontWeight: FontWeight.w500,
                size: 18,
                localizeKey: title,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WalletText(
                "",
                ellipsis: true,
                fontWeight: FontWeight.w500,
                localizeKey: body,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WalletButton(
                textContent: "",
                onPressed: () async {
                  final ctaUri = Uri.parse(ctaUrl);
                  if (openInDappBrowser) {
                    return;
                  }
                  if (await canLaunchUrl(ctaUri)) {
                    launchUrl(Uri.parse(ctaUrl));
                  }
                },
                localizeKey: ctaText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
