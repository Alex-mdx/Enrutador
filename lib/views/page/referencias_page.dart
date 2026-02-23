import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/referencia_fire.dart';
import 'package:enrutador/models/referencia_model.dart';
import 'package:enrutador/views/widgets/extras/chip_referencia.dart';
import 'package:enrutador/views/widgets/sliding_cards/slide_general.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import '../../controllers/referencias_controller.dart';
import '../../utilities/services/dialog_services.dart';
import '../../utilities/theme/theme_app.dart';
import '../../utilities/theme/theme_color.dart';

class ReferenciasPage extends StatelessWidget {
  final List<ReferenciaModelo> referencias;
  final bool carga;
  final Function() send;
  const ReferenciasPage(
      {super.key,
      required this.referencias,
      required this.carga,
      required this.send});

  @override
  Widget build(BuildContext context) {
    return !carga
        ? Center(
            child: LoadingAnimationWidget.twoRotatingArc(
                color: ThemaMain.primary, size: 24.sp))
        : referencias.isEmpty
            ? Center(
                child: Text("No se encontraron referencias pendientes a enviar",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)))
            : Scrollbar(
                child: StickyGroupedListView<ReferenciaModelo, int?>(
                    floatingHeader: true,
                    elements: referencias,
                    itemComparator: (a, b) => a.id!.compareTo(b.id!),
                    groupBy: (element) => element.idForanea,
                    groupSeparatorBuilder: (element) => Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 2.w),
                        decoration: BoxDecoration(
                            color: ThemaMain.darkBlue,
                            borderRadius: BorderRadius.circular(borderRadius)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(element.idForanea.toString(),
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: ThemaMain.second,
                                  fontWeight: FontWeight.bold)),
                          IconButton.filled(
                              iconSize: 20.sp,
                              onPressed: () {},
                              icon: Icon(Icons.youtube_searched_for,
                                  color: ThemaMain.primary)),
                          IconButton.filled(
                              iconSize: 20.sp,
                              onPressed: () async {
                                 var contacto =
                                    await ContactoController.getPersonalizado(
                                        query: "id=${element.idForanea}",
                                        columns: [
                                          "id",
                                          "nombre_completo",
                                          "latitud",
                                          "longitud",
                                        ],
                                        limit: 1);
                                var referencias = await ReferenciasController.getIdPrin(idContacto: element.idForanea, lat: element.contactoIdRLat, lng: element.contactoIdRLng, status: -1);
                                await Dialogs.showMorph(
                                    title: "Enviar notas",
                                    description:
                                        "¿Desea enviar las referencias de ${contacto.firstOrNull?.nombreCompleto} de manera directa?",
                                    loadingTitle: "Enviando",
                                    onAcceptPressed: (context) async {
                                      for (var refencia in referencias) {
                                        var data = refencia.copyWith(estatus: 0);
                                        var result =
                                            await ReferenciaFire.send(referencia: data);
                                        if (result) {
                                          await ReferenciasController.update(data);
                                        }
                                      }
                                      await send();
                                    });
                              },
                              icon: Icon(Icons.cloud_done,
                                  color: ThemaMain.green))
                        ])),
                    itemBuilder: (context, refencias) =>
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          SlideGeneral(
                              id: refencias.id!,pendiente: ()async {
                                await Dialogs.showMorph(
                                    title: "Enviar referencias a pendientes",
                                    description:
                                        "¿Desea enviar las referencias como pendientes a revision?",
                                    loadingTitle: "Enviando",
                                    onAcceptPressed: (context) async {
                                      var data = refencias.copyWith(estatus: 0);
                                      await ReferenciasController.update(data);
                                      
                                      await send();
                                    });
                              },
                              directo: () async {
                                await Dialogs.showMorph(
                                    title: "Enviar referencias directas",
                                    description:
                                        "¿Desea enviar este cambio de manera directa?",
                                    loadingTitle: "Enviando",
                                    onAcceptPressed: (context) async {
                                      var data = refencias.copyWith(estatus: 0);
                                      await ReferenciasController.update(data);
                                      await ReferenciaFire.send(
                                          referencia: data);
                                      await send();
                                    });
                              },
                              model: ChipReferencia(
                                  latlng: LatLng(refencias.contactoIdLat,
                                      refencias.contactoIdLng),
                                  ref: refencias,
                                  origen: true,
                                  extended: true,
                                  tap: false))
                        ])));
  }
}
