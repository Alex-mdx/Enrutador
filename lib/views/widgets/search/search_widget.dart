import 'dart:developer';

import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/what_3_words_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/utilities/w3w_fun.dart';
import 'package:enrutador/views/widgets/card_contacto_widget.dart';
import 'package:enrutador/views/widgets/list_w3w.dart';
import 'package:flutter/material.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'row_filtro.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  FocusNode foc = FocusNode();
  List<What3WordsModel> w3wSuggest = [];
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0),
        child: Column(spacing: 0, children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 5,
                        offset: Offset(4, 4))
                  ]),
              width: 99.w,
              child: Column(children: [
                TextFormField(
                    focusNode: foc,
                    onTapOutside: (event) {
                      if (foc.hasFocus) {
                        foc.unfocus();
                      }
                    },
                    controller: provider.buscar,
                    onFieldSubmitted: (value) async {
                      var w3w = await W3wFun.suggets(value);
                      setState(() {
                        w3wSuggest = w3w;
                      });

                      try {
                        var ps = PlusCode(value);
                        var decode = ps.decode();
                        var coordenadas = LatLng(
                            double.parse(
                                decode.southWest.latitude.toStringAsFixed(6)),
                            double.parse(
                                decode.southWest.longitude.toStringAsFixed(6)));
                        log("${coordenadas.toJson()}");
                        await MapFun.sendInitUri(
                            provider: provider,
                            lat: coordenadas.latitude,
                            lng: coordenadas.longitude);
                      } catch (e) {
                        debugPrint("error: $e");
                      }
                    },
                    onChanged: (value) => setState(() {
                          provider.buscar.text = value;
                        }),
                    style: TextStyle(fontSize: 16.sp),
                    decoration: InputDecoration(
                        fillColor: ThemaMain.second,
                        prefixIcon: IconButton(
                            iconSize: 22.sp,
                            onPressed: () {
                              w3wSuggest.clear();
                              setState(() {
                                provider.buscar.clear();
                              });

                              if (foc.hasFocus) {
                                foc.unfocus();
                              }
                            },
                            icon: Icon(Icons.close_rounded,
                                color: ThemaMain.red)),
                        label: Text("Nombre | PlusCode | Telefono | What3Word",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 15.sp,
                                color: ThemaMain.darkGrey)),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h))),
                RowFiltro(),
                if (provider.buscar.text != "")
                  Column(children: [
                    Container(
                        constraints: BoxConstraints(maxHeight: 30.h),
                        child: Scrollbar(
                            child: ListView.builder(
                                itemCount: w3wSuggest.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.all(0),
                                itemBuilder: (context, index) {
                                  final w3w = w3wSuggest[index];
                                  return Column(children: [
                                    ListW3w(w3w: w3w),
                                    Divider(
                                        height: 0, indent: 5.w, endIndent: 5.w)
                                  ]);
                                }))),
                    FutureBuilder(
                        future:
                            ContactoController.buscar(provider.buscar.text, 8),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                                constraints: BoxConstraints(maxHeight: 30.h),
                                child: Scrollbar(
                                    child: ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(0),
                                        itemBuilder: (context, index) {
                                          final contacto =
                                              snapshot.data![index];
                                          return CardContactoWidget(
                                              entrada: provider.buscar.text,
                                              contacto: contacto,
                                              funContact: (p0) async {
                                                provider.animaMap.centerOnPoint(
                                                    LatLng(contacto.latitud,
                                                        contacto.longitud),
                                                    zoom: 18);
                                                provider.mapSeguir = false;
                                                provider.contacto =
                                                    await ContactoController
                                                        .getItem(
                                                            lat: contacto
                                                                .latitud,
                                                            lng: contacto
                                                                .longitud);
                                                provider.buscar.clear();
                                                await provider.slide.open();
                                              },
                                              compartir: false,
                                              selectedVisible: false,
                                              selected: null,
                                              onSelected: (p0) {});
                                        })));
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          } else {
                            return LinearProgressIndicator();
                          }
                        })
                  ])
              ]))
        ]));
  }
}
