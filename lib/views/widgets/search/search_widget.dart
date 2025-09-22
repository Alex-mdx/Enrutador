import 'dart:developer';

import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/card_contacto_widget.dart';
import 'package:flutter/foundation.dart';
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
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: .5.h),
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
              width: 98.w,
              child: Column(children: [
                TextFormField(
                    focusNode: foc,
                    controller: provider.buscar,
                    onChanged: (value) => setState(() {
                          provider.buscar.text = value;
                        }),
                    style: TextStyle(fontSize: 18.sp),
                    decoration: InputDecoration(
                        fillColor: ThemaMain.second,
                        prefixIcon: IconButton(
                            iconSize: 20.sp,
                            onPressed: () {
                              provider.buscar.clear();
                              if (foc.hasFocus) {
                                foc.unfocus();
                              }
                            },
                            icon: Icon(Icons.arrow_back, color: ThemaMain.red)),
                        label: Text(
                            "Nombre | PlusCode | Telefono${kDebugMode ? " | What3Word" : ""}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 16.sp,
                                color: ThemaMain.darkGrey)),
                        suffixIcon: IconButton.filledTonal(
                            iconSize: 22.sp,
                            onPressed: () async {
                              try {
                                var ps = PlusCode(provider.buscar.text);
                                var decode = ps.decode();
                                var coordenadas = LatLng(
                                    decode.southWest.latitude,
                                    decode.southWest.longitude);
                                log("${coordenadas.toJson()}");
                                await MapFun.sendInitUri(
                                    provider: provider,
                                    lat: coordenadas.latitude,
                                    lng: coordenadas.longitude);
                              } catch (e) {
                                debugPrint("error: $e");
                              }
                            },
                            icon: Icon(Icons.youtube_searched_for,
                                color: ThemaMain.green)),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h))),
                RowFiltro(),
                if (provider.buscar.text != "")
                  FutureBuilder(
                      future:
                          ContactoController.buscar(provider.buscar.text, 10),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                              constraints: BoxConstraints(maxHeight: 40.h),
                              child: Scrollbar(
                                  child: ListView.builder(
                                      itemCount: snapshot.data!.length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(0),
                                      itemBuilder: (context, index) {
                                        final contacto = snapshot.data![index];
                                        return CardContactoWidget(
                                            entrada: provider.buscar.text,
                                            contacto: contacto,
                                            funContact: (p0) async {
                                              provider.animaMap.centerOnPoint(
                                                  LatLng(contacto.latitud,
                                                      contacto.longitud),
                                                  zoom: 18);
                                              provider.contacto =
                                                  await ContactoController
                                                      .getItem(
                                                          lat: contacto.latitud,
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
              ]))
        ]));
  }
}
