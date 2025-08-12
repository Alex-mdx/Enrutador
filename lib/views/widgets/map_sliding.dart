import 'dart:convert';

import 'package:advanced_media_picker/advanced_media_picker.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/funcion_parser.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../utilities/camara_fun.dart';
import '../../utilities/map_fun.dart';
import '../dialogs/dialog_send.dart';

class MapSliding extends StatefulWidget {
  const MapSliding({super.key});

  @override
  State<MapSliding> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MapSliding> {
  bool esperar = false;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return SlidingUpPanel(
        isDraggable: false,
        backdropEnabled: true,
        renderPanelSheet: false,
        backdropTapClosesPanel: true,
        defaultPanelState: PanelState.CLOSED,
        minHeight: 1.h,
        maxHeight: 40.h,
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
                    Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: Column(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                    width: 50.w,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (kDebugMode)
                                            Row(children: [
                                              Icon(LineIcons.wordFile,
                                                  size: 24.sp,
                                                  color: ThemaMain.red),
                                              Text("///XXX.XXX.XXX",
                                                  style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  "${provider.contacto?.id ?? "NO"}",
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontStyle:
                                                          FontStyle.italic)),
                                            ]),
                                          if (kDebugMode)
                                            LinearProgressIndicator(
                                                color: ThemaMain.red),
                                          Row(children: [
                                            TextButton.icon(
                                                icon: Icon(LineIcons.mapMarked,
                                                    size: 22.sp,
                                                    color: ThemaMain.primary),
                                                style: ButtonStyle(
                                                    elevation:
                                                        WidgetStatePropertyAll(
                                                            1),
                                                    padding:
                                                        WidgetStatePropertyAll(
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        1.w,
                                                                    vertical:
                                                                        5.sp))),
                                                onPressed: () async {
                                                  await Clipboard.setData(
                                                      ClipboardData(
                                                          text:
                                                              "${PlusCode.encode(LatLng(double.parse((provider.contacto?.latitud ?? 0).toStringAsFixed(6)), double.parse((provider.contacto?.longitud ?? 0).toStringAsFixed(6))), codeLength: 12)}"));
                                                  showToast(
                                                      "Plus Code copiados");
                                                },
                                                label: Text(
                                                    "${PlusCode.encode(LatLng(double.parse((provider.contacto?.latitud ?? 0).toStringAsFixed(6)), double.parse((provider.contacto?.longitud ?? 0).toStringAsFixed(6))), codeLength: 12)}",
                                                    style: TextStyle(
                                                        fontSize: 16.sp)))
                                          ]),
                                          Text(
                                              "${provider.contacto?.latitud.toStringAsFixed(6)} ${provider.contacto?.longitud.toStringAsFixed(6)}",
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontStyle: FontStyle.italic))
                                        ])),
                                Wrap(spacing: 1.w, children: [
                                  IconButton.filledTonal(
                                      iconSize: 22.sp,
                                      onPressed: () async => await ShareFun.share(
                                          titulo:
                                              "Comparte este codigo para obtener la direccion",
                                          mensaje:
                                              "//Ingrese este codigo en algun navegador de google para tener la ubicacion exacta.\n${PlusCode.encode(LatLng(double.parse((provider.contacto?.latitud ?? 0).toStringAsFixed(6)), double.parse((provider.contacto?.longitud ?? 0).toStringAsFixed(6))), codeLength: 12)}"),
                                      icon: Icon(Icons.share,
                                          color: ThemaMain.darkBlue)),
                                  IconButton.filledTonal(
                                      iconSize: provider.contacto?.id == null
                                          ? 22.sp
                                          : 18.sp,
                                      onPressed: () async {
                                        if (provider.contacto?.id == null) {
                                          await ContactoController.insert(
                                              provider.contacto!);
                                          provider.marker.clear();
                                          provider.contacto =
                                              await ContactoController.getItem(
                                                  lat: provider
                                                      .contacto!.latitud,
                                                  lng: provider
                                                      .contacto!.longitud);
                                        } else {
                                          await Dialogs.showMorph(
                                              title: "Eliminar Punteo",
                                              description:
                                                  "¿Desea eliminar este punteo?",
                                              loadingTitle: "Eliminando",
                                              onAcceptPressed: (context) async {
                                                await ContactoController
                                                    .deleteItem(
                                                        provider.contacto!.id!);
                                                var model =
                                                    ContactoModelo.fromJson({
                                                  "latitud": provider
                                                      .contacto!.latitud,
                                                  "longitud": provider
                                                      .contacto!.longitud,
                                                  "contacto_enlances": []
                                                });
                                                provider.contacto = model;
                                                await MapFun.touch(
                                                    provider: provider,
                                                    lat: model.latitud,
                                                    lng: model.longitud);
                                                showToast("Marcador limpiado");
                                              });
                                        }
                                      },
                                      icon: esperar
                                          ? CircularProgressIndicator()
                                          : provider.contacto?.id == null
                                              ? Icon(Icons.save,
                                                  color: ThemaMain.green)
                                              : Icon(Icons.delete,
                                                  color: ThemaMain.red))
                                ])
                              ]),
                          cardContacto(provider)
                        ]))
                  ]))
            ]));
  }

  Widget cardContacto(MainProvider provider) {
    return Card(
        color: ThemaMain.dialogbackground,
        child: AnimatedContainer(
            duration: Durations.medium3,
            height: provider.contacto?.id == null ? 0.h : 25.h,
            child: Scrollbar(
                child: ListView(children: [
              Row(children: [
                Expanded(flex: 1, child: fotos(provider)),
                Expanded(
                    flex: 4,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                    style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                horizontal: 1.w, vertical: 0))),
                                    onPressed: () => showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) => DialogSend(
                                            fun: (p0) async {
                                              var newModel = provider.contacto
                                                  ?.copyWith(
                                                      nombreCompleto: p0);
                                              await ContactoController.update(
                                                  newModel!);
                                              provider.contacto = newModel;
                                            },
                                            tipoTeclado: TextInputType.name,
                                            fecha: null,
                                            cabeza:
                                                "Ingresar nombre del contacto")),
                                    label: Text(
                                        "Nombre: ${provider.contacto?.nombreCompleto ?? "Sin nombre"}",
                                        style: TextStyle(fontSize: 16.sp))),
                                TextButton.icon(
                                    style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                horizontal: 1.w, vertical: 0))),
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => DialogSend(
                                            fun: (p0) async {
                                              var newModel = provider.contacto
                                                  ?.copyWith(
                                                      domicilio: p0,
                                                      fechaDomicilio:
                                                          DateTime.now());
                                              await ContactoController.update(
                                                  newModel!);
                                              provider.contacto = newModel;
                                            },
                                            tipoTeclado:
                                                TextInputType.streetAddress,
                                            fecha: provider
                                                .contacto?.fechaDomicilio,
                                            cabeza:
                                                "Ingresar domicilio del contacto")),
                                    label: Text(
                                        "Domicilio: ${provider.contacto?.domicilio ?? "Sin Domicilio"}",
                                        style: TextStyle(fontSize: 16.sp)))
                              ]),
                          Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                    style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                horizontal: 1.w, vertical: 0))),
                                    onPressed: () {},
                                    label: Text(
                                        "Tipo\n${provider.contacto?.tipo ?? "Ø"}",
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold))),
                                TextButton.icon(
                                    style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                horizontal: 1.w, vertical: 0))),
                                    onPressed: () {},
                                    label: Text(
                                        "Estado\n${provider.contacto?.estado ?? "Ø"}",
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold))),
                                TextButton.icon(
                                    style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                horizontal: 1.w, vertical: 0))),
                                    onLongPress: () async {
                                      if (provider.contacto?.numero != null) {
                                        var res = await FlutterPhoneDirectCaller
                                            .callNumber(provider
                                                    .contacto?.numero
                                                    .toString() ??
                                                "1");
                                        if (res != true) {
                                          showToast(
                                              "No se pudo ejecutar la llamada");
                                        }
                                      } else {
                                        showToast(
                                            "Numero de telefono no valido");
                                      }
                                    },
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => DialogSend(
                                            fun: (p0) async {
                                              if (int.tryParse(p0.toString()) !=
                                                  null) {
                                                var newModel = provider.contacto
                                                    ?.copyWith(
                                                        numero: int.parse(
                                                            p0.toString()),
                                                        numeroFecha:
                                                            DateTime.now());
                                                await ContactoController.update(
                                                    newModel!);
                                                provider.contacto = newModel;
                                              } else {
                                                showToast(
                                                    "Numero ingresado no valido");
                                              }
                                            },
                                            tipoTeclado: TextInputType.phone,
                                            fecha:
                                                provider.contacto?.numeroFecha,
                                            cabeza:
                                                "Ingresar numero telefonico del contacto")),
                                    label: Text(
                                        "Telefono\n${provider.contacto?.numero ?? "Ø"}",
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold))),
                                TextButton.icon(
                                    onLongPress: () async {
                                      if (provider.contacto?.otroNumero !=
                                          null) {
                                        var res = await FlutterPhoneDirectCaller
                                            .callNumber(provider
                                                    .contacto?.otroNumero
                                                    .toString() ??
                                                "1");
                                        if (res != true) {
                                          showToast(
                                              "No se pudo ejecutar la llamada");
                                        }
                                      } else {
                                        showToast("Numero ingresado no valido");
                                      }
                                    },
                                    style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                horizontal: 1.w, vertical: 0))),
                                    onPressed: () async {
                                      showDialog(
                                          context: context,
                                          builder: (context) => DialogSend(
                                              fun: (p0) async {
                                                if (int.tryParse(
                                                        p0.toString()) !=
                                                    null) {
                                                  var newModel = provider
                                                      .contacto
                                                      ?.copyWith(
                                                          otroNumero: int.parse(
                                                              p0.toString()),
                                                          otroNumeroFecha:
                                                              DateTime.now());
                                                  await ContactoController
                                                      .update(newModel!);
                                                  provider.contacto = newModel;
                                                } else {
                                                  showToast(
                                                      "Numero ingresado no valido");
                                                }
                                              },
                                              tipoTeclado: TextInputType.phone,
                                              fecha: provider
                                                  .contacto?.otroNumeroFecha,
                                              cabeza:
                                                  "Ingresar numero telefonico secundario del contacto"));
                                    },
                                    label: Text(
                                        "Otro Tel\n${provider.contacto?.otroNumero ?? "Ø"}",
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold)))
                              ]),
                          Text("Referencias:",
                              style: TextStyle(fontSize: 16.sp)),
                          Wrap(
                              runAlignment: WrapAlignment.spaceBetween,
                              spacing: .5.w,
                              children: [
                                ...provider.contacto?.contactoEnlances
                                        .map((e) => IconButton.filled(
                                            onPressed: () {},
                                            icon: Icon(LineIcons.userTag,
                                                color: ThemaMain.darkBlue)))
                                        .toList() ??
                                    [],
                                IconButton.filled(
                                    iconSize: 20.sp,
                                    onPressed: () {},
                                    icon: Icon(Icons.person_add,
                                        color: ThemaMain.green))
                              ]),
                          TextButton(
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => DialogSend(
                                      fun: (p0) async {
                                        var newModel =
                                            provider.contacto?.copyWith(
                                          nota: p0,
                                        );
                                        await ContactoController.update(
                                            newModel!);
                                        provider.contacto = newModel;
                                      },
                                      tipoTeclado: TextInputType.text,
                                      fecha: null,
                                      cabeza: "Ingresar notas del contacto")),
                              child: Text(
                                  "Notas\n${provider.contacto?.nota ?? "Sin notas"}",
                                  style: TextStyle(fontSize: 16.sp)))
                        ]))
              ])
            ]))));
  }

  Widget fotos(MainProvider provider) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
          decoration: BoxDecoration(
              color: ThemaMain.background,
              borderRadius: BorderRadius.circular(borderRadius)),
          child: (provider.contacto?.foto == null ||
                  provider.contacto?.foto == "null")
              ? InkWell(
                  onTap: () async {
                    final XFile? photo =
                        (await CamaraFun.getGalleria(context)).firstOrNull;

                    if (photo != null) {
                      final data = await photo.readAsBytes();
                      var reducir = Parser.reducirUint8List(
                          imgBytes: data, calidad: 70, relacion: 70);
                      if (reducir != null) {
                        var newModel = provider.contacto?.copyWith(
                            foto: base64Encode(reducir),
                            fotoFecha: DateTime.now());
                        await ContactoController.update(newModel!);
                        provider.contacto = newModel;
                      } else {
                        showToast("Error al comprimir imagen");
                      }
                    }
                  },
                  child: Icon(Icons.contacts,
                      size: 34.sp, color: ThemaMain.primary))
              : InkWell(
                  onLongPress: () => Dialogs.showMorph(
                      title: "Eliminar foto",
                      description: "¿Desea eliminar la foto seleccionada?",
                      loadingTitle: "Eliminando",
                      onAcceptPressed: (context) async {
                        var newModel = provider.contacto
                            ?.copyWith(foto: "null", fotoFecha: DateTime.now());
                        await ContactoController.update(newModel!);
                        showToast("Foto eliminada");
                        provider.contacto = newModel;
                      }),
                  onDoubleTap: () async {
                    final XFile? photo =
                        (await CamaraFun.getGalleria(context)).firstOrNull;

                    if (photo != null) {
                      final data = await photo.readAsBytes();
                      var reducir = Parser.reducirUint8List(
                          imgBytes: data, calidad: 70, relacion: 70);
                      if (reducir != null) {
                        var newModel = provider.contacto?.copyWith(
                            foto: base64Encode(reducir),
                            fotoFecha: DateTime.now());
                        await ContactoController.update(newModel!);
                        provider.contacto = newModel;
                      } else {
                        showToast("Error al comprimir imagen");
                      }
                    }
                  },
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) => Column(children: [
                            Expanded(
                                child: PhotoView.customChild(
                                    minScale: PhotoViewComputedScale.contained,
                                    maxScale:
                                        PhotoViewComputedScale.contained * 2,
                                    child: Image.memory(base64Decode(
                                        provider.contacto?.foto ?? "a")))),
                            Text(
                                "Ultima modificacion\n${Textos.fechaYMDHMS(fecha: provider.contacto!.fotoFecha!)}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: ThemaMain.white))
                          ])),
                  child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(borderRadius),
                      child: Image.memory(
                          base64Decode(provider.contacto?.foto ?? "a"),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                          width: 34.sp,
                          height: 34.sp,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              color: ThemaMain.red,
                              size: 34.sp))))),
      Divider(),
      Container(
          decoration: BoxDecoration(
              color: ThemaMain.background,
              borderRadius: BorderRadius.circular(borderRadius)),
          child: (provider.contacto?.fotoReferencia == null ||
                  provider.contacto?.fotoReferencia == "null")
              ? InkWell(
                  onTap: () async {
                    final XFile? photo =
                        (await CamaraFun.getGalleria(context)).firstOrNull;

                    if (photo != null) {
                      final data = await photo.readAsBytes();
                      var reducir = Parser.reducirUint8List(
                          imgBytes: data, calidad: 70, relacion: 70);
                      if (reducir != null) {
                        var newModel = provider.contacto?.copyWith(
                            fotoReferencia: base64Encode(reducir),
                            fotoReferenciaFecha: DateTime.now());
                        await ContactoController.update(newModel!);
                        provider.contacto = newModel;
                      } else {
                        showToast("Error al comprimir imagen");
                      }
                    }
                  },
                  child: Icon(Icons.image, color: ThemaMain.green, size: 34.sp))
              : InkWell(
                  onLongPress: () => Dialogs.showMorph(
                      title: "Eliminar foto",
                      description: "¿Desea eliminar la foto seleccionada?",
                      loadingTitle: "Eliminando",
                      onAcceptPressed: (context) async {
                        var newModel = provider.contacto?.copyWith(
                            fotoReferencia: "null", fotoFecha: DateTime.now());
                        await ContactoController.update(newModel!);
                        showToast("Foto eliminada");
                        provider.contacto = newModel;
                      }),
                  onDoubleTap: () async {
                    final XFile? photo =
                        (await CamaraFun.getGalleria(context)).firstOrNull;

                    if (photo != null) {
                      final data = await photo.readAsBytes();
                      var reducir = Parser.reducirUint8List(
                          imgBytes: data, calidad: 70, relacion: 70);
                      if (reducir != null) {
                        var newModel = provider.contacto?.copyWith(
                            fotoReferencia: base64Encode(reducir),
                            fotoReferenciaFecha: DateTime.now());
                        await ContactoController.update(newModel!);
                        provider.contacto = newModel;
                      } else {
                        showToast("Error al comprimir imagen");
                      }
                    }
                  },
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) => Column(children: [
                            Expanded(
                                child: PhotoView.customChild(
                                    minScale: PhotoViewComputedScale.contained,
                                    maxScale:
                                        PhotoViewComputedScale.contained * 2,
                                    child: Image.memory(base64Decode(
                                        provider.contacto?.fotoReferencia ??
                                            "a")))),
                            Text(
                                "Ultima modificacion\n${Textos.fechaYMDHMS(fecha: provider.contacto!.fotoReferenciaFecha!)}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: ThemaMain.white))
                          ])),
                  child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(borderRadius),
                      child: Image.memory(
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                          width: 34.sp,
                          height: 34.sp,
                          base64Decode(
                              provider.contacto?.fotoReferencia ?? "a"),
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              color: ThemaMain.red,
                              size: 34.sp)))))
    ]);
  }
}
