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

class ReferenciasPage extends StatefulWidget {
  final List<ReferenciaModelo> referencias;
  final bool carga;
  final Function() send;
  const ReferenciasPage(
      {super.key,
      required this.referencias,
      required this.carga,
      required this.send});

  @override
  State<ReferenciasPage> createState() => _ReferenciasPageState();
}

class _ReferenciasPageState extends State<ReferenciasPage> {
  @override
  Widget build(BuildContext context) {
    return !widget.carga
        ? Center(
            child: LoadingAnimationWidget.twoRotatingArc(
                color: ThemaMain.primary, size: 24.sp))
        : widget.referencias.isEmpty
            ? Center(
                child: Text("No se encontraron referencias pendientes a enviar",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)))
            : Scrollbar(
                child: StickyGroupedListView<ReferenciaModelo, int?>(
                    floatingHeader: true,
                    elements: widget.referencias,
                    itemComparator: (a, b) => a.id!.compareTo(b.id!),
                    groupBy: (element) => element.idForanea,
                    groupSeparatorBuilder: (element) => Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 2.w),
                        decoration: BoxDecoration(
                            color: ThemaMain.darkBlue,
                            borderRadius: BorderRadius.circular(borderRadius)),
                        child: Text(element.idForanea.toString(),
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: ThemaMain.second,
                                fontWeight: FontWeight.bold))),
                    itemBuilder: (context, refencias) =>
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          SlideGeneral(
                              id: refencias.id!,
                              delete: () async {
                                await Dialogs.showMorph(
                                    title: "Eliminar envio",
                                    description:
                                        "¿Desea quitar este cambio de los pendientes?\nTodos los cambios se mantendran de manera local",
                                    loadingTitle: "Eliminando",
                                    onAcceptPressed: (context) async {
                                      var data = refencias.copyWith(estatus: 1);
                                      await ReferenciasController.update(data);
                                      await widget.send();
                                    });
                              },
                              pendiente: () async {},
                              directo: () {},
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
