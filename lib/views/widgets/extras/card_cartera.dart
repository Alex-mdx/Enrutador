import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/extras/card_qr_widget.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';

import '../../../models/cartera_model.dart';

class CardCartera extends StatelessWidget {
  final CarteraModel cartera;
  final Function()? onTap;
  final Function()? onLongPress;
  const CardCartera(
      {super.key, required this.cartera, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async => onTap != null ? await onTap!() : null, 
      onLongPress: () async =>
          onLongPress != null ? await onLongPress!() : null,
      child: Card(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .5.h),
              child: Column(children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Expanded(
                      flex: 6,
                      child: Column(children: [
                        Text(cartera.uuid,
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Divider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(Icons.person,
                                    color: ThemaMain.green, size: 20.sp),
                                Text("Creado: ${cartera.empleadoBy}",
                                    style: TextStyle(fontSize: 14.sp))
                              ]),
                              Row(children: [
                                Icon(Icons.person_search,
                                    color: ThemaMain.yellow, size: 20.sp),
                                Text("Asignado: ${cartera.empleadoTo}",
                                    style: TextStyle(fontSize: 14.sp))
                              ])
                            ]),
                        Row(children: [
                          Icon(LineIcons.userFriends,
                              size: 20.sp, color: ThemaMain.primary),
                          Text(
                              "Contactos ingresados: ${cartera.contactos.length} ",
                              style: TextStyle(fontSize: 14.sp))
                        ])
                      ])),
                  IconButton.filledTonal(
                      icon: Icon(Icons.qr_code, color: ThemaMain.darkBlue),
                      iconSize: 22.sp,
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => Dialog(
                              child: QrWidget(
                                  text: cartera.codigo.toString(),
                                  size: 72.sp))))
                ])
              ]))),
    );
  }
}
