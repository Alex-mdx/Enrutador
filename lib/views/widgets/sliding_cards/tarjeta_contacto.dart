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
                width: 54.w,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: PlusCodeFun.convert(
                              PlusCodeFun.psCODE(
                                  provider.contacto?.latitud ?? 0,
                                  provider.contacto?.longitud ?? 0),
                              toShortFormat: Preferences.psCodeExt),
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
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          DialogUbicacion(funLat: (lat) async {
                                            var temp = provider.contacto!
                                                .copyWith(
                                                    latitud: double.parse(
                                                        lat
                                                                ?.latitude
                                                                .toStringAsFixed(
                                                                    6) ??
                                                            "0"),
                                                    longitud: double.parse(lat
                                                            ?.longitude
                                                            .toStringAsFixed(
                                                                6) ??
                                                        "0"));
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
                                  minFontSize: 8,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis))),
                      InkWell(
                          onLongPress: () async {
                            await Clipboard.setData(ClipboardData(
                                text:
                                    "${PlusCodeFun.truncPlusCode(PlusCodeFun.psCODE(provider.contacto?.latitud ?? 0, provider.contacto?.longitud ?? 0)).latitude} ${PlusCodeFun.truncPlusCode(PlusCodeFun.psCODE(provider.contacto?.latitud ?? 0, provider.contacto?.longitud ?? 0)).longitude}"));
                            showToast("Coordenadas copiadas");
                          },
                          child: Text(
                              "${kDebugMode ? "|${provider.contacto?.id}| " : ""}${PlusCodeFun.truncPlusCode(PlusCodeFun.psCODE(provider.contacto?.latitud ?? 0, provider.contacto?.longitud ?? 0)).latitude} ${PlusCodeFun.truncPlusCode(PlusCodeFun.psCODE(provider.contacto?.latitud ?? 0, provider.contacto?.longitud ?? 0)).longitude}",
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
