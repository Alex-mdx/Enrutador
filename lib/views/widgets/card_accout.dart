import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import '../../models/usuario_model.dart';
import '../../utilities/preferences.dart';
import '../../utilities/services/navigation_services.dart';
import '../../utilities/theme/theme_color.dart';
import '../../utilities/trans_fun.dart';
import '../dialogs/dialog_send.dart';

class CardAccout extends StatefulWidget {
  const CardAccout({super.key});

  @override
  State<CardAccout> createState() => _CardAccoutState();
}

class _CardAccoutState extends State<CardAccout> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: EdgeInsets.all(4.sp),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            onPressed: () => showDialog(
                                context: context,
                                builder: (context) => DialogSend(
                                    cabeza: "Ingresar nombre de cuenta",
                                    fun: (value) async {
                                      await FirebaseAuth.instance.currentUser
                                          ?.updateDisplayName(value);
                                      await FirebaseAuth.instance.currentUser
                                          ?.reload();
                                      setState(() {
                                        showToast(
                                            "Nombre de la cuenta actualizada");
                                      });
                                    },
                                    tipoTeclado: TextInputType.name,
                                    fecha: null,
                                    entradaTexto: FirebaseAuth
                                        .instance.currentUser?.displayName)),
                            icon: FirebaseAuth.instance.currentUser?.photoURL !=
                                    null
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                    child: Image.network(FirebaseAuth.instance.currentUser!.photoURL!,
                                        width: 24.sp,
                                        height: 24.sp,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(Icons.account_circle,
                                                    size: 24.sp,
                                                    color: ThemaMain.yellow)))
                                : Icon(Icons.person,
                                    size: 24.sp, color: ThemaMain.darkBlue),
                            label: Text(
                                FirebaseAuth.instance.currentUser?.displayName ?? "Sin nombre",
                                style: TextStyle(fontSize: 16.sp))),
                        Row(children: [
                          Expanded(
                              flex: 5,
                              child: TextButton.icon(
                                  onPressed: FirebaseAuth.instance.currentUser
                                              ?.emailVerified ==
                                          true
                                      ? () {
                                          showToast(
                                              "Tu correo ya está verificado");
                                        }
                                      : () => Dialogs.showMorph(
                                          title: "Autorizar correo",
                                          description:
                                              "¿Desea autorizar el correo de su cuenta?",
                                          loadingTitle: "Autorizando correo",
                                          onAcceptPressed: (context) async {
                                            try {
                                              await FirebaseAuth
                                                  .instance.currentUser
                                                  ?.sendEmailVerification();

                                              showToast(
                                                  "Correo de verificación enviado. Por favor revisa tu bandeja de entrada.");
                                            } catch (e) {
                                              showToast(
                                                  "Error al enviar correo: $e");
                                              log("Error al enviar verificación: $e");
                                            }
                                          }),
                                  icon: FirebaseAuth.instance.currentUser
                                              ?.emailVerified ==
                                          false
                                      ? Icon(Icons.mark_email_unread,
                                          size: 24.sp, color: ThemaMain.yellow)
                                      : Icon(Icons.mark_email_read,
                                          size: 24.sp, color: ThemaMain.green),
                                  label: Text(
                                      FirebaseAuth
                                              .instance.currentUser?.email ??
                                          "Sin correo",
                                      style: TextStyle(fontSize: 16.sp)))),
                          Expanded(
                              flex: 1,
                              child: IconButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.currentUser
                                        ?.reload();
                                    setState(() {});
                                    if (FirebaseAuth.instance.currentUser
                                            ?.emailVerified ==
                                        true) {
                                      showToast(
                                          "¡Correo verificado exitosamente!");
                                    } else {
                                      showToast(
                                          "El correo aún no ha sido verificado. Por favor verifica tu bandeja de entrada.");
                                    }
                                  },
                                  icon: Icon(Icons.refresh,
                                      size: 24.sp, color: ThemaMain.darkBlue)))
                        ]),
                        FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection("users")
                                .where("uuid",
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser?.uid)
                                .get(),
                            builder: (context, snapshot) {
                              return TextButton.icon(
                                  onPressed: () async {
                                    UsuarioModel? user;
                                    await showDialog(
                                        context: context,
                                        builder: (context) => DialogSend(
                                            cabeza:
                                                "Vincular con numero de empleado",
                                            fun: (valor) async {
                                              debugPrint(valor);
                                              showToast("Buscando..");
                                              var db =
                                                  FirebaseFirestore.instance;
                                              var data = await db
                                                  .collection("users")
                                                  .where("empleado_id",
                                                      isEqualTo: int.tryParse(
                                                          valor ?? "0"))
                                                  .get();
                                              user =
                                                  data.docs.firstOrNull == null
                                                      ? null
                                                      : UsuarioModel.fromJson(
                                                          data.docs.firstOrNull!
                                                              .data());
                                              debugPrint(
                                                  "${data.docs.map((e) => e.data()).toList()}");
                                            },
                                            tipoTeclado: TextInputType.number,
                                            fecha: null,
                                            entradaTexto: ""));
                                    if (user != null) {
                                      await Dialogs.showMorph(
                                          title: "Desea Enlazar Empleado",
                                          description:
                                              "Desea enlazar al empleado ${user!.nombre} con su cuenta electronica actual?",
                                          loadingTitle: "Enlazando empleado",
                                          onAcceptPressed: (context) async {
                                            var model = user!.copyWith(
                                                actualizacion: DateTime.now(),
                                                uuid: FirebaseAuth
                                                    .instance.currentUser?.uid);
                                            var db = FirebaseFirestore.instance;
                                            var data = await db
                                                .collection("users")
                                                .where("id",
                                                    isEqualTo: user!.id)
                                                .get();
                                            await db
                                                .collection("users")
                                                .doc(data.docs.first.id)
                                                .set(model.toJson());
                                            await FirebaseAuth
                                                .instance.currentUser
                                                ?.updateDisplayName(
                                                    user!.nombre);
                                            await FirebaseAuth
                                                .instance.currentUser
                                                ?.reload();
                                            setState(() {
                                              showToast(
                                                  "Vinculado a ${user!.nombre}");
                                            });
                                          });
                                    } else {
                                      showToast(
                                          "No se encontro ningun empleado con el numero proporcionado");
                                    }
                                  },
                                  icon: Icon(
                                      snapshot.hasData
                                          ? LineIcons.link
                                          : Icons.link,
                                      size: 24.sp,
                                      color: snapshot.hasData
                                          ? ThemaMain.green
                                          : ThemaMain.darkBlue),
                                  label: Text(
                                      "${snapshot.data?.docs.firstOrNull?.data()["empleado_id"] ?? "N. Empleado"}",
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: snapshot.hasData
                                              ? FontWeight.bold
                                              : FontWeight.normal)));
                            }),
                        ElevatedButton.icon(
                            onPressed: () async {
                              var accout = FirebaseAuth.instance.currentUser;
                              await Dialogs.showMorph(
                                  title: "Resetear contraseña",
                                  description:
                                      "Se esta intentando restablecer su contraseña de la cuenta ${accout?.email}",
                                  loadingTitle: "Restableciendo",
                                  onAcceptPressed: (context) async {
                                    try {
                                      await FirebaseAuth.instance
                                          .sendPasswordResetEmail(
                                              email: accout!.email!);
                                      showToast(
                                          "Se ha enviado un codigo de restablecimiento de su contraseña");
                                    } catch (e) {
                                      var tr =
                                          await TransFun.trad(e.toString());
                                      showToast(tr);
                                    }
                                  });
                            },
                            icon: Icon(LineIcons.alternateUnlock,
                                size: 24.sp, color: ThemaMain.primary),
                            label: Text('Resetear contraseña',
                                style: TextStyle(fontSize: 16.sp))),
                        ElevatedButton.icon(
                            onPressed: () async => Dialogs.showMorph(
                                title: "Cerrar sesión",
                                description: "¿Desea cerrar sesión?",
                                loadingTitle: "Cerrando sesión",
                                onAcceptPressed: (context) async {
                                  await FirebaseAuth.instance.signOut();
                                  Preferences.login = false;
                                  showToast("Sesión cerrada");
                                  await Navigation.pushNamedAndRemoveUntil(
                                      routeName: "loginState",
                                      predicate: (route) => false);
                                }),
                            icon: Icon(Icons.logout,
                                size: 22.sp, color: ThemaMain.red),
                            label: Text("Cerrar sesión",
                                style: TextStyle(
                                    fontSize: 16.sp, color: ThemaMain.red))),
                        Divider(),
                        Center(
                            child: ElevatedButton.icon(
                                onPressed: () async => Dialogs.showMorph(
                                    title: "Eliminar Cuenta",
                                    description: "¿Desea eliminar su cuenta?",
                                    loadingTitle: "Eliminando cuenta",
                                    onAcceptPressed: (context) async {
                                      var db = FirebaseFirestore.instance;
                                      var data = await db
                                          .collection("users")
                                          .where("uuid",
                                              isEqualTo: FirebaseAuth
                                                  .instance.currentUser?.uid)
                                          .get();
                                      if (data.docs.firstOrNull != null) {
                                        var user = (UsuarioModel.fromJson(
                                            data.docs.first.data()));
                                        await db
                                            .collection("users")
                                            .doc(data.docs.first.id)
                                            .update(
                                                user.toJson()..["uuid"] = null);
                                        await FirebaseAuth.instance.currentUser
                                            ?.reload();
                                        setState(() {
                                          showToast("Enlace eliminado");
                                        });
                                      }
                                      await FirebaseAuth.instance.currentUser
                                          ?.delete();

                                      Preferences.login = false;
                                      showToast("Cuenta eliminada");
                                      await Navigation.pushNamedAndRemoveUntil(
                                          routeName: "loginState",
                                          predicate: (route) => false);
                                    }),
                                icon: Icon(LineIcons.userSlash,
                                    size: 24.sp, color: ThemaMain.pink),
                                label: Text("Eliminar Cuenta",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: ThemaMain.pink))))
                      ])
                ])));
  }
}
