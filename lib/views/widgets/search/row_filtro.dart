import 'dart:developer';

import 'package:enrutador/controllers/estado_controller.dart';
import 'package:enrutador/controllers/tipo_controller.dart';
import 'package:enrutador/models/estado_model.dart';
import 'package:enrutador/models/tipos_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/views/widgets/list_estado_widget.dart';
import 'package:enrutador/views/widgets/list_tipo_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_color.dart';
import '../../dialogs/dialog_zona_view.dart';

class RowFiltro extends StatefulWidget {
  final List<String> tipos;
  final List<String> estados;
  final List<String> zonas;
  final Function? press;
  final Function(List<String> tipo, List<String> estado, List<String> zona)
      updateData;
  const RowFiltro(
      {super.key,
      this.press,
      required this.updateData,
      required this.tipos,
      required this.estados,
      required this.zonas});

  @override
  State<RowFiltro> createState() => _RowFiltroState();
}

class _RowFiltroState extends State<RowFiltro> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(spacing: .5.w, children: [
          chips(
              icono: Icons.type_specimen,
              cabeza: widget.tipos.isEmpty
                  ? "Tipo"
                  : widget.tipos
                      .map((e) => provider.tipos
                          .firstWhereOrNull((ti) => ti.id == int.tryParse(e))
                          ?.nombre)
                      .join(", "),
              fun: () => showDialog(
                  context: context,
                  builder: (context) => Dialog(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        Text("Seleccione tipos para filtrar",
                            style: TextStyle(fontSize: 16.sp)),
                        Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Container(
                                constraints: BoxConstraints(maxHeight: 80.h),
                                child: FutureBuilder(
                                    future: TipoController.getItems(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, index) {
                                              TiposModelo tipo =
                                                  snapshot.data![index];
                                              return ListTipoWidget(
                                                  tipo: tipo,
                                                  fun: () {},
                                                  share: false,
                                                  selectedVisible: true,
                                                  selected: widget.tipos
                                                      .contains(
                                                          tipo.id.toString()),
                                                  onSelected: (p0) {
                                                    var temp = widget.tipos
                                                        .map(
                                                            (e) => int.parse(e))
                                                        .toList();
                                                    if (temp
                                                        .contains(tipo.id)) {
                                                      temp.remove(tipo.id);
                                                    } else {
                                                      temp.add(tipo.id!);
                                                    }
                                                    setState(() {
                                                      widget.updateData(
                                                          temp
                                                              .map((e) =>
                                                                  e.toString())
                                                              .toList(),
                                                          widget.estados,
                                                          widget.zonas);
                                                      if (widget.press !=
                                                          null) {
                                                        widget.press!();
                                                      }
                                                    });

                                                    Navigation.pop();
                                                  });
                                            });
                                      } else if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}",
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                fontStyle: FontStyle.italic));
                                      } else {
                                        return Padding(
                                            padding: EdgeInsets.all(8.sp),
                                            child: CircularProgressIndicator());
                                      }
                                    })))
                      ]))),
              colorprincipal: ThemaMain.primary,
              condicion: widget.tipos.isNotEmpty,
              delete: () => setState(() {
                    widget.updateData([], widget.estados, widget.zonas);
                    if (widget.press != null) {
                      widget.press!();
                    }
                  })),
          chips(
              icono: Icons.contact_emergency,
              cabeza: widget.estados.isEmpty
                  ? "Estado"
                  : widget.estados
                      .map((e) => provider.estados
                          .firstWhereOrNull((ti) => ti.id == int.tryParse(e))
                          ?.nombre)
                      .join(", "),
              fun: () => showDialog(
                  context: context,
                  builder: (context) => Dialog(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        Text("Seleccione estados para filtrar",
                            style: TextStyle(fontSize: 16.sp)),
                        Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Container(
                                constraints: BoxConstraints(maxHeight: 80.h),
                                child: FutureBuilder(
                                    future: EstadoController.getItems(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, index) {
                                              EstadoModel estado =
                                                  snapshot.data![index];
                                              return ListEstadoWidget(
                                                  estado: estado,
                                                  fun: () {},
                                                  share: false,
                                                  selectedVisible: true,
                                                  selected: widget.estados
                                                      .contains(
                                                          estado.id.toString()),
                                                  onSelected: (p0) {
                                                    var temp = widget.estados
                                                        .map(
                                                            (e) => int.parse(e))
                                                        .toList();
                                                    if (temp
                                                        .contains(estado.id)) {
                                                      temp.remove(estado.id);
                                                    } else {
                                                      temp.add(estado.id!);
                                                    }
                                                    log("${temp.map((e) => e.toString()).toList()}");
                                                    setState(() {
                                                      widget.updateData(
                                                          widget.tipos,
                                                          temp
                                                              .map((e) =>
                                                                  e.toString())
                                                              .toList(),
                                                          widget.zonas);
                                                      if (widget.press !=
                                                          null) {
                                                        widget.press!();
                                                      }
                                                    });

                                                    Navigation.pop();
                                                  },
                                                  dense: true);
                                            });
                                      } else if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}",
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                fontStyle: FontStyle.italic));
                                      } else {
                                        return Padding(
                                            padding: EdgeInsets.all(8.sp),
                                            child: CircularProgressIndicator());
                                      }
                                    })))
                      ]))),
              colorprincipal: ThemaMain.darkBlue,
              condicion: widget.estados.isNotEmpty,
              delete: () => setState(() {
                    widget.updateData(widget.tipos, [], widget.zonas);
                    if (widget.press != null) {
                      widget.press!();
                    }
                  })),
          chips(
              icono: LineIcons.mapMarked,
              cabeza: widget.zonas.isEmpty
                  ? "Zona"
                  : widget.zonas
                      .map((e) => provider.zonas
                          .firstWhereOrNull((ti) => ti.id == int.tryParse(e))
                          ?.nombre)
                      .join(", "),
              fun: () => showDialog(
                  context: context,
                  builder: (context) => DialogZonaView(
                      zonas: widget.zonas.isEmpty
                          ? []
                          : widget.zonas.map((e) => int.parse(e)).toList(),
                      fun: (p0) {
                        setState(() {
                          widget.updateData(widget.tipos, widget.estados,
                              p0.map((e) => e.id.toString()).toList());
                        });

                        Navigation.pop();
                      })),
              colorprincipal: ThemaMain.pink,
              condicion: widget.zonas.isNotEmpty,
              delete: () => setState(() {
                    widget.updateData(widget.tipos, widget.estados, []);
                    if (widget.press != null) {
                      widget.press!();
                    }
                  }))
        ]));
  }

  Widget chips(
      {required IconData icono,
      required String cabeza,
      required Function() fun,
      required Color colorprincipal,
      required bool condicion,
      required Function() delete}) {
    return GestureDetector(
        onTap: fun,
        child: Chip(
            avatar: Icon(icono,
                size: 17.sp,
                color: condicion ? colorprincipal : ThemaMain.darkGrey),
            padding: EdgeInsets.all(0),
            label: Text(cabeza,
                style: TextStyle(
                    fontSize: condicion ? 12.sp : 13.sp,
                    fontWeight:
                        condicion ? FontWeight.bold : FontWeight.normal)),
            onDeleted: delete,
            labelPadding: EdgeInsets.all(0),
            deleteIcon: condicion
                ? Icon(Icons.close, size: 18.sp, color: ThemaMain.red)
                : SizedBox()));
  }
}
