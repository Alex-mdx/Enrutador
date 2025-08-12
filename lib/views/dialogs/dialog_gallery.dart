import 'dart:typed_data';

import 'package:advanced_media_picker/advanced_media_picker.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DialogGallery extends StatelessWidget {
  final Function(Uint8List?) image;
  const DialogGallery({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Seleccione el origen de su imagen",
          style: TextStyle(fontSize: 16.sp)),
      Padding(
        padding: EdgeInsets.all(10.sp),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Column(children: [
            Text("Camara", style: TextStyle(fontSize: 14.sp)),
            IconButton.filled(
                iconSize: 28.sp,
                onPressed: () {},
                icon: Icon(Icons.camera_enhance))
          ]),
          Column(children: [
            Text("Galeria", style: TextStyle(fontSize: 14.sp)),
            IconButton.filled(
                iconSize: 28.sp,
                onPressed: () async {
                  
                },
                icon: Icon(Icons.image_search))
          ])
        ]),
      )
    ]));
  }
}
