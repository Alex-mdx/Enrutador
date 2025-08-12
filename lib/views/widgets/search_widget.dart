import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  bool press = false;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(children: [
          AnimatedContainer(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(4, 4))
                  ]),
              width: press ? 95.w : 28.sp,
              duration: Durations.medium3,
              child: press
                  ? Column(children: [
                      TextFormField(
                          controller: provider.buscar,
                          onChanged: (value) {},
                          style: TextStyle(fontSize: 18.sp),
                          decoration: InputDecoration(
                              fillColor: ThemaMain.second,
                              prefixIcon: IconButton(
                                  iconSize: 20.sp,
                                  onPressed: () => setState(() {
                                        press = !press;
                                      }),
                                  icon: Icon(Icons.arrow_back,
                                      color: ThemaMain.red)),
                              label: Text(
                                  "Nombre | PlusCode | Telefono(s)${kDebugMode ? " | What3Word" : ""}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 16.sp,
                                      color: ThemaMain.darkGrey)),
                              suffixIcon: IconButton.filledTonal(
                                  iconSize: 22.sp,
                                  onPressed: () {},
                                  icon: Icon(Icons.youtube_searched_for,
                                      color: ThemaMain.green)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 1.h))),
                      FutureBuilder(
                          future: ContactoController.buscar(
                              provider.buscar.text, 6),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(0),
                                  itemBuilder: (context, index) {
                                    final contacto = snapshot.data![index];
                                    return ListTile(
                                        onTap: () async {
                                          try {
                                            provider.animaMap.centerOnPoint(
                                                LatLng(contacto.latitud,
                                                    contacto.longitud),
                                                zoom: 18);
                                            provider.contacto =
                                                await ContactoController
                                                    .getItem(
                                                        lat: contacto.latitud,
                                                        lng: contacto.longitud);
                                          } catch (err) {
                                            debugPrint("$err");
                                            var reparacion =
                                                ContactoModelo.fromJson({
                                              "latitud": contacto.latitud,
                                              "longitud": contacto.longitud,
                                              "foto": "null",
                                              "fotoReferencia": "null"
                                            });
                                            await ContactoController.update(
                                                reparacion);
                                            provider.contacto =
                                                await ContactoController
                                                    .getItem(
                                                        lat: contacto.latitud,
                                                        lng: contacto.longitud);
                                            showToast(
                                                "No se pudo obtener sus fotos, intente de nuevo");
                                          }
                                          provider.buscar.clear();
                                          press = false;
                                          await provider.slide.open();
                                          
                                        },
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 1.w, vertical: 0),
                                        tileColor: Colors.white.withAlpha(100),
                                        leading:
                                            Icon(Icons.person, size: 18.sp),
                                        title: Text(
                                            contacto.nombreCompleto ??
                                                "Sin nombre",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Domicilio: ${contacto.domicilio ?? "Sin domicilio"}",
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 15.sp)),
                                              Text(
                                                  "Plus Code: ${PlusCode.encode(LatLng(contacto.latitud, contacto.longitud), codeLength: 12)}",
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 15.sp)),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        "Tipo: ${contacto.tipo ?? "Ø"}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 14.sp)),
                                                    Text(
                                                        "Estatus: ${contacto.estado ?? "Ø"}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 14.sp)),
                                                    Text(
                                                        "Tel: ${contacto.numero ?? "Ø"}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 14.sp)),
                                                    Text(
                                                        "Otro: ${contacto.otroNumero ?? "Ø"}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 14.sp))
                                                  ])
                                            ]));
                                  });
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            } else {
                              return LinearProgressIndicator();
                            }
                          }),
                    ])
                  : IconButton.filled(
                      iconSize: 24.sp,
                      onPressed: () => setState(() {
                            press = !press;
                          }),
                      icon: Icon(Icons.search, color: ThemaMain.green))),
        ]));
  }
}
