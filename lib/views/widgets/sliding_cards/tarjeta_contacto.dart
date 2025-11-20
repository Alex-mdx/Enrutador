import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/enrutar_controller.dart';
import 'package:enrutador/models/enrutar_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/views/dialogs/dialog_compartir.dart';
import 'package:enrutador/views/dialogs/dialog_mapas.dart';
import 'package:enrutador/views/dialogs/dialog_ubicacion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../../../models/contacto_model.dart';
import '../../../utilities/map_fun.dart';
import '../../../utilities/textos.dart';
import '../../../utilities/theme/theme_color.dart';
import 'tarjeta_contacto_detalle.dart';

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
        padding: EdgeInsets.all(10.sp),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(
                width: 46.w,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* if (kDebugMode)
                        Row(children: [
                          Icon(LineIcons.wordFile,
                              size: 24.sp, color: ThemaMain.red),
                          Text("///XXX.XXX.XXX",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)),
                          Text("${provider.contacto?.id ?? "NO"}",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontStyle: FontStyle.italic)),
                        ]), 
                      if (kDebugMode)
                        LinearProgressIndicator(color: ThemaMain.red),*/
                      Row(children: [
                        TextButton.icon(
                            onLongPress: () => showDialog(
                                context: context,
                                builder: (context) =>
                                    DialogUbicacion(funLat: (lat) async {
                                      var temp = provider.contacto!.copyWith(
                                          latitud: double.parse(lat?.latitude
                                                  .toStringAsFixed(6) ??
                                              "0"),
                                          longitud: double.parse(lat?.longitude
                                                  .toStringAsFixed(6) ??
                                              "0"));
                                      funcion(contacto: temp);
                                      Navigation.pop();
                                      await ContactoController.update(temp);

                                      provider.contacto =
                                          await ContactoController.getItem(
                                              lat: temp.latitud,
                                              lng: temp.longitud);
                                      provider.animaMap.centerOnPoint(
                                          LatLng(
                                              provider.contacto?.latitud ?? 0,
                                              provider.contacto?.longitud ?? 0),
                                          zoom: 18);
                                    })),
                            icon: Icon(LineIcons.mapMarked,
                                size: 22.sp, color: ThemaMain.primary),
                            style: ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                        horizontal: 1.w, vertical: 0))),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                  text: Textos.psCODE(
                                      provider.contacto?.latitud ?? 0,
                                      provider.contacto?.longitud ?? 0)));
                              showToast("Plus Code copiados");
                            },
                            label: Text(
                                Textos.psCODE(provider.contacto?.latitud ?? 0,
                                    provider.contacto?.longitud ?? 0),
                                style: TextStyle(fontSize: 16.sp)))
                      ]),
                      SelectableText(
                          "${kDebugMode ? "|${provider.contacto?.id}| " : ""}${provider.contacto?.latitud.toStringAsFixed(6)}, ${provider.contacto?.longitud.toStringAsFixed(6)}",
                          style: TextStyle(
                              fontSize: 15.sp, fontStyle: FontStyle.italic))
                    ])),
            Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        spacing: .5.w,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (provider.contacto?.id != null)
                            IconButton.filledTonal(
                                iconSize: 22.sp,
                                onPressed: () async => await showDialog(
                                    context: context,
                                    builder: (context) => DialogCompartir(
                                        contacto: provider.contacto!)),
                                icon: Icon(Icons.share,
                                    color: ThemaMain.darkBlue)),
                          IconButton.filled(
                              iconSize: 22.sp,
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(ThemaMain.green)),
                              color: ThemaMain.green,
                              onPressed: () async {
                                final availableMaps =
                                    await MapLauncher.installedMaps;
                                if (Preferences.mapa != "") {
                                  await availableMaps
                                      .firstWhere((element) =>
                                          element.mapType.name ==
                                          Preferences.mapa)
                                      .showMarker(
                                          zoom: 15,
                                          coords: Coords(
                                              provider.contacto!.latitud,
                                              provider.contacto!.longitud),
                                          title: provider
                                                  .contacto?.nombreCompleto ??
                                              "Ubicacion Seleccionada");
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) => DialogMapas(
                                          words: provider
                                                  .contacto?.nombreCompleto ??
                                              "Ubicacion Seleccionada",
                                          coordenadas: LatLng(
                                              provider.contacto!.latitud,
                                              provider.contacto!.longitud)));
                                }
                              },
                              icon: Icon(LineIcons.alternateMapMarked,
                                  color: ThemaMain.white)),
                          if (provider.contacto?.id != null)
                            FutureBuilder(
                                future: EnrutarController.getItemContacto(
                                    contactoId: provider.contacto!.id!),
                                builder: (context, snapshot) {
                                  return snapshot.hasData
                                      ? SizedBox()
                                      : IconButton.filled(
                                          iconSize: 22.sp,
                                          onPressed: () async {
                                            Dialogs.showMorph(
                                                title: "Enrutar",
                                                description:
                                                    "¿Usar este contacto para enrutar?\nSe metera este contacto a una lista para visitar",
                                                loadingTitle: "Enrutando...",
                                                onAcceptPressed:
                                                    (contexto) async {
                                                  EnrutarModelo data =
                                                      EnrutarModelo(
                                                          visitado: 0,
                                                          orden: 0,
                                                          contactoId: provider
                                                              .contacto!.id!,
                                                          buscar: provider
                                                              .contacto!);
                                                  await EnrutarController
                                                      .insert(data);
                                                  showToast(
                                                      "Contacto ingresado para el enrutamiento");
                                                });
                                          },
                                          icon: Icon(LineIcons.directions,
                                              color: ThemaMain.green));
                                }),
                          if (provider.contacto?.id != null)
                            ElevatedButton.icon(
                                style: ButtonStyle(
                                    elevation: WidgetStatePropertyAll(2),
                                    padding: WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(
                                            horizontal: .5.w, vertical: 0))),
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                        child: CalendarDatePicker(
                                            initialCalendarMode:
                                                DatePickerMode.day,
                                            initialDate: provider.contacto?.agendar ??
                                                DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now()
                                                .add(Duration(days: 365 * 6)),
                                            onDateChanged: (time) =>
                                                Dialogs.showMorph(
                                                    title: "Seleccionar fecha",
                                                    description:
                                                        "¿Esta seguro de seleccionar dicha fecha para visitar?",
                                                    loadingTitle: "Guardando",
                                                    onAcceptPressed:
                                                        (context) async {
                                                      var newModel = provider
                                                          .contacto
                                                          ?.copyWith(
                                                              agendar: time);
                                                      await ContactoController
                                                          .update(newModel!);
                                                      funcion(
                                                          contacto: newModel);
                                                      provider.contacto =
                                                          newModel;
                                                      Navigation.pop();
                                                    })))),
                                label: Text(
                                    provider.contacto?.agendar == null
                                        ? "Agendar visita"
                                        : "Visita ${Textos.conversionDiaNombre(provider.contacto!.agendar!, DateTime.now())}",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight:
                                            provider.contacto?.agendar == null
                                                ? FontWeight.normal
                                                : FontWeight.bold)),
                                icon: provider.contacto?.agendar == null
                                    ? Icon(LineIcons.calendarWithDayFocus, size: 20.sp)
                                    : null),
                          IconButton.filledTonal(
                              iconSize:
                                  provider.contacto?.id == null ? 22.sp : 18.sp,
                              onPressed: () async {
                                if (provider.contacto?.id == null) {
                                  await ContactoController.insert(
                                      provider.contacto!);
                                  provider.marker.clear();
                                  provider.contacto =
                                      await ContactoController.getItem(
                                          lat: provider.contacto!.latitud,
                                          lng: provider.contacto!.longitud);
                                } else {
                                  await Dialogs.showMorph(
                                      title: "Eliminar Punteo",
                                      description:
                                          "¿Desea eliminar este punteo?",
                                      loadingTitle: "Eliminando",
                                      onAcceptPressed: (context) async {
                                        await ContactoController.deleteItem(
                                            provider.contacto!.id!);
                                        var model = ContactoModelo.fromJson({
                                          "latitud": provider.contacto!.latitud,
                                          "longitud":
                                              provider.contacto!.longitud,
                                          "contacto_enlances": []
                                        });
                                        provider.contacto = model;
                                        await MapFun.touch(
                                            provider: provider,
                                            lat: model.latitud,
                                            lng: model.longitud);
                                        var datas = await EnrutarController
                                            .getItemContacto(
                                                contactoId:
                                                    provider.contacto!.id ??
                                                        -1);
                                        if (datas != null) {
                                          await EnrutarController.deleteItem(
                                              datas.id!);
                                        }
                                        showToast("Marcador limpiado");
                                      });
                                }
                              },
                              icon: esperar
                                  ? CircularProgressIndicator()
                                  : provider.contacto?.id == null
                                      ? Icon(Icons.save, color: ThemaMain.green)
                                      : Icon(Icons.delete,
                                          color: ThemaMain.red))
                        ])))
          ]),
          TarjetaContactoDetalle(contacto: provider.contacto, compartir: false)
        ]));
  }
}
