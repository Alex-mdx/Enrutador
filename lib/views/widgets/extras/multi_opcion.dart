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

class MultiOpcion extends StatefulWidget {
  final List<ContactoModelo> selects;
  final Future<void> Function() send;
  const MultiOpcion({super.key, required this.selects, required this.send});

  @override
  State<MultiOpcion> createState() => _MultiOpcionState();
}

class _MultiOpcionState extends State<MultiOpcion> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (context) => Dialog(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                              var envio =
                                  ((provider.usuario?.adminTipo ?? 0) >= 3 ||
                                      (provider.usuario?.adminTipo ?? 0) == -1);
                              if (widget.selects.length <= 5) {
                                await Dialogs.showMorph(
                                    title: envio
                                        ? "Envio de datos"
                                        : "Sincronizar",
                                    description:
                                        "¿Desea enviar este(os) contacto(s) a ${envio ? "sincronización" : "revision como pendiente"}?",
                                    loadingTitle: envio
                                        ? "sincronizando"
                                        : "Generando pendientes",
                                    loadingDescription:
                                        "Este proceso puede tomar unos minutos sea paciente",
                                    onAcceptPressed: (context) async {
                                      for (var i = 0;
                                          i < widget.selects.length;
                                          i++) {
                                        var cont =
                                            await ContactoController.getItemId(
                                                id: widget.selects[i].id!);

                                        var referencia =
                                            await ReferenciasController
                                                .getIdPrin(
                                                    idContacto: cont!.id!,
                                                    lat: cont.latitud,
                                                    lng: cont.longitud,
                                                    status: -1);

                                        var notas =
                                            await NotasController.getContactoId(
                                                cont.id!,
                                                pendiente: 1);
                                        if (envio) {
                                          var res =
                                              await FireConstants.sendServer(
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
                                        } else {
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
                                  riveIcon: ((provider.usuario?.adminTipo ??
                                                  0) >=
                                              3 ||
                                          (provider.usuario?.adminTipo ?? 0) ==
                                              -1)
                                      ? RiveIcon.reload
                                      : RiveIcon.search,
                                  color: ((provider.usuario?.adminTipo ?? 0) >=
                                              3 ||
                                          (provider.usuario?.adminTipo ?? 0) ==
                                              -1)
                                      ? ThemaMain.green
                                      : ThemaMain.primary,
                                  height: 32.sp,
                                  width: 32.sp,
                                  strokeWidth: 12.sp),
                              Text(
                                  ((provider.usuario?.adminTipo ?? 0) >= 3 ||
                                          (provider.usuario?.adminTipo ?? 0) ==
                                              -1)
                                      ? "Sincronizar"
                                      : "Pendientes",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold))
                            ])),
                          ),
                        InkWell(
                            onTap: () async {
                              if (widget.selects.length <= 100) {
                                List<ContactoModelo> temps = [];
                                for (var element in widget.selects) {
                                  var cont = await ContactoController.getItemId(
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
                            onTap: () async {},
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
                                  contactos: widget.selects,
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
                ]))),
        child: RiveAnimatedIcon(
            enableAbsorbPointer: true,
            riveIcon: RiveIcon.menuDots,
            color: ThemaMain.background,
            height: 22.sp,
            width: 22.sp,
            strokeWidth: 14.sp));
  }
}
