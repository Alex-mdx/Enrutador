import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/controllers/usuario_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../controllers/fireController/usuario_fire.dart';
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
  Future<void> name(String nombre) async {
    var doc = await UsuarioFire.getItem(
        table: "uuid", query: FirebaseAuth.instance.currentUser?.uid ?? "");
    if (doc == null) return;
    var model = doc.copyWith(nombre: nombre, actualizacion: DateTime.now());

    var actualizado = await UsuarioFire.sendItem(data: model);
    if (actualizado) {
      await UsuarioController.insert(model);
    }
    await FirebaseAuth.instance.currentUser?.updateDisplayName(nombre);
    await FirebaseAuth.instance.currentUser?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
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
                                      await name(value ?? "");
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
                                        width: 12.w,
                                        height: 12.w,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(Icons.account_circle,
                                                    size: 12.w,
                                                    color: ThemaMain.yellow)))
                                : Icon(Icons.person,
                                    size: 12.w, color: ThemaMain.darkBlue),
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
                                    var contacto = await UsuarioFire.getItem(
                                        table: "uuid",
                                        query:
                                            "${FirebaseAuth.instance.currentUser?.uid}");
                                    if (contacto != null) {
                                      await UsuarioController.insert(contacto);
                                      provider.usuario = contacto;
                                    }

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
                            future: UsuarioFire.getItem(
                                table: "uuid",
                                query: FirebaseAuth.instance.currentUser?.uid ??
                                    ""),
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
                                              showToast("Buscando..");
                                              user = await UsuarioFire.getItem(
                                                  table: "empleado_id",
                                                  query: valor ?? "0");
                                            },
                                            tipoTeclado: TextInputType.number,
                                            fecha: null,
                                            entradaTexto: ""));
                                    log(user?.toJson().toString() ?? "");
                                    if (user != null &&
                                        (user?.uuid == null ||
                                            user?.uuid ==
                                                FirebaseAuth.instance
                                                    .currentUser?.uid)) {
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

                                            await UsuarioFire.sendItem(
                                                data: model,
                                                table: "id",
                                                query: user?.id.toString(),
                                                itsNumber: true);
                                            await UsuarioController.insert(
                                                model);
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
                                      if (user?.uuid != null) {
                                        showToast(
                                            "El empleado ${user!.nombre}, ya esta asignado a un empleado diferente");
                                      } else {
                                        showToast(
                                            "No se encontro ningun empleado con el numero proporcionado");
                                      }
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
                                      snapshot.data?.empleadoId ??
                                          "N. Empleado",
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
                                  await UsuarioController.deleteAll();
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
                        Center(
                            child: ElevatedButton.icon(
                                onPressed: () async {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user == null) return;
                                  UserCredential? temp;
                                  await showDialog(
                                      context: context,
                                      builder: (context) => DialogSend(
                                          cabeza:
                                              "Eliminar Cuenta\nEsta accion es irreversible. Ingresa tu contrasena para confirmar.",
                                          fun: (p0) async {
                                            // Re-autenticar antes de eliminar
                                            final credential =
                                                EmailAuthProvider.credential(
                                                    email: user.email!,
                                                    password: p0 ?? "");

                                            temp = await user
                                                .reauthenticateWithCredential(
                                                    credential);
                                          },
                                          tipoTeclado:
                                              TextInputType.visiblePassword,
                                          fecha: null,
                                          entradaTexto: null));

                                  if (temp?.user == null) return;

                                  await Dialogs.showMorph(
                                      title: "Eliminando cuenta",
                                      description:
                                          "Procesando la eliminacion de su cuenta...",
                                      loadingTitle: "Eliminando cuenta",
                                      onAcceptPressed: (context) async {
                                        try {
                                          if (temp?.user != null) {
                                            var db = FirebaseFirestore.instance;
                                            await UsuarioController.deleteAll();
                                            var data = await db
                                                .collection("users")
                                                .where("uuid",
                                                    isEqualTo: user.uid)
                                                .get();

                                            if (data.docs.firstOrNull != null) {
                                              var userModel =
                                                  UsuarioModel.fromJson(
                                                      data.docs.first.data());
                                              await db
                                                  .collection("users")
                                                  .doc(data.docs.first.id)
                                                  .update(userModel.toJson()
                                                    ..["uuid"] = null);
                                            }

                                            await user.delete();
                                            Preferences.login = false;
                                            showToast("Cuenta eliminada");
                                            await Navigation
                                                .pushReplacementNamed(
                                                    routeName: "loginState");
                                          }
                                        } on FirebaseAuthException catch (e) {
                                          if (e.code == 'wrong-password') {
                                            showToast(
                                                "Contrasena incorrecta. Intenta de nuevo.");
                                          } else {
                                            showToast(
                                                "Error al eliminar cuenta: ${e.message}");
                                          }
                                          log("FirebaseAuthException al eliminar cuenta: $e");
                                        } catch (e) {
                                          showToast("Error inesperado: $e");
                                          log("Error al eliminar cuenta: $e");
                                        }
                                      });
                                },
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
