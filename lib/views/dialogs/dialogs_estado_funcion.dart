import 'package:enrutador/controllers/estado_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/models/estado_model.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../controllers/fireController/usuario_fire.dart';
import '../../utilities/textos.dart';
import '../widgets/extras/card_children.dart';
import '../widgets/extras/paginador_widget.dart';

class DialogsEstadoFuncion extends StatefulWidget {
  final ContactoModelo contacto;
  final Function(ContactoModelo?) estatus;
  final DateTime? fecha;
  final String? empleadoId;
  const DialogsEstadoFuncion(
      {super.key,
      required this.contacto,
      required this.estatus,
      required this.fecha,
      required this.empleadoId});

  @override
  State<DialogsEstadoFuncion> createState() => _DialogsEstadoFuncion();
}

class _DialogsEstadoFuncion extends State<DialogsEstadoFuncion> {
  bool charge = false;
  List<EstadoModel> estados = [];
  List<bool> aceptar = [];
  late ContactoModelo contacto;

  bool search = true;
  List<UsuarioModel> actuales = [];
  int index = 1;
  int max = 0;
  final int maxLenght = 6;
  bool press = false;
  @override
  void initState() {
    name();
    send(1);
    super.initState();
    contacto = widget.contacto.copyWith(
        empleadoEstado: widget.contacto.empleadoEstado ?? widget.empleadoId);
  }

  Future<void> name() async {
    estados = await EstadoController.getItems();
    setState(() {
      aceptar.addAll(estados.map((e) => false));
      charge = true;
    });
  }

