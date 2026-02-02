import 'package:enrutador/models/nota_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/textos.dart';

class CardNota extends StatelessWidget {
  final NotaModel element;
  const CardNota({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Card(
        elevation: element.empleadoId == provider.usuario?.empleadoId ? 2 : 1,
        color: element.empleadoId == provider.usuario?.empleadoId
            ? ThemaMain.dialogbackground
            : null,
        child: ListTile(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: Text(Textos.fechaHMS(fecha: element.creado),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: ThemaMain.darkGrey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Row(
                          spacing: 2.w,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                        Text(
                            element.empleadoId == provider.usuario?.empleadoId
                                ? "Mio"
                                : element.empleadoId,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: element.empleadoId ==
                                        provider.usuario?.empleadoId
                                    ? ThemaMain.darkGrey
                                    : ThemaMain.darkBlue,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold)),
                        element.pendiente == 0
                            ? Icon(Icons.cloud_done,
                                color: ThemaMain.green, size: 16.sp)
                            : element.pendiente == -1
                                ? Icon(Icons.cloud_off,
                                    color: ThemaMain.primary, size: 16.sp)
                                : Icon(Icons.search,
                                    color: ThemaMain.primary, size: 16.sp)
                      ]))
                ]),
            subtitle:
                Text(element.descripcion, style: TextStyle(fontSize: 15.sp))));
  }
}
