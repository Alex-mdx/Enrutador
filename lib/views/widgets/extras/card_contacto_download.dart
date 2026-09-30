import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/tip_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/fireController/contacto_fire.dart';
import '../../../models/contacto_model.dart';
import '../../../utilities/theme/theme_color.dart';
import '../sliding_cards/tarjeta_contacto_detalle.dart';

class CardContactoDownload extends StatefulWidget {
  final TipModel tip;
  final List<ContactoModelo> contactoTemp;
  final Function(List<ContactoModelo>) refreshContactos;
  final int index;
  final bool cargaContact;
  final Function(bool) setCargaContact;

  const CardContactoDownload(
      {super.key,
      required this.tip,
      required this.contactoTemp,
      required this.refreshContactos,
      required this.index,
      required this.cargaContact,
      required this.setCargaContact});

  @override
  State<CardContactoDownload> createState() => _CardContactoDownloadState();
}

class _CardContactoDownloadState extends State<CardContactoDownload> {
  @override
  Widget build(BuildContext context) {
    var idTemp = int.parse(widget.tip.contactosIds[widget.index].split("-")[0]);
    var empleadoTemp = widget.tip.contactosIds[widget.index].split("-")[1];

    var exist = (widget.contactoTemp.firstWhereOrNull((element) =>
            (element.id == idTemp) && (element.empleadoId == empleadoTemp))) !=
        null;
    return InkWell(
        onTap: () async {
          if (!widget.cargaContact) {
            if (exist) {
              showDialog(
                  context: context,
                  builder: (context) => Dialog(
                      child: TarjetaContactoDetalle(
                          contacto: widget.contactoTemp.firstWhere((element) =>
                              (element.id == idTemp) &&
                              (element.empleadoId == empleadoTemp)),
                          compartir: true)));
            } else {
              setState(() {
                widget.setCargaContact(true);
              });
              List<Filter> filtro = [];
              filtro.add(Filter.and(Filter("id", isEqualTo: idTemp),
                  Filter("empleado_id", isEqualTo: empleadoTemp)));
              var temp = (await ContactoFire.getItemPersonalizado(
                      filters: filtro, max: 1))
                  .firstOrNull;
              if (temp != null) {
                widget.contactoTemp.add(temp);
                widget.refreshContactos(widget.contactoTemp);
              } else {
                showToast("No se encontro el contacto");
              }
              setState(() {
                widget.setCargaContact(false);
              });
            }
          } else {
            showToast("Hay una descarga de contacto en proceso");
          }
        },
        child: Card.filled(
            color: widget.cargaContact ? ThemaMain.darkGrey : null,
            child: Center(
                child: Text("Contacto\n#${widget.index + 1}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: exist ? ThemaMain.primary : null,
                        fontWeight: FontWeight.bold)))));
  }
}
