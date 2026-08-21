import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/fireController/usuario_fire.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/models/tip_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/card_contacto_widget.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../controllers/fireController/contacto_fire.dart';
import '../../models/usuario_model.dart';

class DialogTipInfo extends StatefulWidget {
  final TipModel tip;
  const DialogTipInfo({super.key, required this.tip});

  @override
  State<DialogTipInfo> createState() => _DialogTipInfoState();
}

class _DialogTipInfoState extends State<DialogTipInfo> {
  late TipModel tip;
  UsuarioModel? usuarioBy;
  TextEditingController respuestaController = TextEditingController();

  bool cargaContact = true;
  List<ContactoModelo> contactos = [];

  bool downloading = false;
  @override
  void initState() {
    super.initState();
    tip = widget.tip;
    userBy(tip.empleadoBy);
    getContactos(tip.contactosIds);
  }

  Future<void> userBy(String empleadoId) async {
    try {
      var usuario =
          await UsuarioFire.getItem(table: "empleado_id", query: empleadoId);
      setState(() {
        usuarioBy = usuario;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> getContactos(List<String> contactoIds) async {
    try {
      for (var contacto in contactoIds) {
        var idTemp = int.tryParse(contacto.split("-")[0]);
        var emIdTemp = contacto.split("-")[1];
        var filtro = Filter.and(Filter("id", isEqualTo: idTemp),
            Filter("empleado_id", isEqualTo: emIdTemp));
        var listContactos =
            await ContactoFire.getItemPersonalizado(filters: [filtro], max: 1);
        contactos.addAll(listContactos);
      }
      setState(() {
        cargaContact = false;
      });
    } catch (e) {
      setState(() {
        cargaContact = false;
      });
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
                constraints: BoxConstraints(
                    maxHeight: contactos.isEmpty && cargaContact ? 6.h : 20.h),
                decoration: BoxDecoration(
                    color: ThemaMain.background,
                    borderRadius: BorderRadius.circular(borderRadius)),
                child: contactos.isEmpty && cargaContact
                    ? Center(child: CircularProgressIndicator())
                    : contactos.isEmpty
                        ? Center(
                            child: Text(
                                "Hubo un error al encontrar los contactos",
                                style: TextStyle(fontSize: 14.sp)))
                        : Scrollbar(
                            trackVisibility: true,
                            thickness: 1.w,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: contactos.length,
                                itemBuilder: (context, index) {
                                  return CardContactoWidget(
                                      contacto: contactos[index],
                                      funContact: (p0) {},
                                      compartir: false,
                                      selectedVisible: false,
                                      onSelected: (p0) {});
                                }))),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: .5.h),
                child: TextField(
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
                    if (contactos.isEmpty) {
                      showToast("No hay contactos para descargar");
                      return;
                    }
                    if (downloading) {
                      showToast("Debes esperar a que se descargue el tip");
                      return;
                    }
                    setState(() {
                      downloading = true;
                    });
                    for (var contacto in contactos) {
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
                    setState(() {
                      downloading = false;
                    });
                  },
                  label: Text("Descargar",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  icon: downloading
                      ? CircularProgressIndicator()
                      : Icon(Icons.downloading,
                          size: 20.sp, color: ThemaMain.green)),
              ElevatedButton.icon(
                  onPressed: () {
                    if (downloading) {
                      showToast("Debes esperar a que se descargue el tip");
                      return;
                    }
                    if (respuestaController.text.isNotEmpty) {
                      Dialogs.showMorph(
                          title: "Cerrar Tip",
                          description:
                              "¿Desea cerrar el tip?\nYa no tendras acceso a esta y se le notificara al creador de está",
                          loadingTitle: "Cerrando...",
                          onAcceptPressed: () {});
                    } else {
                      showToast("Debes agregar una respuesta");
                    }
                  },
                  label: Text("Cerrar tip",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  icon: Icon(Icons.tips_and_updates,
                      size: 20.sp,
                      color: downloading ? ThemaMain.darkGrey : ThemaMain.red))
            ])
          ]))
    ]));
  }
}