  Future<void> send(int idx) async {
    if (!mounted) return;
    setState(() {
      search = true;
    });
    max = await UsuarioFire.countAll(activo: true);
    setState(() {
      index = idx;
    });

    var list = await UsuarioFire.getAllItems(
        limit: maxLenght,
        index: idx - 1,
        orden: "nombre",
        decender: false,
        activo: true);

    if (!mounted) return;
    setState(() {
      actuales = list;
      search = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Estado de contacto", style: TextStyle(fontSize: 16.sp)),
      if (widget.fecha != null)
        Text("Ultima modificacion: ${Textos.fechaYMDHMS(fecha: widget.fecha!)}",
            style: TextStyle(fontSize: 15.sp, fontStyle: FontStyle.italic)),
      Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(children: [
            Text("Arrastre y suelte su contacto al estado que mas le parezca",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            Column(children: [
              if ((contacto.estado ?? -1) != -1 ||
                  contacto.empleadoEstado != null)
                ElevatedButton.icon(
                    onPressed: () {
                      var newTemp = contacto.copyWith(estado: -1)
                        ..empleadoEstado = null;
                      setState(() {
                        contacto = newTemp;
                      });
                    },
                    label: Text("Limpiar los estados",
                        style: TextStyle(fontSize: 15.sp)),
                    icon: Icon(Icons.cleaning_services_rounded,
                        color: ThemaMain.darkBlue, size: 20.sp)),
              Text(contacto.nombreCompleto ?? "Sin nombre",
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              Draggable(
                  data: [],
                  childWhenDragging: Icon(Icons.person,
                      size: 28.sp, color: ThemaMain.darkGrey),
                  feedback: Card(child: Icon(Icons.person, size: 22.sp)),
                  child: Card(child: Icon(Icons.person, size: 28.sp)))
            ]),
            Text(
                "Estado: ${estados.firstWhereOrNull((element) => element.id == contacto.estado)?.nombre ?? "Sin estado"}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp)),
            SizedBox(
                width: double.infinity,
                child: Card(
                    elevation: 0,
                    color: ThemaMain.background,
                    child: Column(children: [
                      Text("Inyectar usuario autor del estado",
                          style: TextStyle(fontSize: 15.sp)),
                      search
                          ? Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                  color: ThemaMain.primary, size: 22.sp))
                          : actuales.isEmpty
                              ? Text("No se han encontrado usuarios",
                                  style: TextStyle(fontSize: 14.sp))
                              : Wrap(
                                  alignment: WrapAlignment.spaceAround,
                                  spacing: .1.w,
                                  children: actuales
                                      .map((e) => CardChildren(
                                          e: e,
                                          width: 25.w,
                                          onTap: () => setState(() {
                                                if (e.empleadoId ==
                                                    provider
                                                        .usuario?.empleadoId) {
                                                  showToast(
                                                      "No puedes tomar tu propio contacto");
                                                  return;
                                                }
                                                if (contacto.empleadoEstado ==
                                                    e.empleadoId) {
                                                  contacto = contacto
                                                    ..empleadoEstado = null;
                                                } else {
                                                  contacto = contacto.copyWith(
                                                      empleadoEstado:
                                                          e.empleadoId);
                                                }
                                                debugPrint(contacto
                                                    .empleadoEstado
                                                    ?.toString());
                                              }),
                                          fontSize: 12.sp,
                                          card: contacto.empleadoEstado ==
                                                  e.empleadoId
                                              ? ThemaMain.green
                                              : ThemaMain.primary,
                                          elevation: 2))
                                      .toList()),
                      PaginadorGroupedWidget(
                          max: max,
                          length: actuales.length,
                          maxLenght: maxLenght,
                          send: (index) async => await send(index),
                          itemScrollController: null)
                    ]))),
            Divider(),
            Text("Estados disponibles", style: TextStyle(fontSize: 14.sp)),
            !charge
                ? CircularProgressIndicator()
                : estados.isEmpty
                    ? Text("No se han creado estados",
                        style: TextStyle(
                            fontSize: 14.sp, fontStyle: FontStyle.italic))
                    : Scrollbar(
                        child: Container(
                            constraints: BoxConstraints(maxHeight: 35.h),
                            child: GridView.builder(
                                itemCount: estados.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                itemBuilder: (context, index) => DragTarget(
                                    onLeave: (data) => aceptar[index] = false,
                                    onMove: (details) => aceptar[index] = true,
                                    onAcceptWithDetails: (details) {
                                      var newTemp = contacto.copyWith(
                                          estado: estados[index].id);
                                      setState(() {
                                        contacto = newTemp;
                                      });
                                      debugPrint("aceptar on acep");
                                      aceptar[index] = false;
                                    },
                                    builder: (context, candidateData, rejectedData) => AnimatedContainer(
                                        duration: kDebugMode
                                            ? Durations.extralong4
                                            : Durations.medium1,
                                        decoration: aceptar[index]
                                            ? BoxDecoration(
                                                color: aceptar[index]
                                                    ? estados[index].color ??
                                                        ThemaMain.primary
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        borderRadius))
                                            : null,
                                        height: aceptar[index] ? 5.w : 20.sp,
                                        width: aceptar[index] ? 5.w : 20.sp,
                                        alignment: Alignment.center,
                                        child: aceptar[index]
                                            ? Padding(
                                                padding: EdgeInsets.all(10.sp),
                                                child: Text(estados[index].nombre,
                                                    style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontWeight: FontWeight.bold)))
                                            : DotIndicator(size: contacto.estado == estados[index].id ? 24.sp : 20.sp, color: estados[index].color ?? ThemaMain.primary, child: contacto.estado == estados[index].id ? Icon(LineIcons.doubleCheck, color: ThemaMain.second, size: 20.sp) : null))))),
                      ),
            Divider(),
            ElevatedButton.icon(
                icon: Icon(Icons.contact_emergency,
                    size: 22.sp, color: ThemaMain.darkBlue),
                onPressed: () {
                  widget.estatus(contacto);
                  Navigation.pop();
                },
                label: Text("Aceptar",
                    style: TextStyle(
                        fontSize: 15.sp, fontWeight: FontWeight.bold)))
          ]))
    ]));
  }
}
