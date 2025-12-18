import 'dart:convert';

import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sizer/sizer.dart';

class VisualizadorWidget extends StatelessWidget {
  final String? image64;
  final String carrusel;
  const VisualizadorWidget(
      {super.key, required this.image64, required this.carrusel});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: PhotoView.customChild(
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 2,
              child: Image.memory(base64Decode(image64!)))),
      Text(carrusel,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: ThemaMain.white))
    ]);
  }
}
