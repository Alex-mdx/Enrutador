import 'package:enrutador/controllers/zonas_controller.dart';
import 'package:enrutador/models/zona_model.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import 'dialog_map_lite.dart';

class DialogsZonas extends StatefulWidget {
  final ZonasModel? item;
  const DialogsZonas({super.key, this.item});

  @override
  State<DialogsZonas> createState() => _DialogsZonasState();
}

class _DialogsZonasState extends State<DialogsZonas> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController notasController = TextEditingController();

  List<List<String>> latlongs = [];
  Color? colorsMain;
  int status = 0;

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      nombreController.text = widget.item!.nombre;
      notasController.text = widget.item!.notas ?? "";
      status = widget.item!.status;
      colorsMain = widget.item!.color;
      latlongs = widget.item!.latlongs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(
          title: Text(widget.item != null ? "Editar Zona" : "Crear Zona",
              style: TextStyle(fontSize: 16.sp))),
      Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(spacing: 1.h, children: [
            TextField(
                style: TextStyle(fontSize: 16.sp),
                textCapitalization: TextCapitalization.sentences,
                controller: nombreController,
                decoration: InputDecoration(label: Text("Nombre"))),
            TextField(
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                minLines: 1,
                maxLines: 4,
                style: TextStyle(fontSize: 16.sp),
                controller: notasController,
                decoration: InputDecoration(label: Text("Notas"))),
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
                                  onColorChange: (Color color) => setState(() {
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
                  icon: Icon(Icons.circle,
                      color: colorsMain ?? ThemaMain.primary))
            ]),
            Divider(),
            for (var item in latlongs)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    color: ThemaMain.background,
                    padding: EdgeInsets.all(2.sp),
                    width: 58.w,
                    height: 3.h,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            spacing: .1.w,
                            children: item
                                .map((e) => SizedBox(
                                    width: 16.w,
                                    child: Card(
                                        elevation: 0,
                                        color: ThemaMain.dialogbackground,
                                        child: Text(e,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: ThemaMain.darkGrey)))))
                                .toList()))),
                Row(mainAxisSize: MainAxisSize.min, spacing: 0, children: [
                  InkWell(
                      onTap: () async {
                        List<LatLng> lats = [];
                        try {
                          for (var e in item) {
                            var newE =
                                e.replaceAll("(", "").replaceAll(")", "");
                            lats.add(LatLng(double.parse(newE.split(",")[0]),
                                double.parse(newE.split(",")[1])));
                          }

                          await showDialog(
                              context: context,
                              builder: (context) => DialogMapLite(
                                  latlongPrev: lats,
                                  onPress: (value) {
                                    item.clear();
                                    setState(() {
                                      item.addAll(value!
                                          .map((e) =>
                                              "(${e.latitude}, ${e.longitude})")
                                          .toList());
                                    });
                                  }));
                        } catch (e) {
                          showToast("Error al procesar las coordenadas");
                        }
                      },
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.all(5.sp),
                              child: Text("Coord",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: ThemaMain.darkBlue,
                                      fontWeight: FontWeight.bold))))),
                  InkWell(
                      onTap: () => Dialogs.showMorph(
                          title: "Eliminar",
                          description:
                              "¿Desea eliminar este listado de coordenadas?",
                          loadingTitle: "Eliminando",
                          onAcceptPressed: (context) {
                            setState(() {
                              latlongs.remove(item);
                            });
                          }),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: .5.w, vertical: 0),
                              child: Text(" - ",
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      color: ThemaMain.red,
                                      fontWeight: FontWeight.bold)))))
                ])
              ]),
            ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    latlongs.add([]);
                  });
                },
                icon: Icon(Icons.layers, size: 20.sp),
                label: Text("Agregar", style: TextStyle(fontSize: 15.sp))),
            Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ElevatedButton.icon(
                  onPressed: () async {
                    var newZona = ZonasModel(
                        id: widget.item?.id,
                        nombre: nombreController.text,
                        notas: notasController.text,
                        status: 0,
                        color: colorsMain,
                        latlongs: latlongs);
                    await ZonasController.insert(newZona);
                    debugPrint("${newZona.toJson()}");
                    Navigation.pop();
                  },
                  icon: Icon(widget.item != null ? Icons.edit : Icons.save,
                      size: 20.sp,
                      color: widget.item != null
                          ? ThemaMain.primary
                          : ThemaMain.green),
                  label: Text(widget.item != null ? "Actualizar" : "Ingresar",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold))),
              if (widget.item != null)
                ElevatedButton.icon(
                    onPressed: () {
                      Dialogs.showMorph(
                          title: "Eliminar",
                          description: "¿Desea eliminar esta zona?",
                          loadingTitle: "Eliminando",
                          onAcceptPressed: (context) {
                            ZonasController.delete(widget.item!.id!);
                            Navigator.pop(context);
                          });
                    },
                    icon: Icon(Icons.delete, size: 20.sp, color: ThemaMain.red),
                    label: Text("Eliminar",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)))
            ])
          ]))
    ]));
  }
}
