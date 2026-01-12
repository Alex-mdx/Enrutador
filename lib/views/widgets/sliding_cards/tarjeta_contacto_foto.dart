import 'dart:convert';

import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as bd;
import 'package:sizer/sizer.dart';

import '../../../controllers/contacto_controller.dart';
import '../../../models/contacto_model.dart';
import '../../../utilities/camara_fun.dart';
import '../../../utilities/services/dialog_services.dart';
import '../../../utilities/theme/theme_app.dart';
import '../../../utilities/theme/theme_color.dart';
import '../galeria_widget.dart';
import '../visualizador_widget.dart';

class TarjetaContactoFoto extends StatefulWidget {
  final ContactoModelo? contacto;
  final bool compartir;
  const TarjetaContactoFoto(
      {super.key, required this.contacto, required this.compartir});

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
                          final XFile? photo = (await CamaraFun.getGalleria(
                                  context, "Seleccionar Foto del Cliente"))
                              .firstOrNull;

                          if (photo != null) {
                            final data = await photo.readAsBytes();
                            try {
                              var reducir =
                                  await FlutterImageCompress.compressWithList(
                                      data,
                                      minHeight: 540,
                                      minWidth: 960,
                                      quality: 70);
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
                  : GaleriaWidget(
                      image64: widget.contacto?.foto,
                      ontap: () => (!widget.compartir)
                          ? showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => VisualizadorWidget(
                                  image64: widget.contacto?.foto,
                                  carrusel:
                                      "Ultima modificacion\n${Textos.fechaYMDHMS(fecha: widget.contacto!.fotoFecha!)}"))
                          : null,
                      onDoubleTap: () async {
                        if (!widget.compartir) {
                          final XFile? photo = (await CamaraFun.getGalleria(
                                  context, "Seleccionar Foto del Cliente"))
                              .firstOrNull;

                          if (photo != null) {
                            final data = await photo.readAsBytes();
                            try {
                              var reducir =
                                  await FlutterImageCompress.compressWithList(
                                      data,
                                      minHeight: 540,
                                      minWidth: 960,
                                      quality: 70);
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
                      compartir: widget.compartir))),
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
                          final XFile? photo = (await CamaraFun.getGalleria(
                                  context, "Seleccionar Foto del Domicilio"))
                              .firstOrNull;

                          if (photo != null) {
                            final data = await photo.readAsBytes();
                            try {
                              var reducir =
                                  await FlutterImageCompress.compressWithList(
                                      data,
                                      minHeight: 540,
                                      minWidth: 960,
                                      quality: 70);
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
                  : GaleriaWidget(
                      image64: widget.contacto?.fotoReferencia,
                      ontap: () => (!widget.compartir)
                          ? showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => VisualizadorWidget(
                                  image64: widget.contacto?.fotoReferencia,
                                  carrusel:
                                      "Ultima modificacion\n${Textos.fechaYMDHMS(fecha: widget.contacto!.fotoReferenciaFecha!)}"))
                          : null,
                      onDoubleTap: () async {
                        if (!widget.compartir) {
                          final XFile? photo = (await CamaraFun.getGalleria(
                                  context, "Seleccionar Del Domicilio"))
                              .firstOrNull;

                          if (photo != null) {
                            final data = await photo.readAsBytes();
                            try {
                              var reducir =
                                  await FlutterImageCompress.compressWithList(
                                      data,
                                      minHeight: 540,
                                      minWidth: 960,
                                      quality: 70);
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
                      compartir: widget.compartir)))
    ]);
  }
}
