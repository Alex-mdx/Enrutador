import 'dart:convert';

import 'package:enrutador/controllers/usuario_fire.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/camara_fun.dart';
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

import '../../../utilities/funcion_parser.dart';
import '../../../utilities/theme/theme_color.dart';

class CardAccountLite extends StatefulWidget {
  final UsuarioModel user;
  final bool pop;
  final Function(UsuarioModel?)? fun;
  final bool local;
  const CardAccountLite(
      {super.key,
      required this.user,
      this.pop = true,
      this.fun,
      this.local = false});

  @override
  State<CardAccountLite> createState() => _CardAccountLiteState();
}

class _CardAccountLiteState extends State<CardAccountLite> {
  int pass = 0;
  late UsuarioModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    setState(() {
      pass = widget.user.adminTipo ?? 0;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> change(UsuarioModel user, {bool? pop}) async {
    var result = await UsuarioFire.updateItem(
        table: "id", query: "${user.id}", itsNumber: true, data: user);
    if (result) {
      showToast("Se ejecuto el cambio de manera exitosa");
      if (widget.fun != null) {
        await widget.fun!(null);
      }
      if (pop ?? widget.pop) {
        Navigation.pop();
      }
    } else {
      showToast("No se pudo ejecutar el cambio intente mas tarde");
    }
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
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "${user.id}. ${user.uuid ?? "Sin identificador"}",
                        style: TextStyle(
                            fontSize: 15.sp, color: ThemaMain.darkGrey))),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: InkWell(
                              onTap: () async {
                                if ((provider.usuario?.adminTipo ?? 0) >= 3) {
                                  try {
                                    var foto = (await CamaraFun.getGalleria(
                                            context,
                                            "Seleccione su foto de perfil"))
                                        .firstOrNull;
                                    if (foto != null) {
                                      var base = await foto.readAsBytes();
                                      var reducir =
                                          await Parser.reducirUint8List(
                                              imgBytes: base);
                                      var temp = user.copyWith(
                                          foto: base64Encode(reducir!),
                                          actualizacion: DateTime.now());
                                      if (!widget.local) {
                                        await change(temp);
                                      } else {
                                        setState(() {
                                          user = temp;
                                        });
                                        await widget.fun!(user);
                                      }
                                    }
                                  } catch (e) {
                                    showToast(
                                        "Hubo un error inesperado intente mas tarde");
                                  }
                                } else {
                                  showToast(
                                      "No tienes el nivel de administrador permitido para modificar este contacto");
                                }
                              },
                              child: user.foto != null
                                  ? Image.memory(base64Decode(user.foto!),
                                      filterQuality: FilterQuality.low,
                                      fit: BoxFit.cover)
                                  : Icon(Icons.photo_camera_front_rounded,
                                      size: 22.sp))),
                      Expanded(
                          flex: 10,
                          child: GestureDetector(
                              onTap: () {
                                if (provider.usuario?.adminTipo == 5 ||
                                    provider.usuario?.uuid == user.uuid) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => DialogSend(
                                          cabeza: "Modificar nombre",
                                          fun: (p0) async {
                                            var temp = user.copyWith(
                                                nombre: p0,
                                                actualizacion: DateTime.now());

                                            if (!widget.local) {
                                              await change(temp);
                                            } else {
                                              setState(() {
                                                user = temp;
                                              });
                                              await widget.fun!(user);
                                            }
                                          },
                                          tipoTeclado: TextInputType.name,
                                          fecha: null,
                                          entradaTexto: user.nombre));
                                } else {
                                  showToast(
                                      "No tienes el nivel de administrador permitido para modificar este contacto");
                                }
                              },
                              child: Text(user.nombre ?? "Sin nombre ingresado",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)))),
                      Expanded(
                          flex: 4,
                          child: TextButton.icon(
                              iconAlignment: IconAlignment.end,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 1.w, vertical: 0),
                                  backgroundColor: user.status == 0
                                      ? ThemaMain.red
                                      : ThemaMain.green),
                              label: Text(
                                  user.status == 0 ? "Inactivo" : "Activo",
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (provider.usuario?.adminTipo == 5) {
                                  Dialogs.showMorph(
                                      title: user.status == 1
                                          ? "Inhabilitar"
                                          : "Habilitar",
                                      description:
                                          "¿Desea ${user.status == 1 ? "Inhabilitar" : "habilitar"} este contacto?\n${user.status == 1 ? "Este contacto dejara de tener acceso a la aplicacion" : "Este contacto tendra acceso a las funciones de esta aplicacion"}",
                                      loadingTitle: "procesando",
                                      onAcceptPressed: (context) async {
                                        var temp = user.copyWith(
                                            status: user.status == 1 ? 0 : 1,
                                            actualizacion: DateTime.now());
                                        if (!widget.local) {
                                          await change(temp);
                                        } else {
                                          setState(() {
                                            user = temp;
                                          });
                                          await widget.fun!(user);
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
                            initVal: user.adminTipo ?? 0,
                            minVal: 0,
                            steps: 1,
                            onQtyChanged: (value) => setState(() {
                                  pass = value;
                                })),
                        if (pass != user.adminTipo)
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      ThemaMain.dialogbackground),
                                  padding:
                                      WidgetStatePropertyAll(EdgeInsets.zero)),
                              onPressed: () {
                                if (pass != user.adminTipo) {
                                  Dialogs.showMorph(
                                      title: "Cambiar nivel",
                                      description:
                                          "¿Desea cambiar el nivel de administrador de este contacto por el sugerido?\nEste cambio agregara/quitara ventajas y accesos privilegiados",
                                      loadingTitle: "Cambiando",
                                      onAcceptPressed: (context) async {
                                        var temp = user.copyWith(
                                            adminTipo: pass,
                                            actualizacion: DateTime.now());
                                        if (!widget.local) {
                                          await change(temp);
                                        } else {
                                          setState(() {
                                            user = temp;
                                          });
                                          await widget.fun!(user);
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
                                provider.usuario?.uuid == user.uuid) {
                              showDialog(
                                  context: context,
                                  builder: (context) => DialogSend(
                                      cabeza: "Vincular con numero de empleado",
                                      fun: (p0) async {
                                        if ((provider.usuario?.adminTipo ??
                                                0) >=
                                            3) {
                                          var temp = user.copyWith(
                                              empleadoId: p0,
                                              actualizacion: DateTime.now());
                                          if (!widget.local) {
                                            await change(temp);
                                          } else {
                                            setState(() {
                                              user = temp;
                                            });
                                            await widget.fun!(user);
                                          }
                                        } else {
                                          showToast(
                                              "No tiene el nivel de administrador necesario para ejercer el cambio");
                                        }
                                      },
                                      tipoTeclado: TextInputType.text,
                                      fecha: null,
                                      entradaTexto: user.empleadoId));
                            } else {
                              showToast(
                                  "No tienes el nivel de administrador permitido para modificar este contacto");
                            }
                          },
                          icon: Icon(Icons.link,
                              color: ThemaMain.green, size: 20.sp),
                          label: Text(
                              user.empleadoId ?? "Sin N. Empleado ingresado",
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
                                hijos: user.children,
                                user: user,
                                onSave: (p0) async {
                                  var temp = user.copyWith(
                                      children: p0,
                                      actualizacion: DateTime.now());
                                  if (!widget.local) {
                                    await change(temp, pop: true);
                                  } else {
                                    setState(() {
                                      user = temp;
                                    });
                                    await widget.fun!(user);
                                    Navigation.pop();
                                  }
                                })),
                        label: Text("Hijos: ${user.children.length}",
                            style: TextStyle(
                                color: ThemaMain.darkBlue,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold)))),
                Row(children: [
                  Expanded(
                      child: Text(
                          "Creado:\n${user.creacion == null ? "Sin fecha" : Textos.fechaYMDHMS(fecha: user.creacion!)}",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 15.sp))),
                  Expanded(
                      child: Text(
                          "Actualizado:\n${user.actualizacion == null ? "Sin fecha" : Textos.fechaYMDHMS(fecha: user.actualizacion!)}",
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 15.sp)))
                ])
              ])
            ])));
  }
}
