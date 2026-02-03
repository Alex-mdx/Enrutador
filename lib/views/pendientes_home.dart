import 'package:enrutador/controllers/contacto_fire.dart';
import 'package:enrutador/controllers/referencias_controller.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:enrutador/models/referencia_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../controllers/contacto_controller.dart';
import '../controllers/nota_controller.dart';
import '../models/contacto_model.dart';
import '../utilities/textos.dart';
import 'widgets/card_contacto_widget.dart';

class PendientesHome extends StatefulWidget {
  const PendientesHome({super.key});

  @override
  State<PendientesHome> createState() => _PendientesHomeState();
}

class _PendientesHomeState extends State<PendientesHome> {
  bool carga = false;
  List<ContactoModelo> contactos = [];
  List<NotaModel> notas = [];
  List<ReferenciaModelo> referencias = [];
  var index = 1;
  @override
  void initState() {
    super.initState();
    send();
  }

  Future<void> send() async {
    setState(() {
      carga = false;
    });
    contactos = await ContactoController.getPendientes();
    notas = await NotasController.getAll(pendiente: 1, long: 100);
    referencias = await ReferenciasController.getItems(estatus: -1, long: 50);
    setState(() {
      carga = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            title: Text("Mis Pendientes", style: TextStyle(fontSize: 18.sp)),
            toolbarHeight: 6.h,
            actions: []),
        body: Column(children: [
          Expanded(
              flex: 10,
              child: !carga
                  ? Center(
                      child: LoadingAnimationWidget.twoRotatingArc(
                          color: ThemaMain.primary, size: 24.sp))
                  : contactos.isEmpty
                      ? Center(
                          child: Text("No se encontraron contactos",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)))
                      : Scrollbar(
                          child: StickyGroupedListView<ContactoModelo, String>(
                              floatingHeader: true,
                              elements: contactos,
                              itemComparator: (a, b) => a.id!.compareTo(b.id!),
                              groupBy: (element) => element.modificado != null
                                  ? Textos.fechaYMD(fecha: element.modificado!)
                                  : "Sin fecha",
                              groupSeparatorBuilder: (element) => Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 2.w),
                                  decoration: BoxDecoration(
                                      color: ThemaMain.darkBlue,
                                      borderRadius:
                                          BorderRadius.circular(borderRadius)),
                                  child: Text(
                                      element.modificado != null
                                          ? Textos.fechaYMD(
                                              fecha: element.modificado!)
                                          : "Sin fecha",
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          color: ThemaMain.second,
                                          fontWeight: FontWeight.bold))),
                              itemBuilder: (context, contacto) =>
                                  Column(mainAxisSize: MainAxisSize.min, children: [
                                    slidableSelect(
                                        id: contacto.id!,
                                        delete: () async {
                                          await Dialogs.showMorph(
                                              title: "Eliminar envio",
                                              description:
                                                  "¿Desea quitar este cambio de los pendientes?\nTodos los cambios se mantendran de manera local",
                                              loadingTitle: "Eliminando",
                                              onAcceptPressed: (context) async {
                                                var data = contacto.copyWith(
                                                    pendiente: 0);
                                                await ContactoController.update(
                                                    data);
                                                await send();
                                              });
                                        },
                                        pendiente: () async {
                                          var referencia =
                                              await ReferenciasController
                                                  .getIdPrin(
                                                      idContacto: contacto.id!,
                                                      lat: contacto.latitud,
                                                      lng: contacto.longitud,
                                                      status: 1);

                                          var notas = await NotasController
                                              .getContactoId(contacto.id!,
                                                  pendiente: 1);
                                          await Dialogs.showMorph(
                                              title: "Pendiente",
                                              description:
                                                  "¿Desea enviar este contacto para que sea revisado?\nEstas enviando ${referencia.length} referencias y ${notas.length} notas ligadas a este contacto",
                                              loadingTitle: "Enviando",
                                              onAcceptPressed: (contexto) {});
                                        },
                                        directo: () {
                                          Dialogs.showMorph(
                                              title: "Sincronizar",
                                              description:
                                                  "¿Desea guardar este contacto con sus cambios de manera directa? ",
                                              loadingTitle: "Guardando",
                                              onAcceptPressed:
                                                  (contexto) async {
                                                var data = contacto.copyWith(
                                                    pendiente: 0,
                                                    aceptadoEmpleado: provider
                                                        .usuario?.empleadoId
                                                        ?.toString());
                                                var result =
                                                    await ContactoFire.send(
                                                        contacto: data);
                                                if (result) {
                                                  await ContactoController
                                                      .update(data);
                                                  await send();
                                                  showToast("Contacto enviado");
                                                } else {
                                                  showToast(
                                                      "Error al enviar datos");
                                                }
                                              });
                                        },
                                        model: CardContactoWidget(
                                            compartir: false,
                                            entrada: "",
                                            funContact: (p0) {},
                                            selectedVisible: false,
                                            onSelected: (p0) {},
                                            contacto: contacto)),
                                    if (notas
                                            .firstWhereOrNull((element) =>
                                                element.contactoId ==
                                                contacto.id)
                                            ?.id !=
                                        null)
                                      slidableSelect(
                                          id: notas
                                                  .firstWhereOrNull((element) =>
                                                      element.contactoId ==
                                                      contacto.id)
                                                  ?.id ??
                                              -1,
                                          delete: () {},
                                          pendiente: () {},
                                          directo: () {},
                                          model: Text(
                                              "Notas: ${notas.where((element) => element.contactoId == contacto.id).length}")),
                                    if (referencias.firstWhereOrNull(
                                            (element) =>
                                                element.idForanea ==
                                                contacto.id) !=
                                        null)
                                      slidableSelect(
                                          id: referencias
                                                  .firstWhereOrNull((element) =>
                                                      element.idForanea ==
                                                      contacto.id)
                                                  ?.id ??
                                              -1,
                                          delete: () {},
                                          pendiente: () {},
                                          directo: () {},
                                          model: Text(
                                              "Referencias: ${referencias.where((element) => element.idForanea == contacto.id).length}"))
                                  ]))))
        ]));
  }

  Slidable slidableSelect(
      {required int id,
      required Widget model,
      required Function() delete,
      required Function() pendiente,
      required Function() directo}) {
    return Slidable(
        key: ValueKey(id),
        startActionPane: ActionPane(motion: ScrollMotion(), children: [
          SlidableAction(
              spacing: 1.h,
              onPressed: (context) async => delete(),
              backgroundColor: ThemaMain.red,
              foregroundColor: Colors.white,
              icon: Icons.cleaning_services,
              label: 'Eliminar')
        ]),
        endActionPane: ActionPane(motion: ScrollMotion(), children: [
          SlidableAction(
              spacing: 1.h,
              onPressed: (context) async => await pendiente(),
              backgroundColor: ThemaMain.primary,
              foregroundColor: ThemaMain.background,
              icon: Icons.youtube_searched_for,
              label: 'Pendiente'),
          SlidableAction(
              spacing: 1.h,
              onPressed: (context) => directo(),
              backgroundColor: ThemaMain.green,
              foregroundColor: ThemaMain.background,
              icon: Icons.cloud_done,
              label: 'Guardar')
        ]),
        child: Stack(alignment: Alignment.center, children: [
          model,
          Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.keyboard_arrow_left_rounded,
                  size: 19.sp, color: ThemaMain.red)),
          Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.keyboard_double_arrow_right_rounded,
                  size: 19.sp, color: ThemaMain.green))
        ]));
  }
}
