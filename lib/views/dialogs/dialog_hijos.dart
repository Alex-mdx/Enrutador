import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:enrutador/controllers/usuario_fire.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:sizer/sizer.dart';

import '../widgets/extras/paginador_widget.dart';

class DialogHijos extends StatefulWidget {
  final List<int> hijos;
  const DialogHijos({super.key, required this.hijos});

  @override
  State<DialogHijos> createState() => _DialogHijosState();
}

class _DialogHijosState extends State<DialogHijos> {
  List<UsuarioModel> hijosG = [];
  bool carga = true;
  SingleSelectController<UsuarioModel> controller =
      SingleSelectController(null);

  List<UsuarioModel> actuales = [];
  int index = 1;
  int max = 0;

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
        limit: 4, index: idx - 1, orden: "nombre", decender: false);

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
    return Dialog(
        child: carga
            ? Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                    color: ThemaMain.primary, size: 30.sp))
            : Column(mainAxisSize: MainAxisSize.min, children: [
                Text("Hijos",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Column(children: [
                  Text("Hijos asignados", style: TextStyle(fontSize: 16.sp)),
                  hijosG.isEmpty
                      ? Text("No tiene hijos asignados",
                          style: TextStyle(
                              fontSize: 16.sp, fontStyle: FontStyle.italic))
                      : Wrap(
                          children: hijosG
                              .map((e) => SizedBox(
                                  width: 20.w,
                                  child: Tooltip(
                                      message: e.nombre ?? '',
                                      child: Card(
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 2),
                                              child: Text(
                                                "  ${e.nombre!}  ",
                                                style:
                                                    TextStyle(fontSize: 14.sp),
                                                overflow: TextOverflow.ellipsis,
                                              ))))))
                              .toList()),
                  Divider(),
                  Text("Asignacion", style: TextStyle(fontSize: 16.sp)),
                  Card(
                      margin: EdgeInsets.all(12.sp),
                      child: hijosG.isEmpty
                          ? Text("Aun no se ha seleccionadon ninguno",
                              style: TextStyle(
                                  fontSize: 16.sp, fontStyle: FontStyle.italic))
                          : Wrap(
                              children: hijosG
                                  .map((e) => SizedBox(
                                      width: 20.w,
                                      child: Tooltip(
                                          message: e.nombre ?? '',
                                          child: Card(
                                              child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2),
                                                  child: Text(
                                                    "  ${e.nombre!}  ",
                                                    style: TextStyle(
                                                        fontSize: 14.sp),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ))))))
                                  .toList())),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: .5.h),
                      child: Card(
                          color: ThemaMain.background,
                          elevation: 0,
                          child: Column(children: [
                            Wrap(
                                spacing: .2.w,
                                children: actuales
                                    .map((e) => SizedBox(
                                        width: 19.w,
                                        child: Tooltip(
                                            message: e.nombre ?? '',
                                            child: Card(
                                                child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4,
                                                            vertical: 2),
                                                    child: Text(
                                                      "  ${e.nombre!}  ",
                                                      style: TextStyle(
                                                          fontSize: 13.sp),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))))))
                                    .toList()),
                            PaginadorGroupedWidget(
                                max: max,
                                length: actuales.length,
                                maxLenght: 4,
                                send: (index) async => await send(index),
                                itemScrollController: null)
                          ])))
                ])
              ]));
  }
}
