import 'dart:developer';

import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/what_3_words_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/utilities/w3w_fun.dart';
import 'package:enrutador/views/widgets/card_contacto_widget.dart';
import 'package:enrutador/views/widgets/list_w3w.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  bool buscar = false;

  Future<void> send(MainProvider provider) async {
    setState(() {
      buscar = true;
    });
    var w3w = await W3wFun.suggets(provider.buscar.text);
    setState(() {
      w3wSuggest = w3w;
    });
    try {
      var coordenadas = Textos.truncPlusCode(PlusCode(provider.buscar.text));
      log("${coordenadas.toJson()}");
      await MapFun.sendInitUri(
          provider: provider,
          lat: coordenadas.latitude,
          lng: coordenadas.longitude);
      return;
    } catch (e) {
      debugPrint("error: $e");
    }
    try {
      var newText = provider.buscar.text.removeAllWhitespace.split(",");
      var text = LatLng(double.parse(newText[0]), double.parse(newText[1]));
      var ps = Textos.psCODE(text.latitude, text.longitude);
      var coordenadas = Textos.truncPlusCode(PlusCode(ps));
      log("${coordenadas.toJson()}");
      await MapFun.sendInitUri(
          provider: provider,
          lat: coordenadas.latitude,
          lng: coordenadas.longitude);
      return;
    } catch (e) {
      debugPrint("error: $e");
    }
    setState(() {
      buscar = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);

    return Padding(
        padding: EdgeInsets.only(top: 1.h),
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
              width: 100.w,
              child: Column(children: [
                AnimatedTextField(
                    animationType: Animationtype.slideReversed,
                    animationDuration: Duration(seconds: 5),
                    style: TextStyle(fontSize: 16.sp),
                    focusNode: foc,
                    onTapOutside: (event) {
                      if (foc.hasFocus) {
                        foc.unfocus();
                      }
                    },
                    controller: provider.buscar,
                    onSubmitted: (value) async => await send(provider),
                    onChanged: (value) => setState(() {
                          provider.buscar.text = value;
                        }),
                    decoration: InputDecoration(
                        fillColor: ThemaMain.second,
                        suffixIcon: provider
                                .buscar.text.removeAllWhitespace.isNotEmpty
                            ? buscar
                                ? LoadingAnimationWidget.inkDrop(
                                    color: ThemaMain.primary, size: 20.sp)
                                : IconButton.filled(
                                    iconSize: 20.sp,
                                    onPressed: () async => await send(provider),
                                    icon: Icon(Icons.send_rounded,
                                        color: ThemaMain.green))
                            : null,
                        prefixIcon: AnimatedCrossFade(
                            alignment: AlignmentGeometry.center,
                            firstChild: IconButton(
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
                            secondChild: Padding(
                                padding: EdgeInsets.only(left: 2.w, top: 1.h),
                                child: Icon(Icons.search_rounded,
                                    size: 22.sp, color: ThemaMain.primary)),
                            crossFadeState: provider
                                    .buscar.text.removeAllWhitespace.isNotEmpty
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: Durations.long1),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h)),
                    hintTextStyle:
                        TextStyle(fontSize: 15.sp, fontStyle: FontStyle.italic),
                    hintTexts: [
                      'Nombre ej: Maria',
                      'Telefono ej: 99X XXX XXXX',
                      'PlusCode ej: 76HF9WGR+W6F',
                      'What3Words ej: palabra.palabra.palabra',
                      'Coordenadas ej: 21.377300, -90.059438'
                    ]),
                RowFiltro(),
                if (provider.buscar.text != "")
                  Column(children: [
                    Container(
                        constraints: BoxConstraints(maxHeight: 18.h),
                        child: Scrollbar(
                            child: ListView.builder(
                                itemCount: w3wSuggest.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.all(0),
                                itemBuilder: (context, index) {
                                  final w3w = w3wSuggest[index];
                                  return ListW3w(w3w: w3w);
                                }))),
                    FutureBuilder(
                        future:
                            ContactoController.buscar(provider.buscar.text, 8),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                                constraints: BoxConstraints(maxHeight: 28.h),
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
