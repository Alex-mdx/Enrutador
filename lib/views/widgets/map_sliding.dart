import 'dart:convert';

import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapSliding extends StatefulWidget {
  const MapSliding({super.key});

  @override
  State<MapSliding> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MapSliding> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return SlidingUpPanel(
        isDraggable: false,
        backdropEnabled: true,
        renderPanelSheet: false,
        backdropTapClosesPanel: true,
        defaultPanelState: PanelState.CLOSED,
        minHeight: 1.h,
        maxHeight: 35.h,
        controller: provider.slide,
        panel: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: ThemaMain.background,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(borderRadius))),
                  width: 100.w,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: Column(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                    width: 50.w,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Icon(LineIcons.wordFile,
                                                size: 24.sp,
                                                color: ThemaMain.red),
                                            Text("///aaaa.aaaaa.aaaa",
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ]),
                                          LinearProgressIndicator(
                                              color: ThemaMain.red),
                                          Row(children: [
                                            Icon(LineIcons.mapMarked,
                                                size: 22.sp,
                                                color: ThemaMain.primary),
                                            Text(
                                                "${PlusCode.encode(LatLng(double.parse((provider.contacto?.latitud ?? 0).toStringAsFixed(6)), double.parse((provider.contacto?.longitud ?? 0).toStringAsFixed(6))), codeLength: 12)}",
                                                style:
                                                    TextStyle(fontSize: 16.sp))
                                          ]),
                                          Text(
                                              "${provider.contacto?.latitud.toStringAsFixed(6)} ${provider.contacto?.longitud.toStringAsFixed(6)}",
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontStyle: FontStyle.italic))
                                        ])),
                                Wrap(spacing: 1.w, children: [
                                  IconButton.filledTonal(
                                      iconSize: 22.sp,
                                      onPressed: () {},
                                      icon: Icon(LineIcons.whatSApp,
                                          color: ThemaMain.green)),
                                  IconButton.filledTonal(
                                      iconSize: 22.sp,
                                      onPressed: () {},
                                      icon: Icon(Icons.save,
                                          color: ThemaMain.green)),
                                ])
                              ]),
                          Card(
                              color: ThemaMain.dialogbackground,
                              child: AnimatedContainer(
                                  duration: Duration(seconds: 1),
                                  height: 0.h,
                                  child: Scrollbar(
                                      child: ListView(children: [
                                    Row(children: [
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                        color: ThemaMain
                                                            .background,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                borderRadius)),
                                                    child: provider.contacto?.foto ==
                                                            null
                                                        ? InkWell(
                                                            child: Icon(
                                                                Icons.contacts,
                                                                size: 34.sp,
                                                                color: ThemaMain
                                                                    .primary))
                                                        : Image.memory(base64Decode(provider.contacto?.foto ?? "a"),
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Icon(Icons.broken_image,
                                                                    color: ThemaMain.red,
                                                                    size: 34.sp))),
                                                Divider(),
                                                Container(
                                                    decoration: BoxDecoration(
                                                        color: ThemaMain
                                                            .background,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                borderRadius)),
                                                    child: provider.contacto
                                                                ?.fotoReferencia ==
                                                            null
                                                        ? InkWell(
                                                            child: Icon(Icons.image,
                                                                color: ThemaMain
                                                                    .green,
                                                                size: 34.sp))
                                                        : Image.memory(base64Decode(provider.contacto?.foto ?? "a"),
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Icon(Icons.broken_image,
                                                                    color: ThemaMain.red,
                                                                    size: 34.sp)))
                                              ])),
                                      Expanded(
                                          flex: 4,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextButton.icon(
                                                          onPressed: () {},
                                                          label: Text(
                                                              "Nombre: ${provider.contacto?.nombreCompleto ?? "Sin nombre"}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.sp))),
                                                      TextButton.icon(
                                                          onPressed: () {},
                                                          label: Text(
                                                              "Domicilio: ${provider.contacto?.domicilio ?? "Sin Domicilio"}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.sp)))
                                                    ]),
                                                Wrap(
                                                    alignment: WrapAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      TextButton.icon(
                                                          onPressed: () {},
                                                          label: Text(
                                                              "Tipo\n${provider.contacto?.tipo ?? "Ø"}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))),
                                                      TextButton.icon(
                                                          onPressed: () {},
                                                          label: Text(
                                                              "Estado\n${provider.contacto?.tipo ?? "Ø"}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))),
                                                      TextButton.icon(
                                                          onPressed: () async {
                                                            const number =
                                                                '9861072354';
                                                            var res =
                                                                await FlutterPhoneDirectCaller
                                                                    .callNumber(
                                                                        number);
                                                            if (res != true) {
                                                              showToast(
                                                                  "No se pudo ejecutar la llamada");
                                                            }
                                                          },
                                                          label: Text(
                                                            "Telefono\n${provider.contacto?.tipo ?? "Ø"}",
                                                            style: TextStyle(
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ))
                                                    ]),
                                                Text("Referencias:",
                                                    style: TextStyle(
                                                        fontSize: 16.sp)),
                                                Wrap(
                                                    runAlignment: WrapAlignment
                                                        .spaceBetween,
                                                    spacing: .5.w,
                                                    children: [
                                                      ...provider.contacto
                                                              ?.contactoEnlances
                                                              .map((e) => IconButton.filled(
                                                                  onPressed:
                                                                      () {},
                                                                  icon: Icon(
                                                                      LineIcons
                                                                          .userTag,
                                                                      color: ThemaMain
                                                                          .darkBlue)))
                                                              .toList() ??
                                                          [],
                                                      IconButton.filled(
                                                          iconSize: 20.sp,
                                                          onPressed: () {},
                                                          icon: Icon(
                                                              Icons.person_add,
                                                              color: ThemaMain
                                                                  .green))
                                                    ]),
                                                Text(
                                                    "Notas${provider.contacto?.tipo ?? "\nVacio"}",
                                                    style: TextStyle(
                                                        fontSize: 16.sp))
                                              ]))
                                    ])
                                  ]))))
                        ]))
                  ]))
            ]));
  }
}
