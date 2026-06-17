import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/fireController/contacto_fire.dart';
import 'package:enrutador/controllers/fireController/referencia_fire.dart';
import 'package:enrutador/controllers/referencias_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/trans_fun.dart';
import 'package:enrutador/views/widgets/sliding_cards/slide_general.dart';
import 'package:enrutador/views/widgets/sliding_cards/tarjeta_contacto_detalle.dart';
import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../models/contacto_model.dart';
import '../../models/referencia_model.dart';
import '../../utilities/theme/theme_color.dart';
import '../widgets/card_contacto_widget.dart';
import '../widgets/search/row_filtro.dart';

class DialogDownload extends StatefulWidget {
  const DialogDownload({super.key});

  @override
  State<DialogDownload> createState() => _DialogDownloadState();
}

class _DialogDownloadState extends State<DialogDownload> {
  TextEditingController buscador = TextEditingController();
  List<ContactoModelo> selects = [];
  List<ReferenciaModelo> referencias = [];
  double progress = 0;
  List<String> tipos = [];
  List<String> estados = [];
  List<String> zonas = [];

  bool carga = false;
  bool c = false;

  int maxValue = 50;
  int currentValue = 50;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(
          title:
              Text("Descarga de\ncontactos", style: TextStyle(fontSize: 16.sp)),
          actions: [
            Padding(
                padding: EdgeInsets.all(8.sp),
                child: SizedBox(
                    width: 22.w,
                    child: InputQty.int(
                        maxVal: maxValue,
                        onQtyChanged: (val) => setState(() {
                              currentValue = val;
                            }),
                        initVal: currentValue,
                        minVal: 1,
                        qtyFormProps: QtyFormProps(
                            enableTyping: false,
                            style: TextStyle(
                                fontSize: 15.sp, fontWeight: FontWeight.bold)),
                        decoration: QtyDecorationProps(
                            plusBtn: Icon(LineIcons.plusCircle, size: 20.sp),
                            minusBtn: Icon(LineIcons.minusCircle, size: 20.sp),
                            fillColor: ThemaMain.background,
                            contentPadding: EdgeInsets.all(0),
                            isBordered: false,
                            isDense: false),
                        steps: 5)))
          ]),
      Column(children: [
        RowFiltro(
            tipos: tipos,
            estados: estados,
            zonas: zonas,
            updateData: (tipo, estado, zona) {
              setState(() {
                tipos = tipo;
                estados = estado;
                zonas = zona;
              });
            }),
        TextFormField(
            controller: buscador,
            enabled: !carga,
            onEditingComplete: () {},
            style: TextStyle(fontSize: 16.sp),
            decoration: InputDecoration(
                fillColor: ThemaMain.second,
                label: Text("Nombre exacto",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 15.sp,
                        color: ThemaMain.darkGrey)),
                suffixIcon: IconButton.filledTonal(
                    iconSize: 22.sp,
                    onPressed: () async {
                      if (!carga) {
                        setState(() {
                          carga = true;
                        });
                        selects.clear();
                        List<Filter> tempFilter = [];
                        String texto = buscador.text;
                        try {
                          // Si no es un número, solo buscamos por nombre
                          if (texto.isNotEmpty) {
                            tempFilter.add(Filter.and(
                                Filter("nombre_completo",
                                    isGreaterThanOrEqualTo: texto),
                                Filter("nombre_completo",
                                    isLessThanOrEqualTo: '$texto\uf8ff')));
                          }

                          if (tipos.isNotEmpty) {
                            tempFilter.add(Filter("tipo",
                                whereIn: tipos.map((e) => int.parse(e))));
                          }
                          if (estados.isNotEmpty) {
                            tempFilter.add(Filter("estado",
                                whereIn: estados.map((e) => int.parse(e))));
                          }
                          if (zonas.isNotEmpty) {
                            tempFilter.add(Filter("zona",
                                whereIn: zonas.map((e) => int.parse(e))));
                          }

                          var data = await ContactoFire.getItemPersonalizado(
                              id: null, filters: tempFilter, max: currentValue);
                          List<ReferenciaModelo> refTemp = [];
                          for (var element in data) {
                            var ref =
                                await ReferenciaFire.getItemRId(id: element.id);
                            if (ref != null) {
                              refTemp.add(ref);
                            }
                          }

                          setState(() {
                            selects = data;
                            referencias = refTemp;
                            carga = false;
                          });
                          var refStr = referencias
                              .where((e) => !selects
                                  .map((r) => r.id)
                                  .toList()
                                  .contains(e.idRForenea))
                              .map((e) => e.idRForenea)
                              .toList();
                          log("refStr: ${refStr}");
                          if (refStr.isNotEmpty) {
                            await Dialogs.showMorph(
                                title: "Contactos Referenciados",
                                description:
                                    "Se encontraron ${referencias.length} contactos referenciados que no estan en la lista\n¿Deseas agregar estos contactos a la lista para descargar?\nEsta operacion agregara contactos a la lista",
                                loadingTitle: "",
                                onAcceptPressed: (context) async {
                                  List<Filter> filter = [];
                                  filter.add(Filter("id", whereIn: refStr));
                                  var temp =
                                      await ContactoFire.getItemPersonalizado(
                                          id: null,
                                          filters: filter,
                                          max: currentValue);

                                  setState(() {
                                    selects.addAll(temp);
                                  });
                                });
                          }
                        } catch (e) {
                          var str = await TransFun.trad(e.toString());
                          showToast("Error: $str");
                          log("Error: ${e.toString()}");
                          setState(() {
                            carga = false;
                          });
                        }
                      } else {
                        showToast("Espera a que termine la peticion");
                      }
                    },
                    icon: Icon(Icons.youtube_searched_for,
                        color: carga ? ThemaMain.darkGrey : ThemaMain.green)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h))),
        AnimatedContainer(
            constraints:
                BoxConstraints(maxHeight: selects.isNotEmpty ? 65.h : 5.h),
            duration: Durations.medium3,
            decoration: BoxDecoration(
                color: ThemaMain.grey,
                borderRadius: BorderRadius.circular(borderRadius)),
            child: carga
                ? Center(
                    child: LoadingAnimationWidget.horizontalRotatingDots(
                        color: ThemaMain.green, size: 25.sp))
                : selects.isEmpty
                    ? Center(
                        child: Text("No se encontro ningun resultado",
                            style: TextStyle(fontSize: 14.sp)))
                    : Scrollbar(
                        trackVisibility: true,
                        thickness: 1.w,
                        child: ListView.builder(
                            itemCount: selects.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final contacto = selects[index];
                              return Column(children: [
                                SlideGeneral(
                                    ifDelete: (provider.usuario?.adminTipo ??
                                                0) ==
                                            -1 ||
                                        (provider.usuario?.adminTipo ?? 0) == 5,
                                    delete: () => Dialogs.showMorph(
                                        title: "Eliminar",
                                        description:
                                            "¿Esta seguro de eliminar este contacto?\nYa no se tendra acceso a este contacto por ningun metodo",
                                        loadingTitle: "Eliminando",
                                        onAcceptPressed: (context) async {
                                          var result =
                                              await ContactoFire.deleteItem(
                                                  model: contacto);
                                          if (result) {
                                            showToast(
                                                "Se ha eliminado este contacto de manera exitosa");
                                            setState(() {
                                              selects.removeAt(index);
                                            });
                                          } else {
                                            showToast(
                                                "No se ha podido eliminar este contacto");
                                          }
                                        }),
                                    id: contacto.id ?? 1,
                                    model: CardContactoWidget(
                                        entrada: buscador.text,
                                        contacto: contacto,
                                        funContact: (p0) async => showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                                child: TarjetaContactoDetalle(
                                                    contacto: contacto,
                                                    compartir: true))),
                                        compartir: false,
                                        naviPc: true,
                                        selectedVisible: false,
                                        selected: null,
                                        onSelected: (p0) {})),
                                if (selects.length - 1 == index)
                                  TextButton.icon(
                                      icon: Icon(LineIcons.eraser,
                                          size: 18.sp, color: ThemaMain.red),
                                      onPressed: () => setState(() {
                                            selects.clear();
                                            referencias.clear();
                                          }),
                                      label: Text(
                                          "Contactos encontrados: ${selects.length} / Referencias vinculadas: ${referencias.length}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontStyle: FontStyle.italic)))
                              ]);
                            }))),
        if (selects.isNotEmpty || referencias.isNotEmpty)
          LinearProgressIndicator(
              value: (selects.isNotEmpty ? progress : 0) /
                  (selects.length + referencias.length),
              minHeight: .6.h,
              valueColor: AlwaysStoppedAnimation(ThemaMain.green)),
        ElevatedButton.icon(
            onPressed: () async {
              await Dialogs.showMorph(
                  title: "Descargar la carga",
                  description:
                      "Desea ingresar los contactos encontrados como contactos nuevos?",
                  loadingTitle: "Descargando ...",
                  onAcceptPressed: (context) async {
                    setState(() {
                      c = true;
                    });
                  });
              if (c) {
                try {
                  for (var i = 0; i < selects.length; i++) {
                    var contacto = selects[i];
                    List<ContactoModelo> data = await ContactoController.buscar(
                        contacto.nombreCompleto!, 1);
                    if (data.isNotEmpty) {
                      await ContactoController.update(data.first);
                    } else {
                      await ContactoController.insert(contacto);
                    }

                    setState(() {
                      progress++;
                    });
                  }
                  for (var element in referencias) {
                    await ReferenciasController.insert(element);
                    setState(() {
                      progress++;
                    });
                  }
                  showToast("Se han descargado todos los contactos");
                } catch (e) {
                  showToast("Hubo un error\n$e");
                }
              }
            },
            icon: Icon(Icons.done_all, color: ThemaMain.green),
            label: Text("Descargar", style: TextStyle(fontSize: 14.sp)))
      ])
    ]));
  }
}
