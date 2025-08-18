import 'package:enrutador/controllers/tipo_controller.dart';
import 'package:enrutador/models/tipos_model.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/views/widgets/list_tipo_widget.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DialogTiposAll extends StatelessWidget {
  final Function(TiposModelo) selected;
  const DialogTiposAll({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Seleccione el tipo", style: TextStyle(fontSize: 16.sp)),
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
