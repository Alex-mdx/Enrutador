import 'package:auto_size_text/auto_size_text.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/dialogs/dialog_compartir.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:substring_highlight/substring_highlight.dart';
import '../../controllers/tipo_controller.dart';
import 'package:badges/badges.dart' as bd;

class CardContactoWidget extends StatelessWidget {
  final ContactoModelo contacto;
  final Function(ContactoModelo) funContact;
  final bool compartir;
  final bool selectedVisible;
  final bool? selected;
  final Function(bool?) onSelected;
  final String? entrada;
  const CardContactoWidget(
      {super.key,
      required this.contacto,
      required this.funContact,
      required this.compartir,
      required this.selectedVisible,
      required this.selected,
      required this.onSelected,
      required this.entrada});

  @override
  Widget build(BuildContext context) {
    return bd.Badge(
        badgeStyle: bd.BadgeStyle(
            badgeColor: Colors.black, shape: bd.BadgeShape.twitter),
        showBadge: contacto.estado != null || (contacto.estado ?? -1) > -1,
        position: bd.BadgePosition.topStart(start: 0, top: 0),
        badgeAnimation: bd.BadgeAnimation.size(),
        badgeContent: Consumer<MainProvider>(
            builder: (context, provider, child) => Icon(Icons.circle,
                color: provider.estados
                    .firstWhereOrNull(
                        (element) => element.id == contacto.estado)
                    ?.color,
                size: 16.sp)),
        child: GestureDetector(
            onTap: () => funContact(contacto),
            child: Card(
                child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 1.w, vertical: .5.h),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              constraints: BoxConstraints(maxWidth: 25.w),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (selectedVisible)
                                      Checkbox.adaptive(
                                          value: selected,
                                          onChanged: (value) =>
                                              onSelected(value)),
                                    FutureBuilder(
                                        future: TipoController.getItem(
                                            data: contacto.tipo ?? -1),
                                        builder: (context, data) => Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Icon(Icons.circle,
                                                      color: ThemaMain.second,
                                                      size: 26.sp),
                                                  Icon(
                                                      data.data?.icon ??
                                                          Icons.person,
                                                      size: 22.sp,
                                                      color: data.data?.color ??
                                                          ThemaMain.primary)
                                                ]))
                                  ])),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                SubstringHighlight(
                                    text:
                                        "${contacto.nombreCompleto ?? "Sin nombre"}${kDebugMode ? " -${contacto.tipo} - ${contacto.estado}" : ""}",
                                    term: entrada,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textStyle: TextStyle(
                                        color: ThemaMain.darkBlue,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold),
                                    textStyleHighlight: TextStyle(
                                        fontSize: 16.sp,
                                        color: ThemaMain.primary,
                                        fontWeight: FontWeight.bold)),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (compartir)
                                        AutoSizeText(
                                            contacto.domicilio ??
                                                "Sin domicilio",
                                            maxLines: 2,
                                            minFontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 15.sp)),
                                      SelectableText(
                                          "Plus Code: ${Textos.psCODE(contacto.latitud, contacto.longitud)}",
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic)),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SubstringHighlight(
                                                text:
                                                    "Tel: ${contacto.numero ?? "Ø"}",
                                                term: entrada,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textStyle: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: ThemaMain.darkBlue),
                                                textStyleHighlight: TextStyle(
                                                    fontSize: 15.sp,
                                                    color: ThemaMain.primary,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SubstringHighlight(
                                                text:
                                                    "Otro: ${contacto.otroNumero ?? "Ø"}",
                                                term: entrada,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textStyle: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: ThemaMain.darkBlue),
                                                textStyleHighlight: TextStyle(
                                                    fontSize: 15.sp,
                                                    color: ThemaMain.primary,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ])
                                    ])
                              ])),
                          if (compartir)
                            IconButton.filled(
                                onPressed: () async {
                                  var temp = await ContactoController.getItem(
                                      lat: contacto.latitud,
                                      lng: contacto.longitud);
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          DialogCompartir(contacto: temp!));
                                },
                                iconSize: 20.sp,
                                icon: Icon(Icons.share, color: ThemaMain.white))
                        ])))));
  }
}
