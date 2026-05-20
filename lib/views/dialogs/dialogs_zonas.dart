import 'package:enrutador/models/zona_model.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/dialogs/dialog_ubicacion.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      nombreController.text = widget.item!.nombre;
      notasController.text = widget.item!.notas ?? "";
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
            Divider(),
            for (var item in latlongs)
              Stack(alignment: Alignment.centerRight, children: [
                Container(
                    color: ThemaMain.background,
                    padding: EdgeInsets.all(2.sp),
                    width: double.infinity,
                    height: 3.h,
                    child: Row(
                        spacing: 1.w,
                        children:
                            item.map((e) => Card(child: Text(e))).toList())),
                Row(mainAxisSize: MainAxisSize.min, spacing: 0, children: [
                  InkWell(
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => DialogUbicacion(
                              funLat: (p0) {
                                debugPrint(
                                    "P0: ${p0?.latitude} , ${p0?.longitude}");
                              },
                              showText: false)),
                      child: Card(
                          child: Text("Coords",
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold)))),
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
                          child: Text(" - ",
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold))))
                ])
              ]),
            ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    latlongs.add([]);
                  });
                },
                icon: Icon(Icons.layers, size: 20.sp),
                label: Text("Agregar", style: TextStyle(fontSize: 15.sp)))
          ]))
    ]));
  }
}
