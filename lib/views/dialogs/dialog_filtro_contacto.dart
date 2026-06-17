import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';

class DialogFiltroContacto extends StatefulWidget {
  final Function() fun;
  final int tipo;
  final int agrupar;
  final bool ordenar;
  final bool vacios;
  final bool pendientes;
  final Function(
      int tipo, int agrupar, bool ordenar, bool vacios, bool pendientes) apply;
  const DialogFiltroContacto(
      {super.key,
      required this.fun,
      required this.tipo,
      required this.agrupar,
      required this.ordenar,
      required this.vacios,
      required this.pendientes,
      required this.apply});

  @override
  State<DialogFiltroContacto> createState() => _DialogFiltroContactoState();
}

class _DialogFiltroContactoState extends State<DialogFiltroContacto> {
  int tipos = 0;
  int agrupar = 0;
  bool ordenar = false;
  bool vacios = false;
  bool pendientes = false;
  @override
  void initState() {
    tipos = widget.tipo;
    agrupar = widget.agrupar;
    ordenar = widget.ordenar;
    vacios = widget.vacios;
    pendientes = widget.pendientes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Filtro de contacto",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
      Divider(),
      Text("Visualizar por ${kDebugMode ? "tiposFilt" : ""}",
          style: TextStyle(fontSize: 15.sp)),
      Wrap(spacing: 1.w, children: [
        ChoiceChip(
            selectedColor: ThemaMain.green,
            label: Text("Nombre",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            selected: tipos == 0,
            onSelected: (value) => setState(() {
                  tipos = 0;
                })),
        ChoiceChip(
            selectedColor: ThemaMain.green,
            label: Text("Tipo",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            selected: tipos == 1,
            onSelected: (value) => setState(() {
                  tipos = 1;
                })),
        ChoiceChip(
            selectedColor: ThemaMain.green,
            label: Text("Estado",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            selected: tipos == 2,
            onSelected: (value) => setState(() {
                  tipos = 2;
                }))
      ]),
      Divider(indent: 5.w, endIndent: 5.w),
      Text("Agrupar por ${kDebugMode ? "agruparFilt" : ""}",
          style: TextStyle(fontSize: 15.sp)),
      Wrap(alignment: WrapAlignment.center, spacing: 1.w, children: [
        ChoiceChip(
            selectedColor: ThemaMain.green,
            label: Text("Alfabeto",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            selected: agrupar == 0,
            onSelected: (value) => setState(() {
                  agrupar = 0;
                })),
        ChoiceChip(
            selectedColor: ThemaMain.green,
            label: Text("Fecha",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            selected: agrupar == 1,
            onSelected: (value) {
              setState(() {
                agrupar = 1;
              });
            })
      ]),
      Divider(indent: 5.w, endIndent: 5.w),
      Text("Ordenar agrupador", style: TextStyle(fontSize: 15.sp)),
      Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Ascendente",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            Switch.adaptive(
                thumbIcon: WidgetStatePropertyAll(Icon(
                    ordenar
                        ? LineIcons.sortAlphabeticalUp
                        : LineIcons.sortAlphabeticalDown,
                    color: ThemaMain.dialogbackground)),
                value: !ordenar,
                onChanged: (value) => setState(() {
                      ordenar = !value;
                    })),
            Text("Descendente",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold))
          ]),
      Divider(indent: 5.w, endIndent: 5.w),
      Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 5,
                child: Text(
                    "No mostrar vacios. Solo contactos con nombre, tipo y estado ingresados",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.bold))),
            Expanded(
                flex: 1,
                child: Checkbox(
                    activeColor: ThemaMain.green,
                    value: vacios,
                    onChanged: (value) => setState(() {
                          if (value != null) {
                            vacios = !vacios;
                          }
                        })))
          ]),
      Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Mostrar solo pendientes",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            Checkbox(
                checkColor: ThemaMain.purple,
                activeColor: ThemaMain.green,
                value: pendientes,
                onChanged: (value) => setState(() {
                      if (value != null) {
                        pendientes = !pendientes;
                      }
                    }))
          ]),
      ElevatedButton.icon(
          icon: Icon(LineIcons.checkCircle, size: 20.sp),
          onPressed: () {
            widget.apply(tipos, agrupar, ordenar, vacios, pendientes);
            widget.fun();
            Navigation.pop();
          },
          label: Text("Aplicar Cambios", style: TextStyle(fontSize: 15.sp)))
    ]));
  }
}
