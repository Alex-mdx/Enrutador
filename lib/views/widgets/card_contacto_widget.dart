import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/dialogs/dialog_compartir.dart';
import 'package:flutter/material.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/tipo_controller.dart';

class CardContactoWidget extends StatelessWidget {
  final ContactoModelo contacto;
  final Function(ContactoModelo) funContact;
  final bool compartir;
  final bool selectedVisible;
  final bool? selected;
  final Function(bool?) onSelected;
  const CardContactoWidget(
      {super.key,
      required this.contacto,
      required this.funContact,
      required this.compartir,
      required this.selectedVisible,
      required this.selected,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => funContact(contacto),
        child: Card(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          constraints: BoxConstraints(maxWidth: 25.w),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (selectedVisible)
                              Checkbox.adaptive(
                                  value: selected,
                                  onChanged: (value) => onSelected(value)),
                            FutureBuilder(
                                future: TipoController.getItem(
                                    data: contacto.tipo ?? -1),
                                builder: (context, data) => Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(Icons.circle,
                                              color: ThemaMain.second,
                                              size: 26.sp),
                                          Icon(data.data?.icon ?? Icons.person,
                                              size: 22.sp,
                                              color: data.data?.color ??
                                                  ThemaMain.primary)
                                        ]))
                          ])),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(contacto.nombreCompleto ?? "Sin nombre",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(contacto.domicilio ?? "Sin domicilio",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 15.sp)),
                                  Text(
                                      "Plus Code: ${PlusCode.encode(LatLng(contacto.latitud, contacto.longitud), codeLength: 12)}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 15.sp)),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        FutureBuilder(
                                            future: TipoController.getItem(
                                                data: contacto.tipo ?? -1),
                                            builder: (context, data) => Text(
                                                "Tipo:\n${data.data?.nombre ?? "Ø"}",
                                                style: TextStyle(
                                                    fontSize: 14.sp))),
                                        Text(
                                            "Estatus: ${contacto.estado ?? "Ø"}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 14.sp))
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Tel: ${contacto.numero ?? "Ø"}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 14.sp)),
                                        Text(
                                            "Otro: ${contacto.otroNumero ?? "Ø"}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 14.sp))
                                      ])
                                ])
                          ])),
                      Container(
                          constraints: BoxConstraints(maxWidth: 20.w),
                          child: (compartir)
                              ? IconButton.filled(
                                  onPressed: () async => showDialog(
                                      context: context,
                                      builder: (context) =>
                                          DialogCompartir(contacto: contacto)),
                                  iconSize: 20.sp,
                                  icon:
                                      Icon(Icons.share, color: ThemaMain.white))
                              : null)
                    ]))));
  }
}
