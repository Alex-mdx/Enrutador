import 'package:enrutador/controllers/usuario_fire.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/views/dialogs/dialog_hijos.dart';
import 'package:enrutador/views/dialogs/dialog_send.dart';
import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_color.dart';

class CardAccountLite extends StatefulWidget {
  final UsuarioModel user;
  final bool pop;
  final Function()? fun;
  const CardAccountLite(
      {super.key, required this.user, this.pop = true, this.fun});

  @override
  State<CardAccountLite> createState() => _CardAccountLiteState();
}

class _CardAccountLiteState extends State<CardAccountLite> {
  int pass = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      pass = widget.user.adminTipo ?? 0;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Card(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: .5.h),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Column(children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                        "${widget.user.id}.- ${widget.user.uuid ?? "Sin identificador"}",
                        style: TextStyle(
                            fontSize: 15.sp, color: ThemaMain.darkGrey))),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 5,
                          child: GestureDetector(
                              onTap: () {
                                if (provider.usuario?.adminTipo == 5 ||
                                    provider.usuario?.uuid ==
                                        widget.user.uuid) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => DialogSend(
                                          cabeza: "Modificar nombre",
                                          fun: (p0) async {
                                            var temp = widget.user.copyWith(
                                                nombre: p0,
                                                actualizacion: DateTime.now());
                                            var result =
                                                await UsuarioFire.updateItem(
                                                    table: "id",
                                                    query: "${widget.user.id}",
                                                    itsNumber: true,
                                                    data: temp);
                                            if (result) {
                                              showToast(
                                                  "Se cambio el nombre de manera exitosa");
                                              if (widget.fun != null) {
                                                await widget.fun!();
                                              }
                                              if (widget.pop) {
                                                Navigation.pop();
                                              }
                                            } else {
                                              showToast(
                                                  "No se pudo ejecutar el cambio intente mas tarde");
                                            }
                                          },
                                          tipoTeclado: TextInputType.name,
                                          fecha: null,
                                          entradaTexto: widget.user.nombre));
                                } else {
                                  showToast(
                                      "No tienes el nivel de administrador permitido para modificar este contacto");
                                }
                              },
                              child: Text(
                                  widget.user.nombre ?? "Sin nombre ingresado",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)))),
                      Expanded(
                          flex: 2,
                          child: TextButton.icon(
                              iconAlignment: IconAlignment.end,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(0),
                                  backgroundColor: widget.user.status == 0
                                      ? ThemaMain.red
                                      : ThemaMain.green),
                              label: Text(
                                  widget.user.status == 0
                                      ? "Inactivo"
                                      : "Activo",
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (provider.usuario?.adminTipo == 5) {
                                  Dialogs.showMorph(
                                      title: widget.user.status == 1
                                          ? "Inhabilitar"
                                          : "Habilitar",
                                      description:
                                          "¿Desea ${widget.user.status == 1 ? "Inhabilitar" : "habilitar"} este contacto?\n${widget.user.status == 1 ? "Este contacto dejara de tener acceso a la aplicacion" : "Este contacto tendra acceso a las funciones de esta aplicacion"}",
                                      loadingTitle: "procesando",
                                      onAcceptPressed: (context) async {
                                        var temp = widget.user.copyWith(
                                            status:
                                                widget.user.status == 1 ? 0 : 1,
                                            actualizacion: DateTime.now());
                                        var result =
                                            await UsuarioFire.updateItem(
                                                table: "id",
                                                query: "${widget.user.id}",
                                                itsNumber: true,
                                                data: temp);
                                        if (result) {
                                          showToast(
                                              "Se cambio el estatus del contacto de manera exitosa");
                                          if (widget.fun != null) {
                                            await widget.fun!();
                                          }
                                          if (widget.pop) {
                                            Navigation.pop();
                                          }
                                        } else {
                                          showToast(
                                              "No se pudo ejecutar el cambio intente mas tarde");
                                        }
                                      });
                                } else {
                                  showToast(
                                      "No tienes el nivel de administrador permitido para modificar este contacto");
                                }
                              },
                              icon: Icon(Icons.account_circle,
                                  size: 20.sp, color: ThemaMain.background)))
                    ]),
                Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.spaceAround,
                    children: [
                      Column(children: [
                        InputQty.int(
                            qtyFormProps: QtyFormProps(
                                enableTyping: false,
                                enabled: provider.usuario?.adminTipo == 5),
                            decoration: QtyDecorationProps(
                                isDense: true,
                                leadingWidget: Icon(Icons.admin_panel_settings,
                                    color: ThemaMain.primary, size: 20.sp),
                                borderShape: BorderShapeBtn.circle,
                                isBordered: true),
                            maxVal: 5,
                            initVal: widget.user.adminTipo ?? 0,
                            minVal: 0,
                            steps: 1,
                            onQtyChanged: (value) => setState(() {
                                  pass = value;
                                })),
                        if (pass != widget.user.adminTipo)
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      ThemaMain.dialogbackground),
                                  padding:
                                      WidgetStatePropertyAll(EdgeInsets.zero)),
                              onPressed: () {
                                if (pass != widget.user.adminTipo) {
                                  Dialogs.showMorph(
                                      title: "Cambiar nivel",
                                      description:
                                          "¿Desea cambiar el nivel de administrador de este contacto por el sugerido?\nEste cambio agregara/quitara ventajas y accesos privilegiados",
                                      loadingTitle: "Cambiando",
                                      onAcceptPressed: () async {
                                        var temp = widget.user.copyWith(
                                            adminTipo: pass,
                                            actualizacion: DateTime.now());
                                        var result =
                                            await UsuarioFire.updateItem(
                                                table: "id",
                                                query: "${widget.user.id}",
                                                itsNumber: true,
                                                data: temp);
                                        if (result) {
                                          showToast(
                                              "Se cambio el estatus del contacto de manera exitosa");
                                          if (widget.fun != null) {
                                            await widget.fun!();
                                          }
                                          if (widget.pop) {
                                            Navigation.pop();
                                          }
                                        } else {
                                          showToast(
                                              "No se pudo ejecutar el cambio intente mas tarde");
                                        }
                                      });
                                }
                              },
                              child: Text("Aplicar",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold)))
                      ]),
                      ElevatedButton.icon(
                          onPressed: () {
                            if ((provider.usuario?.adminTipo ?? 0) >= 3 ||
                                provider.usuario?.uuid == widget.user.uuid) {
                              showDialog(
                                  context: context,
                                  builder: (context) => DialogSend(
                                      cabeza: "Vincular con numero de empleado",
                                      fun: (p0) async {
                                        if ((provider.usuario?.adminTipo ??
                                                0) >=
                                            3) {
                                          var temp = widget.user.copyWith(
                                              empleadoId: p0,
                                              actualizacion: DateTime.now());
                                          var result =
                                              await UsuarioFire.updateItem(
                                                  table: "id",
                                                  query: "${widget.user.id}",
                                                  itsNumber: true,
                                                  data: temp);
                                          if (result) {
                                            showToast(
                                                "Se cambio el nombre de manera exitosa");
                                            if (widget.fun != null) {
                                              await widget.fun!();
                                            }
                                            if (widget.pop) {
                                              Navigation.pop();
                                            }
                                          } else {
                                            showToast(
                                                "No se pudo ejecutar el cambio intente mas tarde");
                                          }
                                        } else {
                                          showToast(
                                              "No tiene el nivel de administrador necesario para ejercer el cambio");
                                        }
                                      },
                                      tipoTeclado: TextInputType.text,
                                      fecha: null,
                                      entradaTexto: widget.user.empleadoId));
                            } else {
                              showToast(
                                  "No tienes el nivel de administrador permitido para modificar este contacto");
                            }
                          },
                          icon: Icon(Icons.link,
                              color: ThemaMain.green, size: 20.sp),
                          label: Text(
                              widget.user.empleadoId ??
                                  "Sin N. Empleado ingresado",
                              style: TextStyle(
                                  color: ThemaMain.darkBlue,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold)))
                    ]),
                Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                        icon: Icon(LineIcons.helpingHands,
                            color: ThemaMain.green, size: 20.sp),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (context) => DialogHijos(
                                hijos: widget.user.children,
                                user: widget.user,
                                onSave: (p0) async {
                                  var temp = widget.user.copyWith(
                                      children: p0,
                                      actualizacion: DateTime.now());
                                  var result = await UsuarioFire.updateItem(
                                      table: "id",
                                      query: "${widget.user.id}",
                                      itsNumber: true,
                                      data: temp);
                                  if (result) {
                                    Navigation.pop();
                                    showToast(
                                        "Actualizo la lista de hijos de manera exitosa");
                                    if (widget.fun != null) {
                                      await widget.fun!();
                                    }
                                  } else {
                                    showToast(
                                        "No se pudo ejecutar el cambio intente mas tarde");
                                  }
                                })),
                        label: Text("Hijos: ${widget.user.children.length}",
                            style: TextStyle(
                                color: ThemaMain.darkBlue,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold)))),
                Row(children: [
                  Expanded(
                      child: Text(
                          "Creado:\n${widget.user.creacion == null ? "Sin fecha" : Textos.fechaYMDHMS(fecha: widget.user.creacion!)}",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 15.sp))),
                  Expanded(
                      child: Text(
                          "Actualizado:\n${widget.user.actualizacion == null ? "Sin fecha" : Textos.fechaYMDHMS(fecha: widget.user.actualizacion!)}",
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 15.sp)))
                ])
              ])
            ])));
  }
}
