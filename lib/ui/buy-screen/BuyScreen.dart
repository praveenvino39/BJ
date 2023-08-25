import 'package:flutter/material.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';

class BuyScreen extends StatefulWidget {
  static const route = "BUYSCREEN";
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  late final RampFlutter ramp;
  late final Configuration configuration;

  @override
  void initState() {
    super.initState();
    configuration = Configuration();
    configuration.hostApiKey = 'YOUR_API_KEY';
    configuration.hostAppName = "Ramp Flutter";
    configuration.hostLogoUrl = "https://ramp.network/logo.png";
    configuration.enabledFlows = ["ONRAMP", "OFFRAMP"];

    ramp = RampFlutter();
    ramp.onOnrampPurchaseCreated = onOnrampPurchaseCreated;
    ramp.onSendCryptoRequested = onSendCryptoRequested;
    ramp.onOfframpSaleCreated = onOfframpSaleCreated;
    ramp.onRampClosed = onRampClosed;
  }

  void onOnrampPurchaseCreated(
    OnrampPurchase purchase,
    String purchaseViewToken,
    String apiUrl,
  ) {}

  _presentRamp() {
    ramp.showRamp(configuration);
  }

  void onSendCryptoRequested(SendCryptoPayload payload) {}

  void onOfframpSaleCreated(
    OfframpSale sale,
    String saleViewToken,
    String apiUrl,
  ) {}

  void onRampClosed() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
          onPressed: () {
            _presentRamp();
          },
          child: const Text("Buy")),
    );
  }
}
