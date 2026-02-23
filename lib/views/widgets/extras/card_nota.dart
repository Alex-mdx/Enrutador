import 'package:enrutador/controllers/nota_fire.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/nota_controller.dart';
import '../../../utilities/textos.dart';

class CardNota extends StatelessWidget {
  final NotaModel element;
  final int? maxLine;
  final Function()? onDelete;
  const CardNota(
      {super.key, required this.element, this.maxLine, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return GestureDetector(
      onLongPress: () {
        if (onDelete != null) {
          Dialogs.showMorph(
              title: "Eliminar",
              description: "¿Estas seguro de eliminar esta nota?",
              loadingTitle: "Eliminando",
              onAcceptPressed: (context) async {
                await NotasController.deleteItem(element.id!);
                await NotaFire.delete(nota: element);

                await onDelete!();
              });
        }
      },
      child: Card(
          elevation: element.empleadoId == provider.usuario?.empleadoId ? 2 : 1,
          color: element.empleadoId == provider.usuario?.empleadoId
              ? ThemaMain.dialogbackground
              : null,
          child: Stack(alignment: AlignmentGeometry.bottomRight, children: [
            Padding(
                padding: const EdgeInsets.all(4),
                child: element.pendiente == 0
                    ? Icon(Icons.cloud_done,
                        color: ThemaMain.green, size: 15.sp)
                    : element.pendiente == -1
                        ? Icon(Icons.search_off,
                            color: ThemaMain.darkGrey, size: 15.sp)
                        : Icon(Icons.cloud_off,
                            color: ThemaMain.darkGrey, size: 15.sp)),
            ListTile(
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
                                element.empleadoId ==
                                        provider.usuario?.empleadoId
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
                subtitle: ReadMoreText(element.descripcion,
                    trimMode: TrimMode.Line,
                    trimLines: maxLine ?? 6,
                    colorClickableText: ThemaMain.pink,
                    trimCollapsedText: ' Mas',
                    trimExpandedText: 'Menos...',
                    style: TextStyle(fontSize: 14.sp),
                    moreStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: ThemaMain.primary)))
          ])),
    );
  }
}
