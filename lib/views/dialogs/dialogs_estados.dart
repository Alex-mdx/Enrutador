
import 'package:enrutador/controllers/estado_controller.dart';
import 'package:enrutador/models/estado_model.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/theme/theme_color.dart';

class DialogsTipos extends StatefulWidget {
  final EstadoModel? estado;
  
  const DialogsTipos({super.key, required this.estado});

  @override
  State<DialogsTipos> createState() => _DialogsTiposState();
}

class _DialogsTiposState extends State<DialogsTipos> {
  TextEditingController nombre = TextEditingController();
  TextEditingController descricion = TextEditingController();
  int? orden;
  Color? colorsMain;

  @override
  void initState() {
    super.initState();
    nombre.text = widget.estado?.nombre ?? "";
    descricion.text = widget.estado?.descripcion ?? "";
    orden = widget.estado?.orden;
    colorsMain = widget.estado?.color;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(widget.estado == null ? "Crear tipo" : "Actualizar tipo",
          style: TextStyle(fontSize: 16.sp)),
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
            TextFormField(
                controller: descricion,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    label: Text("Descripcion",
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
                Text("Orden:", style: TextStyle(fontSize: 16.sp)),
                
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
                                      Colors.green,
                                      Colors.cyan,
                                      
                                      Colors.deepPurple,
                                      Colors.purpleAccent,Colors.indigo,
                                      Colors.brown
                                    ])))),
                    icon: Icon(Icons.circle, color: colorsMain ?? Colors.grey))
              ])
            ]),
            ElevatedButton.icon(
                icon: Icon(
                    widget.estado != null ? Icons.comment : Icons.add_comment,
                    size: 22.sp,
                    color: ThemaMain.green),
                onPressed: () async {
                  if (nombre.text.isNotEmpty || nombre.text != "") {
                    if (widget.estado != null) {
                      var newTipo = widget.estado!.copyWith(
                          nombre: nombre.text,
                          descripcion: descricion.text,
                          orden: orden ?? 1,
                          color: colorsMain);
                      await EstadoController.update(newTipo);
                      showToast("Estado actualizado");
                      Navigation.pop();
                    }
                  } else {
                    showToast("Ingrese un nombre");
                  }
                },
                label: Text(widget.estado != null ? "Actualizar" : "Crear",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)))
          ]))
    ]));
  }
}
