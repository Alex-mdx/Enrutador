import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/controllers/fireController/cartera_fire.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/extras/card_contacto_download.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:enrutador/models/cartera_model.dart';
import 'package:line_icons/line_icons.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';
import 'package:badges/badges.dart' as bd;

import '../../utilities/camara_fun.dart';
import '../../utilities/main_provider.dart';
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
  Map<String, dynamic>? datas;

  bool chargeCartera = false;

  bool cargaContacto = false;

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
        datas = jsonDecode(content);

        /* if (datas.containsKey("cartera")) {
          final carteraData = datas["cartera"];
          final model =
              CarteraModel.fromJson(Map<String, dynamic>.from(carteraData));
          if (mounted) {
            setState(() {
              cartera = model;
            });
          }
        }*/
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
    final provider = Provider.of<MainProvider>(context);
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(
          title: Text("Cartera${kDebugMode ? "\n${cartera?.codigo}" : ""}"),
          actions: [
            if (cartera != null)
              OverflowBar(spacing: 0, children: [
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
                                      if (p0 == cartera?.codigo.toString()) {
                                        var temp = cartera?.copyWith(activo: 1);

                                        showToast(
                                            "Cartera escaneada exitosamente");
                                        setState(() {
                                          cartera = temp;
                                        });
                                        Navigation.pop();
                                      } else {
                                        showToast(
                                            "Codigo ingresado incorrecto");
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
                        if (result == cartera?.codigo.toString()) {
                          var temp = cartera?.copyWith(activo: 1);
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
            IconButton.filledTonal(
                iconSize: 20.sp,
                onPressed: () async {
                  try {
                    setState(() {
                      chargeCartera = true;
                    });
                    List<Filter> querys = [
                      Filter.and(
                          Filter("empleado_to",
                              isEqualTo: provider.usuario!.empleadoId!),
                          Filter("activo", isEqualTo: 0))
                    ];
                    var temp = (await CarteraFire.getItemPersonalizado(
                            filters: querys,
                            descending: true,
                            max: 1,
                            orderBy: "fecha_creado"))
                        .firstOrNull;
                    if (temp != null) {
                      setState(() {
                        cartera = temp;
                      });
                      showToast("Cartera actualizada exitosamente");
                    } else {
                      showToast("No se encontro ninguna cartera");
                    }
                    setState(() {
                      chargeCartera = false;
                    });
                  } catch (e) {
                    log(e.toString());
                    showToast("Error al obtener cartera");
                  } finally {
                    setState(() {
                      chargeCartera = false;
                    });
                  }
                },
                icon: chargeCartera
                    ? CircularProgressIndicator(
                        constraints:
                            BoxConstraints(maxHeight: 3.h, maxWidth: 3.h))
                    : Icon(Icons.refresh, color: ThemaMain.green))
          ]),
      Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(children: [
            IconButton.filledTonal(
                onLongPress: () {
                  Dialogs.showMorph(
                      title: "Eliminar",
                      description: "¿Estas seguro de eliminar la cartera?",
                      loadingTitle: "Eliminando",
                      onAcceptPressed: () async {
                        try {
                          final directory =
                              await getApplicationDocumentsDirectory();
                          final file = File('${directory.path}/cartera.json');

                          await file.delete();
                          var result = await file.exists();
                          if (result) {
                            showToast("Error al eliminar la cartera");
                          } else {
                            showToast("Cartera eliminada exitosamente");
                          }
                        } catch (e) {
                          log(e.toString());
                          showToast("Error al eliminar la cartera");
                        } finally {
                          Navigation.pop();
                        }
                      });
                },
                iconSize: 20.sp,
                onPressed: () async {
                  await _cargarCarteraArchivo();
                  if (datas == null) {
                    showToast(
                        "No se encontro algun archivo para extraer de la cartera");
                  } else {
                    showToast("Archivo de cartera local encontrada");
                  }
                },
                icon: cargandoArchivo
                    ? CircularProgressIndicator.adaptive()
                    : datas == null
                        ? Icon(LineIcons.folderOpenAlt,
                            color: ThemaMain.darkGrey)
                        : Icon(LineIcons.fileAlt, color: ThemaMain.green)),
            Divider(),
            cartera?.activo == null
                ? Text("No se encontro ninguna cartera",
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: ThemaMain.pink))
                : Padding(
                    padding: EdgeInsets.all(8.sp),
                    child: Column(children: [
                      bd.Badge(
                          onTap: () => showToast(
                              "Esta cartera esta bloqueada, ingrese su codigo para acceder a los contactos"),
                          badgeContent: RiveAnimatedIcon(
                              riveIcon: RiveIcon.shield,
                              enableAbsorbPointer: true,
                              height: 20.sp,
                              width: 20.sp,
                              strokeWidth: 16.sp,
                              color: ThemaMain.primary),
                          badgeAnimation: const bd.BadgeAnimation.slide(),
                          showBadge: cartera!.activo == 0 && datas != null,
                          child: AnimatedContainer(
                              duration: Durations.medium1,
                              curve: Curves.easeInOut,
                              width: double.infinity,
                              constraints: BoxConstraints(
                                  maxHeight: cartera!.activo == 0 ? 6.h : 30.h),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.sp),
                                  color: cartera!.activo == 0
                                      ? ThemaMain.darkGrey
                                      : ThemaMain.second),
                              child: cartera!.activo == 0
                                  ? Center(
                                      child: Text("Contactos bloqueados",
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: ThemaMain.second)))
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      itemCount: cartera!.contactos.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 5),
                                      itemBuilder: (context, index) {
                                        var item = cartera!.contactos[index];
                                        return CardContactoDownload(
                                            contact: item,
                                            contactoTemp: [],
                                            refreshContactos: (p0) {},
                                            index: index,
                                            cargaContact: cargaContacto,
                                            setCargaContact: (p0) =>
                                                setState(() {
                                                  cargaContacto = p0;
                                                }));
                                      }))),
                      Wrap(
                          runAlignment: WrapAlignment.spaceAround,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            Text(
                                "Creado: ${cartera!.empleadoBy == provider.usuario!.empleadoId ? "(Yo)" : cartera!.empleadoBy}",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: cartera!.empleadoBy ==
                                            provider.usuario!.empleadoId
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                    color: ThemaMain.darkGrey)),
                            Text(
                                "Asignado: ${cartera!.empleadoTo == provider.usuario!.empleadoId ? "(Tu)" : cartera!.empleadoTo}",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: cartera!.empleadoTo ==
                                            provider.usuario!.empleadoId
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                    color: ThemaMain.darkGrey)),
                            Text(
                                "Actualizado: ${Textos.fechaYMDHMS(fecha: cartera!.fechaActualizado)}",
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold))
                          ]),
                      ElevatedButton.icon(
                          icon: Icon(Icons.upgrade,
                              color: ThemaMain.green, size: 22.sp),
                          onPressed: () {},
                          label: Text("Actualizar",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)))
                    ]))
          ]))
    ]));
  }
}
