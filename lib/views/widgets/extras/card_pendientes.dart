import 'package:enrutador/controllers/contacto_fire.dart';
import 'package:enrutador/controllers/pendiente_fire.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/views/widgets/card_contacto_widget.dart';
import 'package:enrutador/views/widgets/extras/card_nota.dart';
import 'package:enrutador/views/widgets/extras/chip_referencia.dart';
import 'package:enrutador/views/widgets/sliding_cards/tarjeta_contacto_detalle.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../controllers/nota_fire.dart';
import '../../../controllers/referencia_fire.dart';
import '../../../controllers/usuario_fire.dart';
import '../../../models/pendiente_model.dart';
import '../../../utilities/theme/theme_color.dart';
import '../../dialogs/dialog_comparativa.dart';
import 'card_account_lite.dart';

class CardPendientes extends StatefulWidget {
  final PendienteModel pendientes;
  final Function()? fun;
  const CardPendientes({super.key, required this.pendientes, this.fun});

  @override
  State<CardPendientes> createState() => _CardPendientesState();
}

class _CardPendientesState extends State<CardPendientes> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Card(
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
                    child: Text("Envio: ${widget.pendientes.empleadoId}",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold))),
                GestureDetector(
                    onTap: () async {
                      if (widget.pendientes.aceptadoEmpleadoId != null) {
                        var user = await UsuarioFire.getItem(
                            table: "empleado_id",
                            query: widget.pendientes.aceptadoEmpleadoId!);
                        if (user != null) {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  Dialog(child: CardAccountLite(user: user)));
                        } else {
                          showToast("No se encontro un contacto con este ID");
                        }
                      }
                    },
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (widget.pendientes.sincronizado != 0)
                        Icon(Icons.check_circle,
                            color: widget.pendientes.sincronizado == 1
                                ? ThemaMain.green
                                : ThemaMain.red,
                            size: 22.sp),
                      Text(
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
                                      : FontWeight.bold))
                    ]))
              ]),
              Divider(indent: 4.w, endIndent: 4.w, height: .5.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                ElevatedButton.icon(
                    icon: Icon(Icons.contacts,
                        size: 20.sp, color: ThemaMain.primary),
                    onPressed: () {
                      if (widget.pendientes.contactos.isNotEmpty) {
                        showDialog(
                            context: context,
                            builder: (context) => Dialog(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        widget.pendientes.contactos.length,
                                    itemBuilder: (context, index) =>
                                        CardContactoWidget(
                                            entrada: "",
                                            contacto: widget
                                                .pendientes.contactos[index],
                                            naviPc: false,
                                            funContact: (p0) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      DialogComparativa(
                                                          entrada: p0));
                                            },
                                            compartir: false,
                                            selectedVisible: false,
                                            onSelected: (p0) {}))));
                      } else {
                        showToast(
                            "No hay contactos ingresados en este pendiente");
                      }
                    },
                    label: Text("${widget.pendientes.contactos.length}",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold))),
                ElevatedButton.icon(
                    icon: Icon(Icons.person_add_alt_1,
                        size: 20.sp, color: ThemaMain.green),
                    onPressed: () {
                      if (widget.pendientes.referencias.isNotEmpty) {
                        showDialog(
                            context: context,
                            builder: (context) => Dialog(
                                child: Padding(
                                    padding: EdgeInsets.all(8.sp),
                                    child: Wrap(
                                        alignment: WrapAlignment.spaceAround,
                                        runAlignment: WrapAlignment.center,
                                        children: widget.pendientes.referencias
                                            .map((e) => Card(
                                                    child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                      ChipReferencia(
                                                          ref: e,
                                                          latlng: LatLng(
                                                              e.contactoIdLat,
                                                              e.contactoIdLng),
                                                          origen: true,
                                                          extended: true),
                                                      Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            InkWell(
                                                                onTap:
                                                                    () async {
                                                                  showToast(
                                                                      "Buscando coincidencia...");
                                                                  var contacto =
                                                                      await ContactoFire
                                                                          .getItem(
                                                                              id: e.idForanea);
                                                                  if (contacto !=
                                                                      null) {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) =>
                                                                                Dialog(child: TarjetaContactoDetalle(contacto: contacto, compartir: true)));
                                                                  } else {
                                                                    showToast(
                                                                        "No se encontraron coincidencias");
                                                                  }
                                                                },
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            borderRadius),
                                                                child: Text(
                                                                    "${e.idForanea}",
                                                                    style: TextStyle(
                                                                        fontSize: 14
                                                                            .sp,
                                                                        fontWeight:
                                                                            FontWeight.bold))),
                                                            Text(" → ",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15.sp)),
                                                            InkWell(
                                                                onTap:
                                                                    () async {
                                                                  showToast(
                                                                      "Buscando coincidencia...");
                                                                  var contacto =
                                                                      await ContactoFire
                                                                          .getItem(
                                                                              id: e.idRForenea);
                                                                  if (contacto !=
                                                                      null) {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) =>
                                                                                Dialog(child: TarjetaContactoDetalle(contacto: contacto, compartir: true)));
                                                                  } else {
                                                                    showToast(
                                                                        "No se encontraron coincidencias");
                                                                  }
                                                                },
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            borderRadius),
                                                                child: Text(
                                                                    "${e.idRForenea}",
                                                                    style: TextStyle(
                                                                        fontSize: 14
                                                                            .sp,
                                                                        fontWeight:
                                                                            FontWeight.bold)))
                                                          ])
                                                    ])))
                                            .toList()))));
                      } else {
                        showToast(
                            "No hay referencias ingresadas en este pendiente");
                      }
                    },
                    label: Text("${widget.pendientes.referencias.length}",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold))),
                ElevatedButton.icon(
                    icon:
                        Icon(Icons.note, size: 20.sp, color: ThemaMain.yellow),
                    onPressed: () {
                      if (widget.pendientes.notas.isNotEmpty) {
                        showDialog(
                            context: context,
                            builder: (context) => Dialog(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: widget.pendientes.notas.length,
                                    itemBuilder: (context, index) => CardNota(
                                        element: widget.pendientes.notas[index],
                                        maxLine: 2,
                                        onDelete: () async {
                                          if (widget.pendientes.sincronizado ==
                                              0) {
                                            List<NotaModel> newNota = [];
                                            newNota.add(widget.pendientes.notas
                                                .removeAt(index));
                                            var newPendiente = widget.pendientes
                                                .copyWith(notas: newNota);
                                            await PendienteFire.sendItem(
                                                table: "id",
                                                query: widget.pendientes.id,
                                                data: newPendiente);
                                            if (widget.fun != null) {
                                              await widget.fun!();
                                            }
                                            showToast(
                                                "Nota eliminada del pendiente");
                                            Navigation.pop();
                                          } else {
                                            showToast(
                                                "No se puede eliminar la nota porque el pendiente ya fue sincronizado");
                                          }
                                        }))));
                      } else {
                        showToast("No hay notas ingresadas en este pendiente");
                      }
                    },
                    label: Text("${widget.pendientes.notas.length}",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)))
              ]),
              Divider(height: .5.h),
              Column(children: [
                Row(children: [
                  Icon(Icons.timelapse, size: 18.sp, color: ThemaMain.primary),
                  Text(
                      "Fecha Enviado: ${Textos.fechaYMDHMS(fecha: widget.pendientes.fechaPendiente)} (${Textos.conversionDiaNombre(widget.pendientes.fechaPendiente, DateTime.now())})",
                      style: TextStyle(fontSize: 15.sp))
                ]),
                Row(children: [
                  Icon(Icons.checklist, size: 18.sp, color: ThemaMain.green),
                  Text(
                      "Fecha Revisado: ${widget.pendientes.fechaSincronizado == null ? "Sin fecha" : "${Textos.fechaYMDHMS(fecha: widget.pendientes.fechaSincronizado!)} (${Textos.conversionDiaNombre(widget.pendientes.fechaSincronizado!, DateTime.now())})"}",
                      style: TextStyle(fontSize: 15.sp))
                ])
              ]),
              if (widget.pendientes.sincronizado == 0 &&
                  (provider.usuario?.adminTipo ?? 0) > 1)
                Column(children: [
                  Divider(height: .5.h),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(ThemaMain.red)),
                            icon: Icon(LineIcons.thumbsDown,
                                size: 20.sp, color: ThemaMain.background),
                            onPressed: () => Dialogs.showMorph(
                                title: "Rechazar",
                                description:
                                    "¿Desea rechazar este pendiente?\nLos cambios no se subiran a la nube",
                                loadingTitle: "Rechazando",
                                onAcceptPressed: (context) async {
                                  var newPendiente = widget.pendientes.copyWith(
                                      sincronizado: -1,
                                      fechaSincronizado: DateTime.now(),
                                      aceptadoEmpleadoId:
                                          provider.usuario?.empleadoId);
                                  await PendienteFire.sendItem(
                                      table: "id",
                                      query: widget.pendientes.id,
                                      data: newPendiente);
                                  if (widget.fun != null) {
                                    await widget.fun!();
                                  }
                                  showToast("Pendiente aceptado");
                                }),
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
                            onPressed: () => Dialogs.showMorph(
                                title: "Aceptar",
                                description:
                                    "¿Desea aceptar este pendiente?\nLos cambios se subiran a la nube",
                                loadingTitle: "Aceptando",
                                onAcceptPressed: (context) async {
                                  var newPendiente = widget.pendientes.copyWith(
                                      sincronizado: 1,
                                      fechaSincronizado: DateTime.now(),
                                      aceptadoEmpleadoId:
                                          provider.usuario?.empleadoId);
                                  for (var element in newPendiente.contactos) {
                                    await ContactoFire.sendItem(
                                        data: element,
                                        table: "id",
                                        query: widget.pendientes.id);
                                  }
                                  for (var element
                                      in newPendiente.referencias) {
                                    await ReferenciaFire.send(
                                        referencia: element);
                                  }
                                  for (var element in newPendiente.notas) {
                                    await NotaFire.send(nota: element);
                                  }
                                  await PendienteFire.sendItem(
                                      table: "id",
                                      query: widget.pendientes.id,
                                      data: newPendiente);
                                  if (widget.fun != null) {
                                    await widget.fun!();
                                  }
                                  showToast("Pendiente aceptado");
                                }),
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
