import 'package:enrutador/controllers/fireController/usuario_fire.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/views/widgets/extras/card_children.dart';
import 'package:enrutador/views/widgets/extras/paginador_widget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_color.dart';

class CardUserSelect extends StatefulWidget {
  final Function(UsuarioModel) onTap;
  final String? empleadoSelected;
  const CardUserSelect(
      {super.key, required this.onTap, required this.empleadoSelected});

  @override
  State<CardUserSelect> createState() => _CardUserSelectState();
}

class _CardUserSelectState extends State<CardUserSelect> {
  bool search = true;
  List<UsuarioModel> actuales = [];
  int index = 1;
  int max = 0;
  final int maxLenght = 6;
  bool press = false;
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
  void initState() {
    send(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return AnimatedContainer(
        duration: Durations.short4,
        height: search
            ? 13.h
            : actuales.isEmpty
                ? 12.h
                : 15.h,
        width: double.infinity,
        child: Card(
            elevation: 0,
            color: ThemaMain.background,
            child: Column(children: [
              Text("Seleccionar usuario", style: TextStyle(fontSize: 15.sp)),
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
                                            provider.usuario?.empleadoId) {
                                          showToast(
                                              "No puedes tomar tu propio contacto");
                                          return;
                                        }
                                        widget.onTap(e);
                                      }),
                                  fontSize: 12.sp,
                                  card: widget.empleadoSelected == e.empleadoId
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
            ])));
  }
}
