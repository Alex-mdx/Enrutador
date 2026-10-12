import 'dart:convert';
import 'dart:io';

import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:enrutador/models/cartera_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/camara_fun.dart';
import '../widgets/extras/pin_widget.dart';

class DialogCarteraView extends StatefulWidget {
  final CarteraModel? cartera;
  const DialogCarteraView({super.key, required this.cartera});

  @override
  State<DialogCarteraView> createState() => _DialogCarteraViewState();
}

class _DialogCarteraViewState extends State<DialogCarteraView> {
  CarteraModel? cartera;
  bool cargandoArchivo = false;

  @override
  void initState() {
    super.initState();
    cartera = widget.cartera;
    if (cartera == null) {
      _cargarCarteraArchivo();
    }
  }

  Future<void> _cargarCarteraArchivo() async {
    setState(() {
      cargandoArchivo = true;
    });
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/cartera.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> datas = jsonDecode(content);

        if (datas.containsKey("cartera")) {
          final carteraData = datas["cartera"];
          final model =
              CarteraModel.fromJson(Map<String, dynamic>.from(carteraData));
          if (mounted) {
            setState(() {
              cartera = model;
            });
          }
        }
      } else {
        showToast("No se encontró archivo de cartera");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error al cargar cartera.json: $e");
      }
      showToast("Error al leer el archivo de cartera");
    } finally {
      if (mounted) {
        setState(() {
          cargandoArchivo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargandoArchivo) {
      return const Dialog(
          child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Buscando cartera..."),
              ])));
    }

    if (cartera == null) {
      return Dialog(
          child: Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  "No hay cartera disponible",
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: ThemaMain.pink),
                ),
                SizedBox(height: 12.sp),
                FilledButton.tonal(
                  onPressed: _cargarCarteraArchivo,
                  child: const Text("Reintentar"),
                )
              ])));
    }

    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(
          title: Text("Cartera ${kDebugMode ? "${cartera!.codigo}" : ""}"),
          actions: [
            IconButton.filled(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => Dialog(
                        child: SizedBox(
                            height: 14.h,
                            child: PinWidget(
                                pin: cartera!.codigo.toString(),
                                lenght: 5,
                                onCompleted: (p0) {
                                  if (p0 == cartera!.codigo.toString()) {
                                    var temp = cartera!.copyWith(activo: 1);

                                    showToast("Cartera escaneada exitosamente");
                                    setState(() {
                                      cartera = temp;
                                    });
                                    Navigation.pop();
                                  } else {
                                    showToast("Codigo ingresado incorrecto");
                                  }
                                },
                                error: true)))),
                iconSize: 18.sp,
                icon: Icon(Icons.pin, color: ThemaMain.second)),
            IconButton.filledTonal(
                iconSize: 18.sp,
                onPressed: () async {
                  String? result = await CamaraFun.scanQr();
                  if (result != null) {
                    if (result == cartera!.codigo.toString()) {
                      var temp = cartera!.copyWith(activo: 1);
                      showToast("Cartera escaneada exitosamente");
                      setState(() {
                        cartera = temp;
                      });
                      Navigation.pop();
                    } else {
                      showToast("Codigo ingresado incorrecto");
                    }
                  }
                },
                icon: Icon(Icons.photo_camera_rounded))
          ]),
      Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(children: [
            cartera!.activo == 0
                ? Text("Cartera bloqueada",
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: ThemaMain.pink))
                : Placeholder()
          ]))
    ]));
  }
}
