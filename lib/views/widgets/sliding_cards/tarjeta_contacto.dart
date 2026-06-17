import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/enrutar_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/pluscode_fun.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../../../models/contacto_model.dart';
import '../../../utilities/map_fun.dart';
import '../../dialogs/dialog_ubicacion.dart';
import 'tarjeta_contacto_detalle.dart';
import 'tarjeta_rside_widget.dart';

class TarjetaContacto extends StatefulWidget {
  const TarjetaContacto({super.key});

  @override
  State<TarjetaContacto> createState() => _TarjetaContactoState();
}

class _TarjetaContactoState extends State<TarjetaContacto> {
  bool esperar = false;

  Future<void> funcion({required ContactoModelo contacto}) async {
    var data =
        await EnrutarController.getItemContacto(contactoId: contacto.id!);

    if (data != null) {
      var newEnrutar = data.copyWith(buscar: contacto);
      await EnrutarController.update(newEnrutar);
    }
  }

  WidgetsToImageController controller = WidgetsToImageController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Padding(
        padding: EdgeInsets.all(4.sp),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(
                width: 52.w,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: PlusCodeFun.convert(
                              PlusCodeFun.psCODE(
                                  provider.contacto?.latitud.toDouble() ?? 0,
                                  provider.contacto?.longitud.toDouble() ?? 0),
                              toShortFormat:
                                  Preferences.psCodeExt && provider.internet),
                          builder: (context, snapshot) => TextButton(
                              onLongPress: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: snapshot.data ?? "?"));
                                showToast("Plus Code copiados");
                              },
                              style: ButtonStyle(
                                  minimumSize:
                                      WidgetStatePropertyAll(Size(0, 0)),
                                  padding: WidgetStatePropertyAll(
                                      EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 0))),
                              onPressed: () async {
                                if (provider.contacto != null) {
                                  await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          DialogUbicacion(funLat: (lat) async {
                                            var zonas =
                                                await MapFun.checkPointWithZona(
                                                    point: lat ?? LatLng(0, 0));
                                            log("${zonas.map((e) => e.nombre).toList()}");
                                            var temp = provider.contacto!
                                                .copyWith(
                                                    pendiente: 1,
                                                    latitud: double.parse(lat
                                                            ?.latitude
                                                            .toStringAsFixed(
                                                                7) ??
                                                        "0"),
                                                    longitud: double.parse(
                                                        lat?.longitude
                                                                .toStringAsFixed(
                                                                    7) ??
                                                            "0"),
                                                    zonas: zonas
                                                        .map((e) => e.id!)
                                                        .toList());
                                            funcion(contacto: temp);
                                            Navigation.pop();
                                            await ContactoController.update(
                                                temp);

                                            provider.contacto =
                                                await ContactoController
                                                    .getItem(
                                                        lat: temp.latitud,
                                                        lng: temp.longitud);
                                            provider.animaMap.centerOnPoint(
                                                LatLng(
                                                    provider.contacto
                                                            ?.latitud ??
                                                        0,
                                                    provider.contacto
                                                            ?.longitud ??
                                                        0),
                                                zoom: 18);
                                          }));
                                }
                              },
                              child: AutoSizeText(snapshot.data ?? "?",
                                  style: TextStyle(fontSize: 16.sp),
                                  minFontSize: 9,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis))),
                      InkWell(
                          onTap: () async {
                            var zonas = await MapFun.checkPointWithZona(
                                point: LatLng(provider.contacto?.latitud ?? 0,
                                    provider.contacto?.longitud ?? 0));
                            showToast("${zonas.map((e) => e.nombre).toList()}");
                          },
                          onDoubleTap: () async {
                            if (provider.contacto!.id != null) {
                              var zonas = await MapFun.checkPointWithZona(
                                  point: LatLng(provider.contacto?.latitud ?? 0,
                                      provider.contacto?.longitud ?? 0));
                              var temp = provider.contacto!.copyWith(
                                  pendiente: 1,
                                  zonas: zonas.map((e) => e.id!).toList());
                              log("zonas ${zonas.map((e) => e.nombre).toList()}");
                              await ContactoController.update(temp);
                              provider.contacto =
                                  await ContactoController.getItem(
                                      id: temp.id!,
                                      lat: temp.latitud,
                                      lng: temp.longitud);
                              showToast("Zona actualizada");
                            }
                          },
                          onLongPress: () async {
                            await Clipboard.setData(ClipboardData(
                                text:
                                    "${provider.contacto?.latitud.toStringAsFixed(7)}, ${provider.contacto?.longitud.toStringAsFixed(7)}"));
                            showToast("Coordenadas copiadas");
                          },
                          child: Text(
                              "${kDebugMode ? "|${provider.contacto?.id}| " : ""}${provider.contacto?.latitud.toStringAsFixed(7)}, ${provider.contacto?.longitud.toStringAsFixed(7)}",
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontStyle: FontStyle.italic)))
                    ])),
            Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: TarjetaRsideWidget()))
          ]),
          TarjetaContactoDetalle(contacto: provider.contacto, compartir: false)
        ]));
  }
}
