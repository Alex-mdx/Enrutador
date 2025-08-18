import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../utilities/theme/theme_app.dart';
import '../../utilities/theme/theme_color.dart';
import 'sliding_cards/tarjeta_contacto.dart';

class MapSliding extends StatefulWidget {
  const MapSliding({super.key});

  @override
  State<MapSliding> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MapSliding> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return SlidingUpPanel(
        isDraggable: false,
        backdropEnabled: true,
        renderPanelSheet: false,
        backdropTapClosesPanel: true,
        defaultPanelState: PanelState.CLOSED,
        minHeight: 7.h,
        maxHeight: 45.h,
        controller: provider.slide,
        panel: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: ThemaMain.background,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(borderRadius))),
                  width: 100.w,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    if (provider.selectRefencia != null)
                      FutureBuilder(
                          future: ContactoController.getItem(
                              lat: provider.selectRefencia?.contactoIdLat ?? 1,
                              lng: provider.selectRefencia?.contactoIdLng ?? 1),
                          builder: (context, snapshot) => (provider
                                          .contacto?.latitud ==
                                      provider.selectRefencia?.contactoIdLat &&
                                  provider.contacto?.longitud ==
                                      provider.selectRefencia?.contactoIdLng)
                              ? Text(
                                  "Seleccione un contacto para referenciar",
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold)
                                )
                              : TextButton.icon(
                                  onPressed: () async => Dialogs.showMorph(
                                      title: "Agregar",
                                      description:
                                          "¿Agregar este contacto como referencia?",
                                      loadingTitle: "agregando...",
                                      onAcceptPressed: (context) async {
                                        final referencia =
                                            provider.selectRefencia?.copyWith(
                                                contactoIdRLat:
                                                    provider.contacto?.latitud,
                                                contactoIdRLng:
                                                    provider.contacto?.longitud,
                                                fecha: DateTime.now());
                                        var newModel = snapshot.data?.copyWith(
                                            contactoEnlances: [referencia!]);
                                        await ContactoController.update(
                                            newModel!);
                                        provider.selectRefencia = null;
                                      }),
                                  label: Text(
                                      "Presione aqui para agregar como referencia a ${snapshot.data?.nombreCompleto ?? "Sin nombre disponible"}",
                                      style: TextStyle(fontSize: 15.sp)),
                                  icon: Icon(Icons.touch_app,
                                      size: 20.sp, color: ThemaMain.purple))),
                    TarjetaContacto()
                  ]))
            ]));
  }
}
