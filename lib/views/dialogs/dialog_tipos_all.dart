import 'package:enrutador/controllers/tipo_controller.dart';
import 'package:enrutador/models/tipos_model.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/list_tipo_widget.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/textos.dart';

class DialogTiposAll extends StatelessWidget {
  final Function(TiposModelo) selected;
  final DateTime? fecha;
  const DialogTiposAll(
      {super.key, required this.selected, required this.fecha});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Seleccione el tipo", style: TextStyle(fontSize: 16.sp)),
      ElevatedButton.icon(
          style: ButtonStyle(
              padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 0, horizontal: 2.w))),
          icon: Icon(Icons.cleaning_services_rounded,
              size: 18.sp, color: ThemaMain.darkBlue),
          onPressed: () {
            selected(TiposModelo(
                id: -1, nombre: "", descripcion: "", icon: null, color: null));
            Navigation.pop();
          },
          label: Text("Limpiar Tipo",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold))),
      if (fecha != null)
        Text("Ultima modificacion: ${Textos.fechaYMDHMS(fecha: fecha!)}",
            style: TextStyle(fontSize: 15.sp, fontStyle: FontStyle.italic)),
      Container(
          constraints: BoxConstraints(maxHeight: 80.h),
          child: FutureBuilder(
              future: TipoController.getItems(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.isEmpty
                      ? Center(
                          child: Text("No se ha ingresado ningun tipo",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            TiposModelo tipo = snapshot.data![index];
                            return ListTipoWidget(
                                share: false,
                                tipo: tipo,
                                selected: false,
                                selectedVisible: false,
                                onSelected: (p0) {},
                                fun: () {
                                  selected(tipo);
                                  Navigation.pop();
                                });
                          });
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}",
                          style: TextStyle(fontSize: 14.sp)));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }))
    ]));
  }
}
