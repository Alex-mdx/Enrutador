import 'dart:convert';

import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:sizer/sizer.dart';
import '../../utilities/theme/theme_app.dart';

class GaleriaWidget extends StatelessWidget {
  final String? image64;
  final Function() ontap;
  final Function() onDoubleTap;
  final bool compartir;
  final double? minFit;
  const GaleriaWidget(
      {super.key,
      required this.image64,
      required this.onDoubleTap,
      required this.ontap,
      required this.compartir,this.minFit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: () async {
          try {
            await Pasteboard.writeImage(base64Decode(image64!));

            final files = await Pasteboard.files();
            debugPrint("$files");
            showToast("Imagen copiada al portapapeles");
          } catch (e) {
            debugPrint("$e");
          }
        },
        onDoubleTap: () async => await onDoubleTap(),
        onTap: () => ontap(),
        child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(borderRadius),
            child: Image.memory(
                fit: compartir ? BoxFit.fitHeight : BoxFit.cover,
                filterQuality:
                    compartir ? FilterQuality.medium : FilterQuality.low,
                width: compartir ? 30.w : minFit ?? 21.w,
                height: compartir ? 30.w :minFit ?? 21.w,
                base64Decode(image64 ?? "a"),
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.broken_image,
                    color: ThemaMain.red,
                    size: compartir ? 30.w : minFit ?? 21.w))));
  }
}
