import 'package:enrutador/views/dialogs/dialog_send_tip.dart';
import 'package:enrutador/views/page/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/contacto_controller.dart';
import '../../../controllers/fireController/fire_constants.dart';
import '../../../controllers/nota_controller.dart';
import '../../../controllers/referencias_controller.dart';
import '../../../models/contacto_model.dart';
import '../../../utilities/main_provider.dart';
import '../../../utilities/pdf_fun.dart';
import '../../../utilities/services/dialog_services.dart';
import '../../../utilities/share_fun.dart';
import '../../../utilities/theme/theme_color.dart';
import 'package:badges/badges.dart' as bd;

class MultiOpcion extends StatefulWidget {
  final List<String> selects;
  final Future<void> Function() send;
  const MultiOpcion({super.key, required this.selects, required this.send});

  @override
  State<MultiOpcion> createState() => _MultiOpcionState();
}

class _MultiOpcionState extends State<MultiOpcion> {
  List<ContactoModelo> contactos = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> charge() async {
    for (var element in widget.selects) {
      var c = (await ContactoController.getPersonalizado(
              query:
                  "id = ${int.parse(element.split("-")[0])} AND empleado_id = ${element.split("-")[1]}",
              limit: 1))
          .first;
      contactos.add(c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return bd.Badge(
      showBadge: true,
      position: bd.BadgePosition.topEnd(top: -5, end: -5),
      badgeStyle: bd.BadgeStyle(badgeColor: ThemaMain.darkBlue),
      badgeContent: Text("${widget.selects.length}",
          style: TextStyle(fontSize: 15.sp, color: ThemaMain.background)),
      child: FloatingActionButton(
          onPressed: () async {
            await charge();
            await showDialog(
                context: context,
                builder: (context) => Dialog(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      Text("Selector de opciones multiples",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      Wrap(
                          spacing: 1.w,
                          runSpacing: .1.h,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            if ((provider.usuario?.adminTipo ?? 0) >= 3 ||
                                (provider.usuario?.adminTipo ?? 0) == -1)
                              InkWell(
                                  onTap: () async {
                                    if (widget.selects.length <= 5) {
                                      await Dialogs.showMorph(
                                          title: "Sincronizar",
                                          description:
                                              "¿Desea enviar este(os) contacto(s) a sincronización?",
                                          loadingTitle: "sincronizando",
                                          loadingDescription:
                                              "Este proceso puede tomar unos minutos sea paciente",
                                          onAcceptPressed: (context) async {
                                            for (var i = 0;
                                                i < widget.selects.length;
                                                i++) {
                                              var cont =
                                                  await ContactoController
                                                      .getItemId(
                                                          id: contactos[i].id!);

                                              var referencia =
                                                  await ReferenciasController
                                                      .getIdPrin(
                                                          idContacto: cont!.id!,
                                                          lat: cont.latitud,
                                                          lng: cont.longitud,
                                                          status: -1);

                                              var notas = await NotasController
                                                  .getContactoId(cont.id!,
                                                      pendiente: 1);
                                              var res = await FireConstants
                                                  .sendServer(
                                                      contacto: cont,
                                                      referencia: referencia,
                                                      notas: notas,
                                                      empleado: provider
                                                          .usuario!.empleadoId!,
                                                      send: () async {});
                                              if (res) {
                                                showToast(
                                                    "Envio\nContacto numero ${i + 1} de ${widget.selects.length}");
                                              } else {
                                                showToast(
                                                    "No se pudo enviar el contacto numero ${i + 1}");
                                              }
                                            }
                                            widget.selects.clear();
                                            await widget.send();
                                          });
                                    } else {
                                      showToast(
                                          "No puedes enviar mas de 5 contactos al mismo tiempo.\nPor favor selecciona 5 o menos para enviar");
                                    }
                                  },
                                  child: Card(
                                      child: Column(children: [
                                    RiveAnimatedIcon(
                                        enableAbsorbPointer: true,
                                        riveIcon: RiveIcon.reload,
                                        color: ThemaMain.green,
                                        height: 32.sp,
                                        width: 32.sp,
                                        strokeWidth: 12.sp),
                                    Text("Sincronizar",
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold))
                                  ]))),
                            InkWell(
                                onTap: () async {
                                  if (widget.selects.length <= 5) {
                                    await Dialogs.showMorph(
                                        title: "Envio de datos",
                                        description:
                                            "¿Desea enviar este(os) contacto(s) a revision como pendiente?",
                                        loadingTitle: "Generando pendientes",
                                        loadingDescription:
                                            "Este proceso puede tomar unos minutos sea paciente",
                                        onAcceptPressed: (context) async {
                                          for (var i = 0;
                                              i < widget.selects.length;
                                              i++) {
                                            var cont = await ContactoController
                                                .getItemId(
                                                    id: contactos[i].id!);

                                            var referencia =
                                                await ReferenciasController
                                                    .getIdPrin(
                                                        idContacto: cont!.id!,
                                                        lat: cont.latitud,
                                                        lng: cont.longitud,
                                                        status: -1);

                                            var notas = await NotasController
                                                .getContactoId(cont.id!,
                                                    pendiente: 1);
                                            var res = await FireConstants
                                                .pendienteServer(
                                                    cont: cont,
                                                    referencia: referencia,
                                                    notas: notas,
                                                    empleado: provider
                                                        .usuario!.empleadoId!,
                                                    send: () async {});
                                            if (res) {
                                              showToast(
                                                  "Envio\nContacto numero ${i + 1} de ${widget.selects.length}");
                                            } else {
                                              showToast(
                                                  "No se pudo enviar el contacto numero ${i + 1}");
                                            }
                                          }
                                          widget.selects.clear();
                                          await widget.send();
                                        });
                                  } else {
                                    showToast(
                                        "No puedes enviar mas de 5 contactos al mismo tiempo.\nPor favor selecciona 5 o menos para enviar");
                                  }
                                },
                                child: Card(
                                    child: Column(children: [
                                  RiveAnimatedIcon(
                                      enableAbsorbPointer: true,
                                      riveIcon: RiveIcon.timer,
                                      color: ThemaMain.primary,
                                      height: 32.sp,
                                      width: 32.sp,
                                      strokeWidth: 12.sp),
                                  Text("Pendientes",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold))
                                ]))),
                            InkWell(
                                onTap: () async {
                                  if (widget.selects.length <= 100) {
                                    List<ContactoModelo> temps = [];
                                    for (var element in contactos) {
                                      var cont =
                                          await ContactoController.getItemId(
                                              id: element.id!);
                                      if (cont != null) {
                                        temps.add(cont);
                                      }
                                    }
                                    var archivo = await ShareFun.shareDatas(
                                        nombre: "contactos", datas: temps);
                                    if (archivo.isNotEmpty) {
                                      await ShareFun.share(
                                          titulo:
                                              "Este es un contenido compacto de tipos",
                                          mensaje: "objeto de contactos",
                                          files: archivo
                                              .map((e) => XFile(e.path))
                                              .toList());
                                    }
                                  } else {
                                    showToast(
                                        "No compartir de mas de 100 contactos.\nPor favor selecciona 100 o menos para compartir");
                                  }
                                },
                                child: Card(
                                    child: Column(children: [
                                  RiveAnimatedIcon(
                                      enableAbsorbPointer: true,
                                      riveIcon: RiveIcon.copy,
                                      color: ThemaMain.darkBlue,
                                      height: 32.sp,
                                      width: 32.sp,
                                      strokeWidth: 12.sp),
                                  Text("Copiar",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold))
                                ]))),
                            InkWell(
                                onTap: () async => showDialog(
                                    context: context,
                                    builder: (context) => DialogSendTip(
                                        tips: widget.selects,
                                        user: provider.usuario!)),
                                child: Card(
                                    child: Column(children: [
                                  RiveAnimatedIcon(
                                      enableAbsorbPointer: true,
                                      riveIcon: RiveIcon.bell,
                                      color: ThemaMain.yellow,
                                      height: 32.sp,
                                      width: 32.sp,
                                      strokeWidth: 12.sp),
                                  Text("Tip",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold))
                                ]))),
                            InkWell(
                                onTap: () async {
                                  var file = await PDFFun.buildReporteVentas(
                                      titular: "Reporte de ventas",
                                      contactos: contactos,
                                      user: provider.usuario!);
                                  if (file != null) {
                                    var pdfRoute = file.path;
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PdfViewer(path: pdfRoute)));
                                  }
                                },
                                child: Card(
                                    child: Column(children: [
                                  RiveAnimatedIcon(
                                      enableAbsorbPointer: true,
                                      riveIcon: RiveIcon.message,
                                      color: ThemaMain.red,
                                      height: 32.sp,
                                      width: 32.sp,
                                      strokeWidth: 12.sp),
                                  Text("Reporte",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold))
                                ])))
                          ])
                    ])));
          },
          child: RiveAnimatedIcon(
              enableAbsorbPointer: true,
              riveIcon: RiveIcon.menuDots,
              color: ThemaMain.background,
              height: 22.sp,
              width: 22.sp,
              strokeWidth: 14.sp)),
    );
  }
}
