import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrWidget extends StatelessWidget {
  final String text;
  final double size;
  const QrWidget({super.key, required this.text, this.size = 320});

  @override
  Widget build(BuildContext context) {
    return QrImageView(
        data: text,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        size: size,
        eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square),
        gapless: false,
        dataModuleStyle:
            QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle),
        errorStateBuilder: (cxt, err) {
          return Center(
              child: Text('Algo fallo...', textAlign: TextAlign.center));
        });
  }
}
