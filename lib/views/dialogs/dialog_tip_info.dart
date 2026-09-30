import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/fireController/usuario_fire.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/models/tip_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/fireController/tip_fire.dart';
import '../../models/usuario_model.dart';
import '../widgets/extras/card_contacto_download.dart';

class DialogTipInfo extends StatefulWidget {
  final TipModel tip;
  final Function refresh;
  const DialogTipInfo({super.key, required this.tip, required this.refresh});

  @override
  State<DialogTipInfo> createState() => _DialogTipInfoState();
}

class _DialogTipInfoState extends State<DialogTipInfo> {
  late TipModel tip;
  UsuarioModel? usuarioBy;
  TextEditingController respuestaController = TextEditingController();

  List<ContactoModelo> contactoTemp = [];

  bool cargaContact = false;

  bool downloading = false;
  @override
  void initState() {
    super.initState();
    tip = widget.tip;
    userBy(tip.empleadoBy);
  }

  Future<void> userBy(String empleadoId) async {
    try {
      var usuario =
          await UsuarioFire.getItem(table: "empleado_id", query: empleadoId);
      if (mounted) {
        setState(() {
          usuarioBy = usuario;
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(
          title: Text(widget.tip.uuid, style: TextStyle(fontSize: 16.sp)),
          toolbarHeight: 6.h),
      Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("De: ${usuarioBy?.nombre ?? "Sin nombre adjunto"}",
                style: TextStyle(fontSize: 14.sp)),
            Divider(),
            Container(
                padding: EdgeInsets.all(4.sp),
                decoration: BoxDecoration(
                    color: ThemaMain.background,
                    borderRadius: BorderRadius.circular(borderRadius)),
                constraints: BoxConstraints(maxHeight: 25.h),
                width: double.infinity,
                child: AutoSizeText(
                    (widget.tip.contexto?.isEmpty == true ||
                            widget.tip.contexto == "null")
                        ? "Sin contexto"
                        : widget.tip.contexto!,
                    textAlign: TextAlign.start,
                    maxLines: 8,
                    style: TextStyle(fontSize: 16.sp),
                    minFontSize: 11)),
            Divider(),
            AnimatedContainer(
                duration: Durations.short4,
                curve: Curves.easeInOut,
                constraints: BoxConstraints(maxHeight: 20.h),
                decoration: BoxDecoration(
                    color: ThemaMain.background,
                    borderRadius: BorderRadius.circular(borderRadius)),
                child: tip.contactosIds.isEmpty
                    ? Center(
                        child: Text("Hubo un error al encontrar los contactos",
                            style: TextStyle(fontSize: 14.sp)))
                    : Scrollbar(
                        trackVisibility: true,
                        thickness: 1.w,
                        child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4),
                            itemCount: tip.contactosIds.length,
                            itemBuilder: (context, index) =>
                                CardContactoDownload(
                                    tip: tip,
                                    contactoTemp: contactoTemp,
                                    refreshContactos: (contactos) {
                                      setState(() {
                                        contactoTemp = contactos;
                                      });
                                    },
                                    index: index,
                                    cargaContact: cargaContact,
                                    setCargaContact: (value) {
                                      setState(() {
                                        cargaContact = value;
                                      });
                                    })))),
            Divider(indent: 4.w, endIndent: 4.w),
            Padding(
                padding: EdgeInsets.all(4.sp),
                child: (tip.estadoTip == 0)
                    ? Container(
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                            color: ThemaMain.background,
                            borderRadius: BorderRadius.circular(borderRadius)),
                        constraints: BoxConstraints(maxHeight: 25.h),
                        width: double.infinity,
                        child: AutoSizeText(
                            (widget.tip.respuesta?.isEmpty == true ||
                                    widget.tip.respuesta == "null")
                                ? "Sin respuesta"
                                : widget.tip.respuesta!,
                            textAlign: TextAlign.start,
                            maxLines: 8,
                            style: TextStyle(fontSize: 16.sp),
                            minFontSize: 11))
                    : TextField(
                        controller: respuestaController,
                        maxLines: 3,
                        style: TextStyle(fontSize: 15.sp),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 1.w, vertical: .5.h),
                            labelText: "Agregar respuesta...",
                            labelStyle: TextStyle(fontSize: 15.sp),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(borderRadius))))),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ElevatedButton.icon(
                  onPressed: () async {
                    if (provider.usuario!.empleadoId != tip.empleadoTo) {
                      showToast(
                          "No puedes descargar tips que no se te han asignado.");
                      return;
                    }
                    if (contactoTemp.length != tip.contactosIds.length) {
                      showToast("No ha descargado todos los contactos");
                    }
                    if (downloading) {
                      showToast("Debes esperar a que se descargue el tip");
                      return;
                    }
                    setState(() {
                      downloading = true;
                    });
                    for (var contacto in contactoTemp) {
                      var exist = await ContactoController.getItemId(
                          id: contacto.id!, empleadoId: contacto.empleadoId);
                      var newTemp = contacto.copyWith(
                          pendiente: 1,
                          tip: 1,
                          empleadoTip: provider.usuario!.empleadoId);
                      if (exist != null) {
                        await ContactoController.update(newTemp);
                      } else {
                        await ContactoController.insert(newTemp);
                      }
                    }
                    showToast(
                        "Descarga completada\nYa tiene los contactos descargados como tip");
                    if (mounted) {
                      setState(() {
                        downloading = false;
                      });
                    }
                  },
                  label: Text("Descargar",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  icon: downloading
                      ? CircularProgressIndicator()
                      : Icon(Icons.downloading,
                          size: 20.sp, color: ThemaMain.green)),
              if (tip.estadoTip == 1)
                ElevatedButton.icon(
                    onPressed: () async {
                      if (downloading) {
                        showToast("Debes esperar a que se descargue el tip");
                        return;
                      }
                      if (respuestaController.text.isNotEmpty) {
                        await Dialogs.showMorph(
                            title: "Cerrar Tip",
                            description:
                                "¿Deseas cerrar el tip?\nYa no tendras acceso y se le notificara al creador de este tip.",
                            loadingTitle: "Cerrando...",
                            onAcceptPressed: (context) async {
                              var tipTemp = tip.copyWith(
                                  respuesta: respuestaController.text,
                                  fechaCerrado: DateTime.now(),
                                  estadoTip: 0);
                              var result = await TipFire.sendItem(
                                  table: "uuid",
                                  query: tipTemp.uuid,
                                  data: tipTemp);
                              if (result) {
                                showToast("Tip cerrado correctamente");
                                widget.refresh();
                                Navigation.pop();
                              } else {
                                showToast("Error al cerrar el tip");
                              }
                            });
                      } else {
                        showToast("Debes agregar una respuesta");
                      }
                    },
                    label: Text("Cerrar tip",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    icon: Icon(Icons.tips_and_updates,
                        size: 20.sp,
                        color:
                            downloading ? ThemaMain.darkGrey : ThemaMain.red)),
              if (tip.estadoTip == 0)
                ElevatedButton.icon(
                    onPressed: () async {
                      await Dialogs.showMorph(
                          title: "Eliminar Tip",
                          description:
                              "¿Deseas eliminar el tip?\nYa no tendras acceso y se le notificara al creador de este tip.",
                          loadingTitle: "Eliminando...",
                          onAcceptPressed: (context) async {
                            var tipTemp = tip.copyWith(
                                respuesta: respuestaController.text,
                                fechaCerrado: DateTime.now(),
                                estadoTip: 0);
                            var result =
                                await TipFire.deleteItem(model: tipTemp);
                            if (result) {
                              showToast("Tip eliminado correctamente");
                              widget.refresh();
                              Navigation.pop();
                            } else {
                              showToast("Error al eliminar el tip");
                            }
                          });
                    },
                    label: Text("Eliminar tip",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    icon: Icon(Icons.delete_forever,
                        size: 20.sp, color: ThemaMain.purple))
            ])
          ]))
    ]));
  }
}
