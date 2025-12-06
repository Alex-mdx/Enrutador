import 'dart:developer';

import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/geo_names_model.dart';
import 'package:enrutador/models/what_3_words_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/utilities/w3w_fun.dart';
import 'package:enrutador/views/widgets/card_contacto_widget.dart';
import 'package:enrutador/views/widgets/list_geo_name.dart';
import 'package:enrutador/views/widgets/list_w3w.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../models/geo_postal_model.dart';
import '../../../utilities/geo_fun.dart';
import '../list_geo_postal.dart';
import 'row_filtro.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  FocusNode foc = FocusNode();
  List<What3WordsModel> w3wSuggest = [];
  List<GeoNamesModel> geoNamesSuggest = [];
  List<GeoPostalModel> geoPostalSuggest = [];
  bool buscar = false;

  Future<void> send(MainProvider provider) async {
    setState(() {
      buscar = true;
    });
    w3wSuggest.clear();
    geoPostalSuggest.clear();
    geoNamesSuggest.clear();

    try {
      var coordenadas = await Textos.psShortToFull(provider.buscar.text);
      log("${coordenadas?.toJson()}");
      if (coordenadas != null) {
        await MapFun.sendInitUri(
            provider: provider,
            lat: coordenadas.latitude,
            lng: coordenadas.longitude);
        return;
      }
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
    if (provider.buscar.text.split(".").length == 3) {
      var w3w = await W3wFun.suggets(provider.buscar.text)
          .timeout(Duration(seconds: 3));
      setState(() {
        w3wSuggest = w3w;
      });
    } else if (provider.buscar.text.isNumericOnly) {
      debugPrint("postal");
      var geoPostal = await GeoFun.searchPostalCode(provider.buscar.text, null)
          .timeout(Duration(seconds: 3));
      setState(() {
        geoPostalSuggest = geoPostal;
      });
    } else {
      debugPrint("geoNames");
      var geoNames = await GeoFun.searchCity(provider.buscar.text, null)
          .timeout(Duration(seconds: 3));
      setState(() {
        geoNamesSuggest = geoNames;
      });
    }
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
                    animationDuration: Duration(seconds: 3),
                    style: TextStyle(fontSize: 16.sp),
                    focusNode: foc,
                    onTapOutside: (event) {
                      if (foc.hasFocus) {
                        foc.unfocus();
                      }
                    },
                    controller: provider.buscar,
                    onSubmitted: (value) async =>
                        await send(provider).whenComplete(() => setState(() {
                              buscar = false;
                            })),
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
                                    onPressed: () async => await send(provider)
                                        .whenComplete(() => setState(() {
                                              buscar = false;
                                            })),
                                    icon: Icon(Icons.send_rounded,
                                        color: ThemaMain.green))
                            : null,
                        prefixIcon: AnimatedCrossFade(
                            alignment: AlignmentGeometry.center,
                            firstChild: IconButton(
                                iconSize: 22.sp,
                                onPressed: () {
                                  w3wSuggest.clear();
                                  geoPostalSuggest.clear();
                                  geoNamesSuggest.clear();
                                  setState(() {
                                    provider.buscar.clear();
                                    buscar = false;
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
                            crossFadeState:
                                provider.buscar.text.removeAllWhitespace.isNotEmpty
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                            duration: Durations.medium2),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h)),
                    hintTextStyle: TextStyle(fontSize: 15.sp, fontStyle: FontStyle.italic),
                    hintTexts: [
                      'Nombre ej: Maria, Angela, Ana',
                      'Telefono ej: 99X XXX XXXX',
                      'PlusCode ej: QR78+Q4 Miami, Florida, EE. UU',
                      'PlusCode ej: 76HF9WGR+W6F',
                      'What3Words ej: palabra.palabra.palabra',
                      'Coordenadas ej: 21.377300, -90.059438',
                      'Coordenadas ej: 21° 22\' 38.28", 90° 3\' 33.98"',
                      'Codigo Postal ej: 12345',
                      'Ciudad ej: Ciudad, Estado, Pais'
                    ]),
                RowFiltro(),
                if (provider.buscar.text != "") w3wBuilder(provider)
              ]))
        ]));
  }

  Column w3wBuilder(MainProvider provider) {
    return Column(children: [
      Container(
          constraints: BoxConstraints(maxHeight: 20.h),
          child: Scrollbar(
              child: ListView.builder(
                  itemCount: w3wSuggest.isNotEmpty
                      ? w3wSuggest.length
                      : geoNamesSuggest.isNotEmpty
                          ? geoNamesSuggest.length
                          : geoPostalSuggest.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    if (w3wSuggest.isNotEmpty) {
                      final w3w = w3wSuggest[index];
                      return ListW3w(w3w: w3w);
                    } else if (geoPostalSuggest.isNotEmpty) {
                      final geoPostal = geoPostalSuggest[index];
                      return ListGeoPostal(model: geoPostal);
                    } else {
                      final geoName = geoNamesSuggest[index];
                      return ListGeoName(model: geoName);
                    }
                  }))),
      FutureBuilder(
          future: ContactoController.buscar(provider.buscar.text, 8),
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
                            final contacto = snapshot.data![index];
                            return CardContactoWidget(
                                entrada: provider.buscar.text,
                                contacto: contacto,
                                funContact: (p0) async {
                                  provider.animaMap.centerOnPoint(
                                      LatLng(
                                          contacto.latitud, contacto.longitud),
                                      zoom: 18);
                                  provider.mapSeguir = false;
                                  provider.contacto =
                                      await ContactoController.getItem(
                                          lat: contacto.latitud,
                                          lng: contacto.longitud);
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
    ]);
  }
}
