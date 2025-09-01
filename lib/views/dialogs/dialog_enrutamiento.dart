import 'package:enrutador/controllers/enrutar_controller.dart';
import 'package:enrutador/models/enrutar_model.dart';
import 'package:enrutador/utilities/funcion_parser.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/textos.dart';

class DialogEnrutamiento extends StatefulWidget {
  const DialogEnrutamiento({super.key});

  @override
  State<DialogEnrutamiento> createState() => _DialogEnrutamientoState();
}

class _DialogEnrutamientoState extends State<DialogEnrutamiento> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Enrutamiento", style: TextStyle(fontSize: 18.sp)),
        TextButton(
            onPressed: () async {
              await EnrutarController.deleteAll();
              showToast("Datos de enrutamiento limpiado");
              Navigation.pop();
            },
            child: Text("Limpiar", style: TextStyle(fontSize: 15.sp)))
      ]),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Row(children: [
            Expanded(
                flex: 1,
                child: Text("Visitado",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.bold))),
            Expanded(
                flex: 3,
                child: Text("Contacto",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.bold))),
            Expanded(
                flex: 1,
                child: Text("eliminar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.bold)))
          ])),
      FutureBuilder(
          future: EnrutarController.getItems(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Scrollbar(
                  child: Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            EnrutarModelo enrutar = snapshot.data![index];
                            return ListTile(
                                onTap: () async {
                                  Navigation.pop();
                                  await MapFun.sendInitUri(
                                      provider: provider,
                                      lat: enrutar.buscar.latitud,
                                      lng: enrutar.buscar.longitud);
                                },
                                leading: Checkbox(
                                    semanticLabel: "Visitado",
                                    activeColor: ThemaMain.green,
                                    value: enrutar.visitado == 1,
                                    onChanged: (value) async {
                                      var visitado = Parser.toInt(
                                          !(enrutar.visitado == 1));
                                      var tempdata =
                                          enrutar.copyWith(visitado: visitado);
                                      await EnrutarController.update(tempdata);
                                      setState(() {});
                                    }),
                                title: Text(
                                    enrutar.buscar.nombreCompleto ??
                                        "Sin nombre ingresado",
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    enrutar.buscar.agendar == null
                                        ? "Sin visita agendada"
                                        : "Visita: ${Textos.conversionDiaNombre(enrutar.buscar.agendar!, DateTime.now())}",
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight:
                                            enrutar.buscar.agendar == null
                                                ? FontWeight.normal
                                                : FontWeight.bold)),
                                trailing: IconButton(
                                    iconSize: 20.sp,
                                    onPressed: () async {
                                      await EnrutarController.deleteItem(
                                          enrutar.id!);
                                      var tama =
                                          (await EnrutarController.getItems())
                                              .length;
                                      if (tama == 0) {
                                        Navigation.pop();
                                      }
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.delete,
                                        color: ThemaMain.red)));
                          })));
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}",
                  style: TextStyle(fontSize: 15.sp));
            } else {
              return Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: CircularProgressIndicator());
            }
          })
    ]));
  }
}
