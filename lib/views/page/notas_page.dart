import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/nota_fire.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/extras/card_nota.dart';
import 'package:enrutador/views/widgets/sliding_cards/slide_general.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../../controllers/nota_controller.dart';
import '../../utilities/services/dialog_services.dart';

class NotasPage extends StatelessWidget {
  final List<NotaModel> notas;
  final bool carga;
  final Function() send;
  const NotasPage(
      {super.key,
      required this.notas,
      required this.carga,
      required this.send});

  @override
  Widget build(BuildContext context) {
    return !carga
        ? Center(
            child: LoadingAnimationWidget.twoRotatingArc(
                color: ThemaMain.primary, size: 24.sp))
        : notas.isEmpty
            ? Center(
                child: Text("No se encontraron notas pendientes a enviar",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)))
            : Scrollbar(
                child: StickyGroupedListView<NotaModel, int?>(
                    floatingHeader: true,
                    elements: notas,
                    itemComparator: (a, b) =>
                        a.contactoId.compareTo(b.contactoId),
                    groupBy: (element) => element.contactoId,
                    groupSeparatorBuilder: (element) => Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 2.w),
                        decoration: BoxDecoration(
                            color: ThemaMain.darkBlue,
                            borderRadius: BorderRadius.circular(borderRadius)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(element.contactoId.toString(),
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: ThemaMain.second,
                                  fontWeight: FontWeight.bold)),
                          IconButton.filled(
                              iconSize: 20.sp,
                              onPressed: () async {
                                var contacto =
                                    await ContactoController.getPersonalizado(
                                        query: "id=${element.contactoId}",
                                        columns: [
                                          "id",
                                          "nombre_completo",
                                          "latitud",
                                          "longitud",
                                        ],
                                        limit: 1);
                                var notas = await NotasController.getContactoId(
                                    element.contactoId,
                                    pendiente: 1);
                                await Dialogs.showMorph(
                                    title: "Enviar notas",
                                    description:
                                        "¿Desea enviar las notas de ${contacto.firstOrNull?.nombreCompleto} de manera directa?",
                                    loadingTitle: "Enviando",
                                    onAcceptPressed: (context) async {
                                      for (var nota in notas) {
                                        var data = nota.copyWith(pendiente: 0);
                                        var result =
                                            await NotaFire.send(nota: data);
                                        if (result) {
                                          await NotasController.update(data);
                                        }
                                      }
                                      await send();
                                    });
                              },
                              icon: Icon(Icons.cloud_done,
                                  color: ThemaMain.green))
                        ])),
                    itemBuilder: (context, notas) =>
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          SlideGeneral(
                              id: notas.id!,
                              ifDelete: false,
                              ifPendiente: false,
                              directo: () async {
                                await Dialogs.showMorph(
                                    title: "Enviar envio",
                                    description:
                                        "¿Desea enviar este cambio de manera directa?",
                                    loadingTitle: "Enviando",
                                    onAcceptPressed: (context) async {
                                      var data = notas.copyWith(pendiente: 0);
                                      var result =
                                          await NotaFire.send(nota: data);
                                      if (result) {
                                        await NotasController.update(data);
                                        await send();
                                      }
                                    });
                              },
                              model: CardNota(element: notas, maxLine: 1))
                        ])));
  }
}
