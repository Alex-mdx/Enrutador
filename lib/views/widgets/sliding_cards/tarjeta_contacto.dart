import 'dart:convert';

import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/utilities/camara_fun.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/views/dialogs/dialog_send.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/tipo_controller.dart';
import '../../../models/contacto_model.dart';
import '../../../models/referencia_model.dart';
import '../../../utilities/map_fun.dart';
import '../../../utilities/textos.dart';
import '../../../utilities/theme/theme_color.dart';
import '../../dialogs/dialog_tipos_all.dart';

class TarjetaContacto extends StatefulWidget {
  const TarjetaContacto({super.key});

  @override
  State<TarjetaContacto> createState() => _TarjetaContactoState();
}

class _TarjetaContactoState extends State<TarjetaContacto> {
  bool esperar = false;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(
                width: 50.w,
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
                            icon: Icon(LineIcons.mapMarked,
                                size: 22.sp, color: ThemaMain.primary),
                            style: ButtonStyle(
                                elevation: WidgetStatePropertyAll(1),
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                        horizontal: 1.w, vertical: 5.sp))),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                  text:
                                      "${PlusCode.encode(LatLng(double.parse((provider.contacto?.latitud ?? 0).toStringAsFixed(6)), double.parse((provider.contacto?.longitud ?? 0).toStringAsFixed(6))), codeLength: 12)}"));
                              showToast("Plus Code copiados");
                            },
                            label: Text(
                                "${PlusCode.encode(LatLng(double.parse((provider.contacto?.latitud ?? 0).toStringAsFixed(6)), double.parse((provider.contacto?.longitud ?? 0).toStringAsFixed(6))), codeLength: 12)}",
                                style: TextStyle(fontSize: 16.sp)))
                      ]),
                      Text(
                          "${provider.contacto?.latitud.toStringAsFixed(6)} ${provider.contacto?.longitud.toStringAsFixed(6)}",
                          style: TextStyle(
                              fontSize: 14.sp, fontStyle: FontStyle.italic))
                    ])),
            Wrap(spacing: 1.w, children: [
              IconButton.filledTonal(
                  iconSize: 22.sp,
                  onPressed: () async => await ShareFun.share(
                                          titulo: "Comparte este contacto",
                                          mensaje:
                                              "${ShareFun.copiar}\n*Plus Code*: ${PlusCode.encode(LatLng(provider.contacto?.latitud ?? 0, provider.contacto?.longitud ?? -1), codeLength: 12)}${provider.contacto?.nombreCompleto != null ? "\n*Nombre*: ${provider.contacto?.nombreCompleto}" : ""}${provider.contacto?.domicilio != null ? "\n*Domicilio*: ${provider.contacto?.domicilio}" : ""}${provider.contacto?.nota != null ? "\n*Notas*: ${provider.contacto?.nota}" : ""}"),
                  icon: Icon(Icons.share, color: ThemaMain.darkBlue)),
              IconButton.filledTonal(
                  iconSize: provider.contacto?.id == null ? 22.sp : 18.sp,
                  onPressed: () async {
                    if (provider.contacto?.id == null) {
                      await ContactoController.insert(provider.contacto!);
                      provider.marker.clear();
                      provider.contacto = await ContactoController.getItem(
                          lat: provider.contacto!.latitud,
                          lng: provider.contacto!.longitud);
                    } else {
                      await Dialogs.showMorph(
                          title: "Eliminar Punteo",
                          description: "¿Desea eliminar este punteo?",
                          loadingTitle: "Eliminando",
                          onAcceptPressed: (context) async {
                            await ContactoController.deleteItem(
                                provider.contacto!.id!);
                            var model = ContactoModelo.fromJson({
                              "latitud": provider.contacto!.latitud,
                              "longitud": provider.contacto!.longitud,
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
                          ? Icon(Icons.save, color: ThemaMain.green)
                          : Icon(Icons.delete, color: ThemaMain.red))
            ])
          ]),
          cardContacto(provider)
        ]));
  }

  Widget cardContacto(MainProvider provider) {
    return Card(
        color: ThemaMain.dialogbackground,
        child: AnimatedContainer(
            duration: Durations.medium3,
            height: provider.contacto?.id == null ? 0.h : 28.h,
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
                                        barrierDismissible: false,
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
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => DialogTiposAll(
                                                selected: (p0) async {
                                              var newModel = provider.contacto
                                                  ?.copyWith(
                                                      tipo: p0.id,
                                                      tipoFecha:
                                                          DateTime.now());
                                              await ContactoController.update(
                                                  newModel!);
                                              provider.contacto = newModel;
                                            })),
                                    label: FutureBuilder(
                                        future: TipoController.getItem(
                                            data:
                                                provider.contacto?.tipo ?? -1),
                                        builder: (context, data) {
                                          return Text(
                                              "Tipo\n${data.data?.nombre ?? "Ø"}",
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold));
                                        })),
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
                                        barrierDismissible: false,
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
                                          barrierDismissible: false,
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
                                if (provider.selectRefencia == null)
                                  IconButton.filled(
                                      iconSize: 20.sp,
                                      onPressed: () => Dialogs.showMorph(
                                          title: "Ingresar referencia",
                                          description:
                                              "Seleccione otro contacto para que sea referencia de este mismo",
                                          loadingTitle: "cargando",
                                          onAcceptPressed: (context) async {
                                            provider.selectRefencia =
                                                ReferenciaModelo(
                                                    contactoIdLat: provider
                                                        .contacto!.latitud,
                                                    contactoIdLng: provider
                                                        .contacto!.longitud,
                                                    contactoIdRLat: null,
                                                    contactoIdRLng: null,
                                                    buscar: -1,
                                                    tipoCliente: -1,
                                                    estatus: -1,
                                                    fecha: DateTime.now());
                                          }),
                                      icon: Icon(Icons.person_add,
                                          color: ThemaMain.green))
                              ]),
                          TextButton(
                              onPressed: () => showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => DialogSend(
                                      fun: (p0) async {
                                        var newModel = provider.contacto
                                            ?.copyWith(nota: p0);
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
                      try {
                        var reducir =
                            await FlutterImageCompress.compressWithList(data,
                                minHeight: 720, minWidth: 1280, quality: 50);
                        var newModel = provider.contacto?.copyWith(
                            foto: base64Encode(reducir),
                            fotoFecha: DateTime.now());
                        await ContactoController.update(newModel!);
                        provider.contacto = newModel;
                      } catch (e) {
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
                      try {
                        var reducir =
                            await FlutterImageCompress.compressWithList(data,
                                minHeight: 720, minWidth: 1280, quality: 50);
                        var newModel = provider.contacto?.copyWith(
                            foto: base64Encode(reducir),
                            fotoFecha: DateTime.now());
                        await ContactoController.update(newModel!);
                        provider.contacto = newModel;
                      } catch (e) {
                        showToast("Error al comprimir imagen");
                      }
                    }
                  },
                  onTap: () => showDialog(
                      barrierDismissible: false,
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
                      try {
                        var reducir =
                            await FlutterImageCompress.compressWithList(data,
                                minHeight: 720, minWidth: 1280, quality: 50);
                        var newModel = provider.contacto?.copyWith(
                            fotoReferencia: base64Encode(reducir),
                            fotoReferenciaFecha: DateTime.now());
                        await ContactoController.update(newModel!);
                        provider.contacto = newModel;
                      } catch (e) {
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
                      try {
                        var reducir =
                            await FlutterImageCompress.compressWithList(data,
                                minHeight: 720, minWidth: 1280, quality: 50);
                        var newModel = provider.contacto?.copyWith(
                            fotoReferencia: base64Encode(reducir),
                            fotoReferenciaFecha: DateTime.now());
                        await ContactoController.update(newModel!);
                        provider.contacto = newModel;
                      } catch (e) {
                        showToast("Error al comprimir imagen");
                      }
                    }
                  },
                  onTap: () => showDialog(
                      barrierDismissible: false,
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
