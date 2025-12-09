import 'package:enrutador/controllers/estado_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/models/estado_model.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../utilities/textos.dart';

class DialogsEstadoFuncion extends StatefulWidget {
  final ContactoModelo contacto;
  final Function(int?) estatus;
  final DateTime? fecha;
  const DialogsEstadoFuncion(
      {super.key,
      required this.contacto,
      required this.estatus,
      required this.fecha});

  @override
  State<DialogsEstadoFuncion> createState() => _DialogsEstadoFuncion();
}

class _DialogsEstadoFuncion extends State<DialogsEstadoFuncion> {
  bool charge = false;
  List<EstadoModel> estados = [];
  List<bool> aceptar = [];
  late ContactoModelo contacto;
  @override
  void initState() {
    name();
    super.initState();
    contacto = widget.contacto;
  }

  Future<void> name() async {
    estados = await EstadoController.getItems();
    setState(() {
      aceptar.addAll(estados.map((e) => false));
      charge = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              ElevatedButton.icon(
                  onPressed: () {
                    var newTemp = contacto.copyWith(estado: -1);
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
                style: TextStyle(fontSize: 15.sp)),
            Divider(),
            Text("Estados disponibles", style: TextStyle(fontSize: 14.sp)),
            !charge
                ? CircularProgressIndicator()
                : estados.isEmpty
                    ? Text("No se han creado estados",
                        style: TextStyle(
                            fontSize: 14.sp, fontStyle: FontStyle.italic))
                    : SizedBox(
                        height: 35.h,
                        child: GridView.builder(
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: estados.length),
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
                                builder: (context, candidateData, rejectedData) =>
                                    AnimatedContainer(
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
                                        height: aceptar[index] ? 12.h : 21.sp,
                                        width: aceptar[index] ? 23.w : 21.sp,
                                        duration: Durations.medium1,
                                        alignment: Alignment.topCenter,
                                        child: aceptar[index]
                                            ? Padding(
                                                padding: EdgeInsets.all(10.sp),
                                                child: Text(estados[index].nombre,
                                                    style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontWeight: FontWeight.bold)))
                                            : DotIndicator(size: contacto.estado == estados[index].id ? 24.sp : 20.sp, color: estados[index].color ?? ThemaMain.primary, child: contacto.estado == estados[index].id ? Icon(LineIcons.doubleCheck, color: ThemaMain.second, size: 20.sp) : null))))),
            Divider(),
            ElevatedButton.icon(
                icon: Icon(Icons.contact_emergency,
                    size: 22.sp, color: ThemaMain.darkBlue),
                onPressed: () {
                  widget.estatus(contacto.estado);
                  Navigation.pop();
                },
                label: Text("Aceptar",
                    style: TextStyle(
                        fontSize: 15.sp, fontWeight: FontWeight.bold)))
          ]))
    ]));
  }
}
