import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  final Function(String address) onQrDecode;
  const ScannerScreen({Key? key, required this.onQrDecode}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _mobileScannerController = MobileScannerController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Scan QR Code",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.black,
              width: 300,
              height: 300,
              child: MobileScanner(
                controller: _mobileScannerController,
                onDetect: (barcodes) {
                  if (barcodes.barcodes[0].rawValue == null) {
                    debugPrint('Failed to scan Barcode');
                  } else {
                    widget.onQrDecode(barcodes.barcodes[0].rawValue.toString());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
