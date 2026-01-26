import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/enrutar_controller.dart';
import 'package:enrutador/models/enrutar_model.dart';
import 'package:enrutador/utilities/funcion_parser.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/textos.dart';
import '../../utilities/theme/theme_app.dart';

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
              var data = await EnrutarController.getItems();
              for (var element in data) {
                if (element.visitado == 1) {
                  var newItem = await ContactoController.getItemId(
                      id: element.contactoId);
                  if (newItem != null) {
                    var newModel = newItem.copyWith(agendar: null);
                    await ContactoController.update(newModel);
                  }
                }
              }
              await EnrutarController.deleteAll();
              showToast("Datos de enrutamiento limpiado");
              Navigation.pop();
            },
            child: Text("Limpiar", style: TextStyle(fontSize: 14.sp)))
      ]),
      Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: ThemaMain.second),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text("Agrupar por visitado",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            Checkbox.adaptive(
                activeColor: ThemaMain.yellow,
                value: Preferences.visitados,
                onChanged: (value) => setState(() {
                      Preferences.visitados = !Preferences.visitados;
                    }))
          ])),
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
          ? Column(children: [
              FutureBuilder(
                  future: !Preferences.visitados
                      ? EnrutarController.getItems()
                      : EnrutarController.getVisitado(visitado: false),
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
                                  constraints: BoxConstraints(maxHeight: 32.h),
                                  child: ListView.builder(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 1.w, vertical: 1.h),
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        EnrutarModelo enrutar =
                                            snapshot.data![index];
                                        var distancia =
                                            MapFun.calcularDistancia(
                                                lat1:
                                                    provider.local?.latitude ??
                                                        0,
                                                lon1:
                                                    provider.local?.longitude ??
                                                        0,
                                                lat2: enrutar.buscar.latitud,
                                                lon2: enrutar.buscar.longitud);
                                        return listEnrutar(provider, enrutar,
                                            distancia, index, snapshot);
                                      })));
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}",
                          style: TextStyle(fontSize: 15.sp));
                    } else {
                      return Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: LoadingAnimationWidget.fourRotatingDots(
                              color: ThemaMain.green, size: 20.sp));
                    }
                  }),
              if (Preferences.visitados)
                Divider(
                    height: .5.h,
                    indent: 3.w,
                    endIndent: 3.w,
                    color: ThemaMain.darkGrey),
              if (Preferences.visitados)
                FutureBuilder(
                    future: EnrutarController.getVisitado(visitado: true),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!.isEmpty
                            ? Center(
                                child: Text("Enrutamiento visitado",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontStyle: FontStyle.italic)))
                            : Scrollbar(
                                child: Container(
                                    constraints:
                                        BoxConstraints(maxHeight: 32.h),
                                    child: ListView.builder(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 1.w, vertical: 1.h),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          EnrutarModelo enrutar =
                                              snapshot.data![index];
                                          var distancia =
                                              MapFun.calcularDistancia(
                                                  lat1: provider
                                                          .local?.latitude ??
                                                      0,
                                                  lon1: provider
                                                          .local?.longitude ??
                                                      0,
                                                  lat2: enrutar.buscar.latitud,
                                                  lon2:
                                                      enrutar.buscar.longitud);
                                          return listEnrutar(provider, enrutar,
                                              distancia, index, snapshot);
                                        })));
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}",
                            style: TextStyle(fontSize: 15.sp));
                      } else {
                        return Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: LoadingAnimationWidget.fourRotatingDots(
                                color: ThemaMain.green, size: 20.sp));
                      }
                    })
            ])
          : Column(children: [
              Text("Ordenando...",
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              LoadingAnimationWidget.fourRotatingDots(
                  color: ThemaMain.green, size: 20.sp)
            ]),
      FutureBuilder(
          future: EnrutarController.getItems(),
          builder: (context, snapshot) {
            return Stack(alignment: Alignment.center, children: [
              LinearProgressIndicator(
                  value: snapshot.hasData
                      ? (snapshot.data
                                  ?.where((element) => element.visitado == 1)
                                  .length ??
                              1) /
                          (snapshot.data?.length ?? 1)
                      : 0,
                  minHeight: 3.h,
                  backgroundColor: ThemaMain.background,
                  color: ThemaMain.green),
              Text(
                  "${snapshot.data?.where((element) => element.visitado == 1).length ?? 1} / ${snapshot.data?.length ?? 1}",
                  style: TextStyle(fontSize: 14.sp))
            ]);
          })
    ]));
  }

  Column listEnrutar(
      MainProvider provider,
      EnrutarModelo enrutar,
      double distancia,
      int index,
      AsyncSnapshot<List<EnrutarModelo>> snapshot) {
    return Column(children: [
      ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                var visitado = Parser.toInt(!(enrutar.visitado == 1));
                var tempdata = enrutar.copyWith(visitado: visitado);
                await EnrutarController.update(tempdata);
                await name();
              }),
          title: Text(enrutar.buscar.nombreCompleto ?? "Sin nombre ingresado",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
          subtitle: Column(children: [
            Text(
                "Distancia: ${distancia > 100 ? "${Textos.moneda(moneda: distancia / 100)} KM" : "${Textos.moneda(moneda: distancia, digito: 0).replaceAll(".", "")} M"}~",
                style: TextStyle(fontSize: 15.sp)),
            Text(
                enrutar.buscar.agendar == null
                    ? "Sin visita agendada"
                    : "Visita: ${Textos.conversionDiaNombre(enrutar.buscar.agendar!, DateTime.now())}",
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: enrutar.buscar.agendar == null
                        ? FontWeight.normal
                        : FontWeight.bold))
          ]),
          trailing: IconButton(
              iconSize: 20.sp,
              onPressed: () async {
                if (enrutar.visitado == 1) {
                  var newItem = await ContactoController.getItemId(
                      id: enrutar.contactoId);
                  if (newItem != null) {
                    var newModel = newItem.copyWith(agendar: null);
                    await ContactoController.update(newModel);
                  }
                }

                await EnrutarController.deleteItem(enrutar.id!);
                var tama = (await EnrutarController.getItems()).length;
                if (tama == 0) {
                  Navigation.pop();
                }
                await name();
              },
              icon: Icon(Icons.delete, color: ThemaMain.red))),
      if (index < snapshot.data!.length - 1)
        Divider(height: 0, indent: 9.w, endIndent: 9.w)
    ]);
  }
}
