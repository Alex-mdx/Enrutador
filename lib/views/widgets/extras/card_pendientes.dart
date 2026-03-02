import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/usuario_fire.dart';
import '../../../models/pendiente_model.dart';
import '../../../utilities/theme/theme_color.dart';
import 'card_account_lite.dart';

class CardPendientes extends StatefulWidget {
  final PendienteModel pendientes;
  const CardPendientes({super.key, required this.pendientes});

  @override
  State<CardPendientes> createState() => _CardPendientesState();
}

class _CardPendientesState extends State<CardPendientes> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Card(
        color: widget.pendientes.sincronizado == 0
            ? null
            : widget.pendientes.sincronizado == 1
                ? ThemaMain.green.withAlpha(70)
                : ThemaMain.red.withAlpha(70),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: .5.h),
            child: Column(children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(widget.pendientes.id,
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: ThemaMain.darkGrey,
                          fontWeight: FontWeight.bold))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                GestureDetector(
                    onTap: () async {
                      var user = await UsuarioFire.getItem(
                          table: "empleado_id",
                          query: widget.pendientes.empleadoId);
                      if (user != null) {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                Dialog(child: CardAccountLite(user: user)));
                      } else {
                        showToast("No se encontro un contacto con este ID");
                      }
                    },
                    child: Text("Enviado: ${widget.pendientes.empleadoId}",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold))),
                GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/contactos");
                    },
                    child: Text(
                        "Revision: ${widget.pendientes.aceptadoEmpleadoId ?? "Sin Aceptar"}",
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontStyle:
                                widget.pendientes.aceptadoEmpleadoId == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                            fontWeight:
                                widget.pendientes.aceptadoEmpleadoId == null
                                    ? FontWeight.normal
                                    : FontWeight.bold)))
              ]),
              Divider(indent: 4.w, endIndent: 4.w),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                ElevatedButton.icon(
                    icon: Icon(Icons.contacts,
                        size: 20.sp, color: ThemaMain.primary),
                    onPressed: () {},
                    label: Text("${widget.pendientes.contactos.length}",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold))),
                ElevatedButton.icon(
                    icon: Icon(Icons.person_add_alt_1,
                        size: 20.sp, color: ThemaMain.green),
                    onPressed: () {},
                    label: Text("${widget.pendientes.referencias.length}",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold))),
                ElevatedButton.icon(
                    icon:
                        Icon(Icons.note, size: 20.sp, color: ThemaMain.yellow),
                    onPressed: () {
                      if (widget.pendientes.notas.isNotEmpty) {
                      } else {
                        showToast("No hay notas ingresadas en este pendiente");
                      }
                    },
                    label: Text("${widget.pendientes.notas.length}",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)))
              ]),
              Divider(),
              Column(children: [
                Row(children: [
                  Icon(Icons.timelapse, size: 18.sp, color: ThemaMain.primary),
                  Text(
                      "Fecha enviado: ${Textos.fechaYMDHMS(fecha: widget.pendientes.fechaPendiente)} (${Textos.conversionDiaNombre(widget.pendientes.fechaPendiente, DateTime.now())})",
                      style: TextStyle(fontSize: 15.sp))
                ]),
                Row(children: [
                  Icon(Icons.checklist, size: 18.sp, color: ThemaMain.green),
                  Text(
                      "Fecha Revision: ${widget.pendientes.fechaSincronizado == null ? "Sin fecha" : "${Textos.fechaYMDHMS(fecha: widget.pendientes.fechaSincronizado!)} (${Textos.conversionDiaNombre(widget.pendientes.fechaSincronizado!, DateTime.now())})"}",
                      style: TextStyle(fontSize: 15.sp))
                ])
              ]),
              if (widget.pendientes.sincronizado == 0 &&
                  (provider.usuario?.adminTipo ?? 0) > 1)
                Column(children: [
                  Divider(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(ThemaMain.red)),
                            icon: Icon(LineIcons.thumbsDown,
                                size: 20.sp, color: ThemaMain.background),
                            onPressed: () {},
                            label: Text("Rechazar",
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    color: ThemaMain.background,
                                    fontWeight: FontWeight.bold))),
                        ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(ThemaMain.green)),
                            icon: Icon(LineIcons.thumbsUp,
                                size: 20.sp, color: ThemaMain.background),
                            onPressed: () {},
                            label: Text("Aceptar",
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    color: ThemaMain.background,
                                    fontWeight: FontWeight.bold)))
                      ])
                ])
            ])));
  }
}
