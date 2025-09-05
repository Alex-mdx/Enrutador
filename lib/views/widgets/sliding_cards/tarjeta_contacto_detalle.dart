import 'dart:convert';

import 'package:badges/badges.dart' as bd;
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/views/dialogs/dialog_send.dart';
import 'package:enrutador/views/dialogs/dialogs_comunicar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/contacto_controller.dart';
import '../../../controllers/enrutar_controller.dart';
import '../../../controllers/tipo_controller.dart';
import '../../../models/contacto_model.dart';
import '../../../models/referencia_model.dart';
import '../../../utilities/camara_fun.dart';
import '../../../utilities/map_fun.dart';
import '../../../utilities/services/dialog_services.dart';
import '../../../utilities/textos.dart';
import '../../../utilities/theme/theme_app.dart';
import '../../../utilities/theme/theme_color.dart';
import '../../dialogs/dialog_direccion.dart';
import '../../dialogs/dialog_tipos_all.dart';

class TarjetaContactoDetalle extends StatefulWidget {
  final bool compartir;
  const TarjetaContactoDetalle({super.key, required this.compartir});

  @override
  State<TarjetaContactoDetalle> createState() => _TarjetaContactoDetalleState();
}

class _TarjetaContactoDetalleState extends State<TarjetaContactoDetalle> {
  Future<void> funcion({required ContactoModelo contacto}) async {
    var data =
        await EnrutarController.getItemContacto(contactoId: contacto.id!);

    if (data != null) {
      var newEnrutar = data.copyWith(buscar: contacto);
      await EnrutarController.update(newEnrutar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Card(
        color: ThemaMain.dialogbackground,
        child: AnimatedContainer(
            duration: Durations.medium1,
            height: widget.compartir ? null: provider.contacto?.id == null ? 0.h : 27.h,
            child: Row(children: [
              Expanded(flex: 4, child: fotos(provider)),
              VerticalDivider(width: 2.sp, indent: 1.h, endIndent: 1.h),
              Expanded(
                  flex: 10,
                  child: Scrollbar(
                      child: ListView(children: [
                    Column(
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
                                            entradaTexto: provider
                                                .contacto?.nombreCompleto,
                                            fun: (p0) async {
                                              var newModel = provider.contacto
                                                  ?.copyWith(
                                                      nombreCompleto:
                                                          Textos.normalizar(
                                                              p0 ?? ""));
                                              await ContactoController.update(
                                                  newModel!);
                                              funcion(contacto: newModel);
                                              provider.contacto = newModel;
                                            },
                                            tipoTeclado: TextInputType.name,
                                            fecha: null,
                                            cabeza:
                                                "Ingresar nombre del contacto")),
                                    label: Text(
                                        "Nombre: ${provider.contacto?.nombreCompleto ?? "Sin nombre"}",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold))),
                                TextButton.icon(
                                    style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                horizontal: 1.w, vertical: 0))),
                                    onPressed: () => showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) => DialogDireccion(
                                            word: provider.contacto?.domicilio,
                                            fun: (p0) async {
                                              var newModel = provider.contacto
                                                  ?.copyWith(
                                                      domicilio: p0,
                                                      fechaDomicilio:
                                                          DateTime.now());
                                              await ContactoController.update(
                                                  newModel!);
                                              funcion(contacto: newModel);
                                              provider.contacto = newModel;
                                            },
                                            fecha: provider
                                                .contacto?.fechaDomicilio)),
                                    label: Text(
                                        "Domicilio: ${provider.contacto?.domicilio ?? "Sin Domicilio"}",
                                        style: TextStyle(fontSize: 16.sp)))
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                              funcion(contacto: newModel);
                                              provider.contacto = newModel;
                                            })),
                                    label: FutureBuilder(
                                        future: TipoController.getItem(
                                            data:
                                                provider.contacto?.tipo ?? -1),
                                        builder: (context, data) {
                                          return Text(
                                              "Tipo: ${data.data?.nombre ?? "Ø"}",
                                              style: TextStyle(
                                                  color: data.data?.color,
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold));
                                        })),
                                TextButton.icon(
                                    style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                horizontal: 1.w, vertical: 0))),
                                    onPressed: () {},
                                    label: Text(
                                        "Estado: ${provider.contacto?.estado ?? "Ø"}",
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold)))
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                bd.Badge(
                                    badgeStyle: bd.BadgeStyle(
                                        badgeColor: ThemaMain.green),
                                    showBadge:
                                        PhoneNumber.findPotentialPhoneNumbers(
                                                    (provider.contacto?.numero ?? "0")
                                                        .toString())
                                                .firstOrNull
                                                ?.isValid() ??
                                            false,
                                    badgeContent: GestureDetector(
                                        onTap: () => showDialog(
                                            context: context,
                                            builder: (context) => DialogsComunicar(
                                                number:
                                                    (provider.contacto?.numero ?? 0)
                                                        .toString())),
                                        child: Icon(LineIcons.tty, size: 18.sp, color: ThemaMain.second)),
                                    child: TextButton.icon(
                                        style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 1.w, vertical: 0))),
                                        onPressed: () async {
                                          debugPrint(
                                              "${provider.contacto?.numero ?? "0"}");
                                          Iterable<PhoneNumber> country;
                                          country = PhoneNumber
                                              .findPotentialPhoneNumbers(
                                                  (provider.contacto?.numero ??
                                                          "0")
                                                      .toString());
                                          debugPrint(
                                              "${country.toList().map((e) => e).toList()}");
                                          String? lada =
                                              country.firstOrNull?.countryCode;
                                          debugPrint(lada);
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) => DialogSend(
                                                  lenght: 10,
                                                  lada: lada == null
                                                      ? null
                                                      : "+$lada",
                                                  entradaTexto: (provider
                                                              .contacto
                                                              ?.numero ??
                                                          "")
                                                      .toString()
                                                      .replaceAll("$lada", ""),
                                                  fun: (p0) async {
                                                    if (int.tryParse(
                                                            p0.toString()) !=
                                                        null) {
                                                      var newModel = provider
                                                          .contacto
                                                          ?.copyWith(
                                                              numero: int.parse(p0
                                                                  .toString()),
                                                              numeroFecha:
                                                                  DateTime
                                                                      .now());
                                                      await ContactoController
                                                          .update(newModel!);
                                                      funcion(
                                                          contacto: newModel);
                                                      provider.contacto =
                                                          newModel;
                                                    } else {
                                                      showToast(
                                                          "Numero ingresado no valido");
                                                    }
                                                  },
                                                  tipoTeclado:
                                                      TextInputType.phone,
                                                  fecha: provider
                                                      .contacto?.numeroFecha,
                                                  cabeza:
                                                      "Ingresar numero telefonico del contacto"));
                                        },
                                        label: Text("Telefono\n${PhoneNumber.findPotentialPhoneNumbers((provider.contacto?.numero ?? "0").toString()).firstOrNull?.international ?? 0}", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)))),
                                bd.Badge(
                                    badgeStyle: bd.BadgeStyle(
                                        badgeColor: ThemaMain.green),
                                    showBadge: PhoneNumber.findPotentialPhoneNumbers(
                                                (provider.contacto?.otroNumero ??
                                                        "0")
                                                    .toString())
                                            .firstOrNull
                                            ?.isValid(
                                                type: PhoneNumberType.mobile) ??
                                        false,
                                    badgeContent: GestureDetector(
                                        onTap: () => showDialog(
                                            context: context,
                                            builder: (context) => DialogsComunicar(
                                                number: (provider.contacto?.otroNumero ?? 0).toString())),
                                        child: Icon(LineIcons.tty, size: 18.sp, color: ThemaMain.second)),
                                    child: TextButton.icon(
                                        style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 1.w, vertical: 0))),
                                        onPressed: () {
                                          debugPrint(
                                              "${provider.contacto?.otroNumero ?? "0"}");
                                          Iterable<PhoneNumber> country;
                                          country = PhoneNumber
                                              .findPotentialPhoneNumbers(
                                                  (provider.contacto
                                                              ?.otroNumero ??
                                                          "0")
                                                      .toString());
                                          debugPrint(
                                              "${country.toList().map((e) => e).toList()}");
                                          String? lada =
                                              country.firstOrNull?.countryCode;
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) => DialogSend(
                                                  lenght: 10,
                                                  lada: lada == null
                                                      ? null
                                                      : "+$lada",
                                                  entradaTexto: (provider
                                                              .contacto
                                                              ?.otroNumero ??
                                                          "")
                                                      .toString()
                                                      .replaceAll("$lada", ""),
                                                  fun: (p0) async {
                                                    if (int.tryParse(
                                                            p0.toString()) !=
                                                        null) {
                                                      var newModel = provider
                                                          .contacto
                                                          ?.copyWith(
                                                              otroNumero:
                                                                  int.parse(p0
                                                                      .toString()),
                                                              otroNumeroFecha:
                                                                  DateTime
                                                                      .now());
                                                      await ContactoController
                                                          .update(newModel!);
                                                      funcion(
                                                          contacto: newModel);
                                                      provider.contacto =
                                                          newModel;
                                                    } else {
                                                      showToast(
                                                          "Numero ingresado no valido");
                                                    }
                                                  },
                                                  tipoTeclado:
                                                      TextInputType.phone,
                                                  fecha: provider.contacto
                                                      ?.otroNumeroFecha,
                                                  cabeza:
                                                      "Ingresar numero telefonico secundario del contacto"));
                                        },
                                        label: Text("Otro Tel\n${PhoneNumber.findPotentialPhoneNumbers((provider.contacto?.otroNumero ?? "0").toString()).firstOrNull?.international ?? 0}", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold))))
                              ]),
                          Text("Referencias:",
                              style: TextStyle(fontSize: 16.sp)),
                          Wrap(
                              runAlignment: WrapAlignment.spaceBetween,
                              spacing: .5.w,
                              children: [
                                ...provider.contacto?.contactoEnlances
                                        .map((e) => GestureDetector(
                                              onLongPress: () async {
                                                var temp = provider.contacto!
                                                    .copyWith(
                                                        contactoEnlances: []);
                                                await ContactoController.update(
                                                    temp);
                                                provider.contacto = temp;
                                              },
                                              child: Chip(
                                                  deleteIcon: Icon(
                                                      Icons.assistant_direction,
                                                      size: 20.sp,
                                                      color: ThemaMain.green),
                                                  onDeleted: () async {
                                                    await provider.slide
                                                        .close();
                                                    await MapFun.sendInitUri(
                                                        provider: provider,
                                                        lat: e.contactoIdRLat!,
                                                        lng: e.contactoIdRLng!);
                                                  },
                                                  labelPadding:
                                                      EdgeInsets.all(6.sp),
                                                  label: Text("Aval",
                                                      style: TextStyle(
                                                          fontSize: 15.sp))),
                                            ))
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
                                      entradaTexto: provider.contacto?.nota,
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
                        ])
                  ])))
            ])));
  }

  Widget fotos(MainProvider provider) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
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
                                minHeight: 540, minWidth: 960, quality: 75);
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
                      size: 25.w, color: ThemaMain.primary))
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
                                minHeight: 540, minWidth: 960, quality: 75);
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
                          width: 25.w,
                          height: 25.w,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              color: ThemaMain.red,
                              size: 25.w))))),
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
                                minHeight: 540, minWidth: 960, quality: 75);
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
                  child: Icon(Icons.image, color: ThemaMain.green, size: 24.w))
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
                                minHeight: 540, minWidth: 960, quality: 75);
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
                          width: 25.w,
                          height: 25.w,
                          base64Decode(
                              provider.contacto?.fotoReferencia ?? "a"),
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              color: ThemaMain.red,
                              size: 25.w)))))
    ]);
  }
}
