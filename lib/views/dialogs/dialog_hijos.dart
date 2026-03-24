import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:enrutador/controllers/usuario_fire.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';

import 'package:sizer/sizer.dart';

import '../../utilities/theme/theme_app.dart';
import '../widgets/extras/paginador_widget.dart';

class DialogHijos extends StatefulWidget {
  final UsuarioModel user;
  final List<int> hijos;
  final Function(List<int> hijos) onSave;
  const DialogHijos(
      {super.key,
      required this.hijos,
      required this.onSave,
      required this.user});

  @override
  State<DialogHijos> createState() => _DialogHijosState();
}

class _DialogHijosState extends State<DialogHijos> {
  List<UsuarioModel> hijosG = [];
  List<UsuarioModel> hijosSeleccionados = [];
  bool carga = true;
  SingleSelectController<UsuarioModel> controller =
      SingleSelectController(null);

  List<UsuarioModel> actuales = [];
  int index = 1;
  int max = 0;
  bool press = false;

  @override
  void initState() {
    super.initState();
    getHijos();
    send(index);
  }

  getHijos() async {
    if (!mounted) return;
    setState(() {
      carga = true;
    });
    for (var id in widget.hijos) {
      var user = await UsuarioFire.getItem(
          table: "id", query: id.toString(), itsNumber: true);
      if (user != null) {
        hijosG.add(user);
      }
    }
    if (!mounted) return;
    setState(() {
      carga = false;
    });
  }

  Future<void> send(int idx) async {
    if (!mounted) return;
    max = await UsuarioFire.countAll();
    setState(() {
      index = idx;
    });

    var list = await UsuarioFire.getAllItems(
        limit: 6, index: idx - 1, orden: "nombre", decender: false);

    if (!mounted) return;
    setState(() {
      actuales = list;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !press,
        child: Dialog(
            child: carga
                ? Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                        color: ThemaMain.primary, size: 30.sp))
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    Text("Selector de Hijos para ${widget.user.nombre}",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    Column(children: [
                      Text("Hijos asignados (Max. 6)",
                          style: TextStyle(fontSize: 16.sp)),
                      hijosG.isEmpty
                          ? Text("No tiene hijos asignados",
                              style: TextStyle(
                                  fontSize: 16.sp, fontStyle: FontStyle.italic))
                          : Wrap(
                              alignment: WrapAlignment.spaceAround,
                              spacing: .2.w,
                              children: hijosG
                                  .map((e) => childrenCard(
                                      e,
                                      40.w,
                                      () => setState(() {
                                            hijosG.remove(e);
                                          }),
                                      14.sp,
                                      ThemaMain.background,
                                      2))
                                  .toList()),
                      Divider(),
                      Text("Asignacion", style: TextStyle(fontSize: 16.sp)),
                      Card(
                          margin: EdgeInsets.all(12.sp),
                          child: SizedBox(
                              width: double.infinity,
                              child: hijosSeleccionados.isEmpty
                                  ? Text("Aun no se ha seleccionadon ninguno",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontStyle: FontStyle.italic))
                                  : Wrap(
                                      alignment: WrapAlignment.spaceAround,
                                      spacing: .1.w,
                                      children: hijosSeleccionados
                                          .map((e) => childrenCard(
                                              e,
                                              25.w,
                                              () => setState(() {
                                                    hijosSeleccionados
                                                        .remove(e);
                                                  }),
                                              13.sp,
                                              ThemaMain.background,
                                              0))
                                          .toList()))),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.w, vertical: .5.h),
                          child: Card(
                              color: ThemaMain.background,
                              elevation: 0,
                              child: Column(children: [
                                Wrap(
                                    alignment: WrapAlignment.spaceAround,
                                    spacing: .2.w,
                                    children: actuales
                                        .map((e) => childrenCard(e, 25.w, () {
                                              if (hijosG.firstWhereOrNull(
                                                          (element) =>
                                                              element.id ==
                                                              e.id) !=
                                                      null ||
                                                  hijosSeleccionados
                                                          .firstWhereOrNull(
                                                              (element) =>
                                                                  element.id ==
                                                                  e.id) !=
                                                      null) {
                                                debugPrint("remove");
                                                if (hijosG.firstWhereOrNull(
                                                        (element) =>
                                                            element.id ==
                                                            e.id) !=
                                                    null) {
                                                  showToast(
                                                      "Deseleccione desde la lista de hijos principal");
                                                  return;
                                                }
                                                setState(() {
                                                  hijosSeleccionados
                                                      .removeWhere((element) =>
                                                          element.id == e.id);
                                                });
                                              } else {
                                                debugPrint("add");
                                                if ((hijosSeleccionados.length +
                                                        hijosG.length) <
                                                    6) {
                                                  if (e.adminTipo == -1 ||
                                                      (e.adminTipo ?? 0) >
                                                          (widget.user
                                                                  .adminTipo ??
                                                              0)) {
                                                    showToast(
                                                        "No se puede agregar un administrador como hijo / No se puede agregar un usuario con mas permisos que el tuyo");
                                                    return;
                                                  }
                                                  if (e.id == widget.user.id) {
                                                    showToast(
                                                        "No puedes agregar al usuario como su propio hijo");
                                                    return;
                                                  }
                                                  setState(() {
                                                    hijosSeleccionados.add(e);
                                                  });
                                                } else {
                                                  showToast(
                                                      "Se ha alcanzado el numero maximo de hijos por usuario");
                                                }
                                              }
                                            },
                                                12.sp,
                                                hijosG.firstWhereOrNull(
                                                                (element) =>
                                                                    element
                                                                        .id ==
                                                                    e.id) !=
                                                            null ||
                                                        hijosSeleccionados
                                                                .firstWhereOrNull(
                                                                    (element) =>
                                                                        element
                                                                            .id ==
                                                                        e.id) !=
                                                            null
                                                    ? ThemaMain.green
                                                    : e.id == widget.user.id
                                                        ? ThemaMain.darkGrey
                                                        : null,
                                                2))
                                        .toList()),
                                PaginadorGroupedWidget(
                                    max: max,
                                    length: actuales.length,
                                    maxLenght: 6,
                                    send: (index) async => await send(index),
                                    itemScrollController: null)
                              ]))),
                      ElevatedButton.icon(
                          onPressed: () async {
                            if (!press) {
                              setState(() {
                                press = true;
                              });
                              var newChange = [
                                ...hijosSeleccionados,
                                ...hijosG
                              ];
                              await widget
                                  .onSave(newChange.map((e) => e.id).toList());
                              if (!mounted) return;
                              setState(() {
                                press = false;
                              });
                            } else {
                              showToast("Espere un momento por favor");
                            }
                          },
                          label: Text("Aplicar cambios",
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  color: press
                                      ? ThemaMain.darkGrey
                                      : ThemaMain.green)),
                          icon: Icon(Icons.save,
                              size: 20.sp,
                              color:
                                  press ? ThemaMain.darkGrey : ThemaMain.green))
                    ])
                  ])));
  }

  SizedBox childrenCard(UsuarioModel e, double width, Function() onTap,
      double fontSize, Color? card, double elevation) {
    return SizedBox(
        width: width,
        child: Tooltip(
            message: e.nombre ?? '',
            child: InkWell(
                onTap: () => onTap(),
                borderRadius: BorderRadius.circular(borderRadius),
                child: Card(
                    elevation: elevation,
                    color: card,
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: .5.w, vertical: .2.h),
                        child: Text(e.nombre!,
                            style: TextStyle(fontSize: fontSize),
                            overflow: TextOverflow.ellipsis))))));
  }
}
