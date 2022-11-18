import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../colors.dart';

class QRCode extends StatefulWidget {
  const QRCode({Key? key, required this.lat, required this.long, required this.address}) : super(key: key);

  final String lat;
  final String long;
  final String address;

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  @override
  Widget build(BuildContext context) {
    return QrImage(
        data: 'Eingestiegen in ${widget.lat}, ${widget.long}. Ort: ${widget.address}',
        gapless: true,
        version: QrVersions.auto,
        size: 300,
        foregroundColor: accentColor1,
        //embeddedImage: const AssetImage('assets/images/thm.png'),
        //embeddedImageStyle: QrEmbeddedImageStyle(
        //size: const Size(80,80),
        //),
        errorStateBuilder: (cxt, err) {
          return const Center(
            child: Text(
              "Etwas läuft schief...",
              textAlign: TextAlign.center,
            ),
          );
        });
  }
}