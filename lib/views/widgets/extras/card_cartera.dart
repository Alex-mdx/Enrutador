import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/fireController/contacto_fire.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/extras/card_qr_widget.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../models/cartera_model.dart';
import '../../../models/contacto_model.dart';
import '../../../models/referencia_model.dart';
import '../../../utilities/share_fun.dart';

class CardCartera extends StatelessWidget {
  final CarteraModel cartera;
  final Function()? onTap;
  final Function()? onLongPress;
  const CardCartera(
      {super.key, required this.cartera, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async => onTap != null ? await onTap!() : null,
        onLongPress: () async =>
            onLongPress != null ? await onLongPress!() : null,
        child: Card(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .5.h),
                child: Column(children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Expanded(
                        flex: 6,
                        child: Column(children: [
                          Text(cartera.uuid,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)),
                          Divider(),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Icon(Icons.person,
                                      color: ThemaMain.green, size: 20.sp),
                                  Text("Creado: ${cartera.empleadoBy}",
                                      style: TextStyle(fontSize: 14.sp))
                                ]),
                                Row(children: [
                                  Icon(Icons.person_search,
                                      color: ThemaMain.yellow, size: 20.sp),
                                  Text("Asignado: ${cartera.empleadoTo}",
                                      style: TextStyle(fontSize: 14.sp))
                                ])
                              ]),
                          Row(children: [
                            Icon(LineIcons.userFriends,
                                size: 20.sp, color: ThemaMain.primary),
                            Text(
                                "Contactos ingresados: ${cartera.contactos.length} ",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold))
                          ])
                        ])),
                    Column(children: [
                      IconButton.filled(
                          iconSize: 22.sp,
                          onPressed: () async {
                            List<ContactoModelo> listTemp = [];
                            List<ReferenciaModelo> listRef = [];
                            bool aceptar = false;
                            for (var item in cartera.contactos) {
                              var (list, ref) =
                                  await ContactoController.globalizar(
                                      element: item);
                              listTemp.addAll(list);
                              listRef.addAll(ref);
                              log("list ${listTemp.length}");
                              log("ref ${listRef.length}");
                              if (listTemp.isNotEmpty) {
                                aceptar = true;
                              }
                            }
                            if (listTemp.isEmpty) {
                              await Dialogs.showMorph(
                                  title: "Descargar en servidor",
                                  description:
                                      "No se encontraron los contactos de manera local, desea descargarlo desde el servidor\nEste proceso tomara unos minutos segun el numero de contactos ingresados",
                                  loadingTitle:
                                      "Descargando\nTomara unos minutos",
                                  onAcceptPressed: (context) async {
                                    for (var item in cartera.contactos) {
                                      var idCont =
                                          int.parse(item.split("-")[0]);
                                      var empleadoId = item.split("-")[1];
                                      List<Filter> filtros = [
                                        Filter.and(
                                            Filter("id", isEqualTo: idCont),
                                            Filter("empleado_id",
                                                isEqualTo: empleadoId))
                                      ];
                                      var (list, ref) =
                                          await ContactoFire.getGeneral(
                                              filters: filtros,
                                              descending: true,
                                              max: 1,
                                              orderBy: "nombre_completo");
                                      listTemp = list;
                                      listRef = ref;
                                    }
                                    aceptar = true;
                                  });
                            }
                            if (aceptar && listTemp.isNotEmpty) {
                              var files = (await ShareFun.shareDatas(
                                      datas: [cartera, listTemp, listRef],
                                      nombre: "Cartera_${cartera.empleadoTo}",
                                      nombres: [
                                        "cartera",
                                        "contactos",
                                        "referencias"
                                      ]))
                                  .firstOrNull;
                              if (files != null) {
                                XFile file = XFile(files.path);
                                await ShareFun.share(
                                    titulo: "Cartera",
                                    mensaje:
                                        "Este es un archivo compartido, contiene una cartera con ${listTemp.length} contacto(s) y ${listRef.length} referencia(s) asociado(s), su codigo para importarla en el sistema es ${cartera.codigo}",
                                    files: [file]);
                              }
                            }
                          },
                          icon: Icon(Icons.share, color: ThemaMain.second)),
                      IconButton.filledTonal(
                          icon: Icon(Icons.qr_code, color: ThemaMain.darkBlue),
                          iconSize: 22.sp,
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                  child: QrWidget(
                                      text: cartera.codigo.toString(),
                                      size: 72.sp))))
                    ])
                  ])
                ]))));
  }
}
