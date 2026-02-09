import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_color.dart';
import '../../../models/referencia_model.dart';

class ListReferenciaAgrupada extends StatelessWidget {
  const ListReferenciaAgrupada({super.key, required this.referencias});

  final List<ReferenciaModelo> referencias;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0),
            child: Column(children: [
              Text("Contacto: ejemplo",
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note, size: 20.sp, color: ThemaMain.yellow),
                    Text("Referencias: 0", style: TextStyle(fontSize: 15.sp))
                  ])
            ])));
  }
}
