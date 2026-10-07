import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_color.dart';

class QrWidget extends StatelessWidget {
  final String text;
  final double size;
  const QrWidget({super.key, required this.text, this.size = 320});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      QrImageView(
          data: text,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
          size: size,
          backgroundColor: Colors.white,
          semanticsLabel: text,
          eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square, color: Colors.black),
          gapless: false,
          dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: ThemaMain.darkBlue),
          errorStateBuilder: (cxt, err) {
            return Center(
                child: Text('Algo fallo...', textAlign: TextAlign.center));
          }),
      Text(text, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold))
    ]);
  }
}
