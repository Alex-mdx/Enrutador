import 'dart:convert';

import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as bd;
import 'package:sizer/sizer.dart';

import '../../../controllers/contacto_controller.dart';
import '../../../models/contacto_model.dart';
import '../../../utilities/camara_fun.dart';
import '../../../utilities/services/dialog_services.dart';
import '../../../utilities/theme/theme_app.dart';
import '../../../utilities/theme/theme_color.dart';

class TarjetaContactoFoto extends StatefulWidget {
  final ContactoModelo? contacto;
  final bool compartir;
  const TarjetaContactoFoto({super.key, required  this.contacto, required this.compartir});

  @override
  State<TarjetaContactoFoto> createState() => _TarjetaContactoFotoState();
}

class _TarjetaContactoFotoState extends State<TarjetaContactoFoto> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      bd.Badge(
          showBadge: !widget.compartir &&
              (widget.contacto?.foto != null &&
                  widget.contacto?.foto != "null"),
          badgeStyle: bd.BadgeStyle(badgeColor: Colors.transparent),
          badgeContent: GestureDetector(
              onTap: () => Dialogs.showMorph(
                  title: "Eliminar foto",
                  description: "¿Desea eliminar la foto seleccionada?",
                  loadingTitle: "Eliminando",
                  onAcceptPressed: (context) async {
                    var newModel = widget.contacto
                        ?.copyWith(foto: "null", fotoFecha: DateTime.now());
                    await ContactoController.update(newModel!);
                    showToast("Foto eliminada");
                    provider.contacto = newModel;
                  }),
              child: Icon(Icons.delete, color: ThemaMain.red, size: 18.sp)),
          child: Container(
              decoration: BoxDecoration(
                  color: ThemaMain.background,
                  borderRadius: BorderRadius.circular(borderRadius)),
              child: (widget.contacto?.foto == null ||
                      widget.contacto?.foto == "null")
                  ? InkWell(
                      onTap: () async {
                        if (!widget.compartir) {
                          final XFile? photo =
                              (await CamaraFun.getGalleria(context))
                                  .firstOrNull;

                          if (photo != null) {
                            final data = await photo.readAsBytes();
                            try {
                              var reducir =
                                  await FlutterImageCompress.compressWithList(
                                      data,
                                      minHeight: 540,
                                      minWidth: 960,
                                      quality: 75);
                              var newModel = widget.contacto?.copyWith(
                                  foto: base64Encode(reducir),
                                  fotoFecha: DateTime.now());
                              await ContactoController.update(newModel!);
                              provider.contacto = newModel;
                            } catch (e) {
                              showToast("Error al comprimir imagen");
                            }
                          }
                        }
                      },
                      child: Icon(Icons.contacts,
                          size: widget.compartir ? 30.w : 21.w,
                          color: ThemaMain.primary))
                  : InkWell(
                      onLongPress: () async {
                        try {
                          await Pasteboard.writeImage(
                              base64Decode(widget.contacto!.foto!));

                          final files = await Pasteboard.files();
                          debugPrint("$files");
                          showToast("Imagen copiada al portapapeles");
                        } catch (e) {
                          debugPrint("$e");
                        }
                      },
                      onDoubleTap: () async {
                        if (!widget.compartir) {
                          final XFile? photo =
                              (await CamaraFun.getGalleria(context))
                                  .firstOrNull;

                          if (photo != null) {
                            final data = await photo.readAsBytes();
                            try {
                              var reducir =
                                  await FlutterImageCompress.compressWithList(
                                      data,
                                      minHeight: 540,
                                      minWidth: 960,
                                      quality: 75);
                              var newModel = widget.contacto?.copyWith(
                                  foto: base64Encode(reducir),
                                  fotoFecha: DateTime.now());
                              await ContactoController.update(newModel!);
                              provider.contacto = newModel;
                            } catch (e) {
                              showToast("Error al comprimir imagen");
                            }
                          }
                        }
                      },
                      onTap: () => showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => Column(children: [
                                Expanded(
                                    child: PhotoView.customChild(
                                        minScale:
                                            PhotoViewComputedScale.contained,
                                        maxScale:
                                            PhotoViewComputedScale.contained *
                                                2,
                                        child: Image.memory(base64Decode(
                                            widget.contacto?.foto ?? "a")))),
                                Text(
                                    "Ultima modificacion\n${Textos.fechaYMDHMS(fecha: widget.contacto!.fotoFecha!)}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: ThemaMain.white))
                              ])),
                      child: ClipRRect(
                          borderRadius:
                              BorderRadiusGeometry.circular(borderRadius),
                          child: Image.memory(
                              base64Decode(widget.contacto?.foto ?? "a"),
                              fit: widget.compartir
                                  ? BoxFit.fitHeight
                                  : BoxFit.cover,
                              filterQuality: widget.compartir
                                  ? FilterQuality.medium
                                  : FilterQuality.low,
                              width: widget.compartir ? 30.w : 21.w,
                              height: widget.compartir ? 30.w : 21.w,
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image,
                                      color: ThemaMain.red,
                                      size:
                                          widget.compartir ? 30.w : 21.w)))))),
      bd.Badge(
          showBadge: !widget.compartir &&
              (widget.contacto?.fotoReferencia != null &&
                  widget.contacto?.fotoReferencia != "null"),
          badgeStyle: bd.BadgeStyle(badgeColor: Colors.transparent),
          badgeContent: GestureDetector(
              onTap: () => Dialogs.showMorph(
                  title: "Eliminar foto",
                  description: "¿Desea eliminar la foto seleccionada?",
                  loadingTitle: "Eliminando",
                  onAcceptPressed: (context) async {
                    var newModel = widget.contacto?.copyWith(
                        fotoReferencia: "null",
                        fotoReferenciaFecha: DateTime.now());
                    await ContactoController.update(newModel!);
                    showToast("Foto eliminada");
                    provider.contacto = newModel;
                  }),
              child: Icon(Icons.delete, color: ThemaMain.red, size: 18.sp)),
          child: Container(
              decoration: BoxDecoration(
                  color: ThemaMain.background,
                  borderRadius: BorderRadius.circular(borderRadius)),
              child: (widget.contacto?.fotoReferencia == null ||
                      widget.contacto?.fotoReferencia == "null")
                  ? InkWell(
                      onTap: () async {
                        if (!widget.compartir) {
                          final XFile? photo =
                              (await CamaraFun.getGalleria(context))
                                  .firstOrNull;

                          if (photo != null) {
                            final data = await photo.readAsBytes();
                            try {
                              var reducir =
                                  await FlutterImageCompress.compressWithList(
                                      data,
                                      minHeight: 540,
                                      minWidth: 960,
                                      quality: 75);
                              var newModel = widget.contacto?.copyWith(
                                  fotoReferencia: base64Encode(reducir),
                                  fotoReferenciaFecha: DateTime.now());
                              await ContactoController.update(newModel!);
                              provider.contacto = newModel;
                            } catch (e) {
                              showToast("Error al comprimir imagen");
                            }
                          }
                        }
                      },
                      child: Icon(Icons.image,
                          color: ThemaMain.green,
                          size: widget.compartir ? 30.w : 21.w))
                  : InkWell(
                      onLongPress: () async {
                        try {
                          await Pasteboard.writeImage(
                              base64Decode(widget.contacto!.fotoReferencia!));

                          final files = await Pasteboard.files();
                          debugPrint("$files");
                          showToast("Imagen copiada al portapapeles");
                        } catch (e) {
                          debugPrint("$e");
                        }
                      },
                      onDoubleTap: () async {
                        if (!widget.compartir) {
                          final XFile? photo =
                              (await CamaraFun.getGalleria(context))
                                  .firstOrNull;

                          if (photo != null) {
                            final data = await photo.readAsBytes();
                            try {
                              var reducir =
                                  await FlutterImageCompress.compressWithList(
                                      data,
                                      minHeight: 540,
                                      minWidth: 960,
                                      quality: 75);
                              var newModel = widget.contacto?.copyWith(
                                  fotoReferencia: base64Encode(reducir),
                                  fotoReferenciaFecha: DateTime.now());
                              await ContactoController.update(newModel!);
                              provider.contacto = newModel;
                            } catch (e) {
                              showToast("Error al comprimir imagen");
                            }
                          }
                        }
                      },
                      onTap: () => (!widget.compartir)
                          ? showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => Column(children: [
                                    Expanded(
                                        child: PhotoView.customChild(
                                            minScale: PhotoViewComputedScale
                                                .contained,
                                            maxScale: PhotoViewComputedScale
                                                    .contained *
                                                2,
                                            child: Image.memory(base64Decode(
                                                widget.contacto
                                                        ?.fotoReferencia ??
                                                    "a")))),
                                    Text(
                                        "Ultima modificacion\n${Textos.fechaYMDHMS(fecha: widget.contacto!.fotoReferenciaFecha!)}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: ThemaMain.white))
                                  ]))
                          : null,
                      child: ClipRRect(
                          borderRadius:
                              BorderRadiusGeometry.circular(borderRadius),
                          child: Image.memory(
                              fit: widget.compartir
                                  ? BoxFit.fitHeight
                                  : BoxFit.cover,
                              filterQuality: widget.compartir
                                  ? FilterQuality.medium
                                  : FilterQuality.low,
                              width: widget.compartir ? 30.w : 21.w,
                              height: widget.compartir ? 30.w : 21.w,
                              base64Decode(
                                  widget.contacto?.fotoReferencia ?? "a"),
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image,
                                      color: ThemaMain.red,
                                      size: widget.compartir ? 30.w : 21.w))))))
    ]);
  }
}