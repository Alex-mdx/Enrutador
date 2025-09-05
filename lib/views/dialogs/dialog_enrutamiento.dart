import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/enrutar_controller.dart';
import 'package:enrutador/models/enrutar_model.dart';
import 'package:enrutador/utilities/funcion_parser.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/textos.dart';

class DialogEnrutamiento extends StatefulWidget {
  final MainProvider provider;
  const DialogEnrutamiento({super.key, required this.provider});

  @override
  State<DialogEnrutamiento> createState() => _DialogEnrutamientoState();
}

class _DialogEnrutamientoState extends State<DialogEnrutamiento> {
  bool carga = false;
  DateTime ahora = DateTime.now();
  @override
  void initState() {
    super.initState();
    name();
  }

  Future<void> name() async {
    await MapFun.ordenamiento(widget.provider);
    setState(() {
      carga = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            child: Text("Limpiar", style: TextStyle(fontSize: 14.sp)))
      ]),
      ElevatedButton.icon(
          icon: Icon(LineIcons.route, color: ThemaMain.green, size: 24.sp),
          onPressed: () async => showDialog(
              context: context,
              builder: (context) => Dialog(
                  child: CalendarDatePicker(
                      initialCalendarMode: DatePickerMode.day,
                      firstDate:
                          DateTime.now().subtract(Duration(days: 5 * 365)),
                      lastDate: DateTime.now().add(Duration(days: 5 * 365)),
                      currentDate: DateTime.now(),
                      initialDate: ahora,
                      onDateChanged: (value) => Dialogs.showMorph(
                          title: "Enrutar fecha",
                          description:
                              "Obtener los contactos del dia de ${Textos.conversionDiaNombre(ahora, DateTime.now())} para enrutar",
                          loadingTitle: "Obteniendo...",
                          onAcceptPressed: (context) async {
                            setState(() {
                              ahora = value;
                            });
                            var datas =
                                await ContactoController.getItembyAgenda(
                                    now: value);
                            for (var contacto in datas) {
                              var data =
                                  await EnrutarController.getItemContacto(
                                      contactoId: contacto.id!);

                              if (data != null) {
                                var newEnrutar =
                                    data.copyWith(buscar: contacto);
                                await EnrutarController.update(newEnrutar);
                              } else {
                                EnrutarModelo data = EnrutarModelo(
                                    visitado: 0,
                                    orden: 0,
                                    contactoId: contacto.id!,
                                    buscar: contacto);
                                await EnrutarController.insert(data);
                              }
                              await name();
                            }
                            debugPrint("${datas.length}");
                          })))),
          label: Text(
              "Obtener de Agenda: ${Textos.conversionDiaNombre(ahora, DateTime.now())}",
              style: TextStyle(fontSize: 15.sp))),
      Divider(height: .5.h),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
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
                child: Text("Borrar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.bold)))
          ])),
      carga
          ? FutureBuilder(
              future: EnrutarController.getItems(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.isEmpty
                      ? Center(
                          child: Text("Enrutamiento vacio",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontStyle: FontStyle.italic)))
                      : Scrollbar(
                          child: Container(
                              constraints: BoxConstraints(maxHeight: 70.h),
                              child: ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 1.w, vertical: 1.h),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data?.length,
                                  itemBuilder: (context, index) {
                                    EnrutarModelo enrutar =
                                        snapshot.data![index];
                                    var distancia = MapFun.calcularDistancia(
                                        lat1: provider.local?.latitude ?? 0,
                                        lon1: provider.local?.longitude ?? 0,
                                        lat2: enrutar.buscar.latitud,
                                        lon2: enrutar.buscar.longitud);
                                    return Column(children: [
                                      ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 0),
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
                                                var tempdata = enrutar.copyWith(
                                                    visitado: visitado);
                                                await EnrutarController.update(
                                                    tempdata);
                                                setState(() {});
                                              }),
                                          title: Text(
                                              enrutar.buscar.nombreCompleto ??
                                                  "Sin nombre ingresado",
                                              style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Column(children: [
                                            Text(
                                                "Distancia: ${distancia > 1 ? "${Textos.moneda(moneda: distancia)} KM" : "${Textos.moneda(moneda: distancia * 1000, digito: 0)} M"}~",
                                                style:
                                                    TextStyle(fontSize: 15.sp)),
                                            Text(
                                                enrutar.buscar.agendar == null
                                                    ? "Sin visita agendada"
                                                    : "Visita: ${Textos.conversionDiaNombre(enrutar.buscar.agendar!, DateTime.now())}",
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: enrutar.buscar
                                                                .agendar ==
                                                            null
                                                        ? FontWeight.normal
                                                        : FontWeight.bold))
                                          ]),
                                          trailing: IconButton(
                                              iconSize: 20.sp,
                                              onPressed: () async {
                                                await EnrutarController
                                                    .deleteItem(enrutar.id!);
                                                var tama =
                                                    (await EnrutarController
                                                            .getItems())
                                                        .length;
                                                if (tama == 0) {
                                                  Navigation.pop();
                                                }
                                                setState(() {});
                                              },
                                              icon: Icon(Icons.delete,
                                                  color: ThemaMain.red))),
                                      Divider(
                                          height: 0,
                                          indent: 7.w,
                                          endIndent: 7.w)
                                    ]);
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
          : Column(children: [
              Text("Ordenando...",
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              CircularProgressIndicator(),
            ]),
      Text("Maximo 15 contactos enrutados", style: TextStyle(fontSize: 14.sp))
    ]));
  }
}
