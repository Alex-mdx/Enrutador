import 'package:enrutador/controllers/roles_controller.dart';
import 'package:enrutador/models/roles_model.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';
import '../../utilities/services/dialog_services.dart';
import 'dialog_icon_picker.dart';

class DialogsRoles extends StatefulWidget {
  final RolesModel? rol;

  const DialogsRoles({super.key, required this.rol});

  @override
  State<DialogsRoles> createState() => _DialogsRolesState();
}

class _DialogsRolesState extends State<DialogsRoles> {
  TextEditingController nombre = TextEditingController();
  IconData? iconMain;
  Color? colorsMain;

  @override
  void initState() {
    super.initState();
    nombre.text = widget.rol?.nombre ?? "";
    iconMain = widget.rol?.icon;
    colorsMain = widget.rol?.color;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(widget.rol == null ? "Crear tipo" : "Actualizar tipo",
          style: TextStyle(fontSize: 16.sp)),
      if (widget.rol != null)
        IconButton.filled(
            onPressed: () => Dialogs.showMorph(
                title: "Eliminar tipo",
                description: "¿Esta seguro de eliminar este tipo?",
                loadingTitle: "Eliminando",
                onAcceptPressed: (context) async {
                  await RolesController.deleteItem(widget.rol!.id ?? -1);
                  Navigation.pop();
                }),
            icon: Icon(Icons.delete, color: ThemaMain.second),
            iconSize: 20.sp),
      Padding(
          padding: EdgeInsets.all(10.sp),
          child: Column(children: [
            TextFormField(
                controller: nombre,
                decoration: InputDecoration(
                    label: Text("Nombre",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 16.sp,
                            color: ThemaMain.darkGrey)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h))),
            Divider(),
            Wrap(runAlignment: WrapAlignment.center, children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text("Icono:", style: TextStyle(fontSize: 16.sp)),
                IconButton.filledTonal(
                    iconSize: 26.sp,
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => DialogIconPicker(
                            iconFun: (p0) => setState(() {
                                  iconMain = p0;
                                }))),
                    icon: Icon(iconMain ?? LineIcons.userTag,
                        color: ThemaMain.primary))
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text("Color:", style: TextStyle(fontSize: 16.sp)),
                IconButton(
                    iconSize: 26.sp,
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => Dialog(
                            child: Padding(
                                padding: EdgeInsets.all(10.sp),
                                child: MaterialColorPicker(
                                    onColorChange: (Color color) =>
                                        setState(() {
                                          colorsMain = color;
                                        }),
                                    selectedColor: colorsMain ?? Colors.red,
                                    colors: [
                                      Colors.red,
                                      Colors.deepOrange,
                                      Colors.yellow,
                                      Colors.lightGreenAccent,
                                      Colors.cyan,
                                      Colors.deepPurple,
                                      Colors.purpleAccent,
                                      Colors.indigo,
                                      Colors.brown
                                    ])))),
                    icon: Icon(Icons.circle, color: colorsMain ?? Colors.grey))
              ])
            ]),
            ElevatedButton.icon(
                icon: Icon(
                    widget.rol != null ? Icons.comment : Icons.add_comment,
                    size: 22.sp,
                    color: ThemaMain.green),
                onPressed: () async {
                  if (nombre.text.isNotEmpty || nombre.text != "") {
                    if (widget.rol != null) {
                      var newTipo = widget.rol!.copyWith(
                          nombre: nombre.text,
                          icon: iconMain,
                          color: colorsMain);
                      await RolesController.update(newTipo);
                      showToast("Rol actualizado");
                      Navigation.pop();
                    } else {
                      if (iconMain != null) {
                        RolesModel rol = RolesModel(
                            id: null,
                            nombre: nombre.text,
                            icon: iconMain,
                            color: colorsMain,
                            tipo: null);
                        await RolesController.insert(rol);

                        showToast("Rol creado");
                        Navigation.pop();
                      } else {
                        showToast("Seleccione un icono");
                      }
                    }
                  } else {
                    showToast("Ingrese un nombre");
                  }
                },
                label: Text(widget.rol != null ? "Actualizar" : "Crear",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)))
          ]))
    ]));
  }
}
