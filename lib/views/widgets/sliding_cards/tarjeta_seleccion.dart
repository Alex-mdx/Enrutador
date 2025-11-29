import 'package:enrutador/controllers/referencias_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/contacto_controller.dart';
import '../../../utilities/theme/theme_color.dart';

class TarjetaSeleccion extends StatefulWidget {
  const TarjetaSeleccion({super.key});

  @override
  State<TarjetaSeleccion> createState() => _TarjetaSeleccionState();
}

class _TarjetaSeleccionState extends State<TarjetaSeleccion> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 9,
              child: FutureBuilder(
                  future: ContactoController.getItem(
                      lat: provider.selectRefencia?.contactoIdLat ?? 1,
                      lng: provider.selectRefencia?.contactoIdLng ?? 1,
                      id: provider.selectRefencia!.idForanea),
                  builder: (context, snapshot) => ((provider
                                      .contacto?.latitud ==
                                  provider.selectRefencia?.contactoIdLat &&
                              provider.contacto?.longitud ==
                                  provider.selectRefencia?.contactoIdLng) ||
                          provider.contacto?.id == null)
                      ? Padding(
                          padding: EdgeInsets.only(left: 1.w),
                          child: Text("Seleccione un contacto para referenciar",
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold)))
                      : TextButton.icon(
                          onPressed: () async => Dialogs.showMorph(
                              title: "Agregar",
                              description:
                                  "¿Agregar este contacto como referencia?",
                              loadingTitle: "agregando...",
                              onAcceptPressed: (context) async {
                                var temp = await ContactoController.getItem(
                                    lat: provider.selectRefencia!.contactoIdLat,
                                    lng:
                                        provider.selectRefencia!.contactoIdLng);
                                if (temp != null) {
                                  final referencia = provider.selectRefencia
                                      ?.copyWith(
                                          idRForenea: provider.contacto?.id,
                                          contactoIdRLat:
                                              provider.contacto?.latitud,
                                          contactoIdRLng:
                                              provider.contacto?.longitud,
                                          fecha: DateTime.now());
                                  if (referencia != null) {
                                    await ReferenciasController.insert(
                                        referencia);
                                  }
                                } else {
                                  showToast("No se encontro el contacto");
                                }

                                provider.selectRefencia = null;
                              }),
                          label: Text(
                              "Presione para vincular a\n${snapshot.data?.nombreCompleto ?? "Sin nombre disponible"}",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15.sp)),
                          icon: Icon(Icons.touch_app,
                              size: 22.sp, color: ThemaMain.yellow)))),
          Expanded(
              flex: 1,
              child: IconButton(
                  iconSize: 24.sp,
                  onPressed: () => provider.selectRefencia = null,
                  icon: Icon(Icons.remove_circle, color: ThemaMain.red)))
        ]);
  }
}
