import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';

import '../controllers/contacto_controller.dart';
import '../models/contacto_model.dart';
import 'widgets/card_contacto_widget.dart';

class PendientesHome extends StatefulWidget {
  const PendientesHome({super.key});

  @override
  State<PendientesHome> createState() => _PendientesHomeState();
}

class _PendientesHomeState extends State<PendientesHome> {
  List<ContactoModelo> selects = [];
  bool carga = false;
  List<ContactoModelo> contactos = [];
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
    setState(() {
      carga = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Pendientes", style: TextStyle(fontSize: 18.sp)),
            toolbarHeight: 6.h,
            actions: [
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: RiveAnimatedIcon(
                      riveIcon: RiveIcon.search,
                      color: ThemaMain.primary,
                      height: 22.sp,
                      strokeWidth: 2.w,
                      width: 22.sp),
                  label: Text("Todo", style: TextStyle(fontSize: 14.sp)))
            ]),
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
                          child: ListView.builder(
                              itemCount: contactos.length,
                              itemBuilder: (context, index) {
                                return Slidable(
                                    key: ValueKey(contactos[index].id),
                                    startActionPane: ActionPane(
                                        motion: ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                              spacing: 1.h,
                                              onPressed: (context) async =>
                                                  await Dialogs.showMorph(
                                                      title: "Eliminar envio",
                                                      description:
                                                          "¿Desea quitar este cambio de los pendientes?\nTodos los cambios se mantendran de manera local",
                                                      loadingTitle:
                                                          "Eliminando",
                                                      onAcceptPressed:
                                                          (context) async {
                                                        var data =
                                                            contactos[index]
                                                                .copyWith(
                                                                    pendiente:
                                                                        0);
                                                        await ContactoController
                                                            .update(data);
                                                        await send();
                                                      }),
                                              backgroundColor: ThemaMain.red,
                                              foregroundColor: Colors.white,
                                              icon: Icons.cleaning_services,
                                              label: 'Eliminar')
                                        ]),
                                    endActionPane: ActionPane(
                                        motion: ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                              spacing: 1.h,
                                              onPressed: (context) =>
                                                  Dialogs.showMorph(
                                                      title: "Pendiente",
                                                      description:
                                                          "¿Desea enviar este contacto para que sea revisado? ",
                                                      loadingTitle: "Enviando",
                                                      onAcceptPressed:
                                                          (contexto) {}),
                                              backgroundColor:
                                                  ThemaMain.primary,
                                              foregroundColor:
                                                  ThemaMain.background,
                                              icon: Icons.youtube_searched_for,
                                              label: 'Pendiente'),
                                          SlidableAction(
                                              spacing: 1.h,
                                              onPressed: (context) =>
                                                  Dialogs.showMorph(
                                                      title: "Sincronizar",
                                                      description:
                                                          "¿Desea guardar este contacto con sus cambios de manera directa? ",
                                                      loadingTitle: "Guardando",
                                                      onAcceptPressed:
                                                          (contexto) {}),
                                              backgroundColor: ThemaMain.green,
                                              foregroundColor:
                                                  ThemaMain.background,
                                              icon: Icons.cloud_done,
                                              label: 'Guardar')
                                        ]),
                                    child: CardContactoWidget(
                                        compartir: false,
                                        entrada: "",
                                        funContact: (p0) {},
                                        selectedVisible: false,
                                        onSelected: (p0) {},
                                        contacto: contactos[index]));
                              })))
        ]));
  }
}
