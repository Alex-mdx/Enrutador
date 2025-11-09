import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';

class DialogFiltroContacto extends StatefulWidget {
  const DialogFiltroContacto({super.key});

  @override
  State<DialogFiltroContacto> createState() => _DialogFiltroContactoState();
}

class _DialogFiltroContactoState extends State<DialogFiltroContacto> {
  int tipos = 0;
  int agrupar = 0;
  bool ordenar = false;
  @override
  void initState() {
    tipos = Preferences.tiposFilt;
    agrupar = Preferences.agruparFilt;
    ordenar = Preferences.ordenFilt;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Filtro de contacto",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
      Divider(),
      Text("Visualizar por", style: TextStyle(fontSize: 15.sp)),
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
      Text("Agrupar por", style: TextStyle(fontSize: 15.sp)),
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
            onSelected: (value) => setState(() {
                  agrupar = 1;
                })),
        Divider(indent: 5.w, endIndent: 5.w),
      ]),
      Text("Ordenar", style: TextStyle(fontSize: 15.sp)),
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
      ElevatedButton.icon(
          icon: Icon(LineIcons.checkCircle, size: 20.sp),
          onPressed: () {},
          label: Text("Aplicar Cambios", style: TextStyle(fontSize: 15.sp)))
    ]));
  }
}
