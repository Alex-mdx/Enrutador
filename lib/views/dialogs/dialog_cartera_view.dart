import 'package:flutter/material.dart';
import 'package:enrutador/models/cartera_model.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/camara_fun.dart';

class DialogCarteraView extends StatefulWidget {
  final CarteraModel cartera;
  const DialogCarteraView({super.key, required this.cartera});

  @override
  State<DialogCarteraView> createState() => _DialogCarteraViewState();
}

class _DialogCarteraViewState extends State<DialogCarteraView> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(title: Text("Cartera"), actions: [
        IconButton.filledTonal(
            iconSize: 18.sp,
            onPressed: () async => await CamaraFun.scanQr(),
            icon: Icon(Icons.photo_camera_rounded))
      ])
    ]));
  }
}
