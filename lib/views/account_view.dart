import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/views/dialogs/dialog_send.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import '../models/usuario_model.dart';
import '../utilities/camara_fun.dart';
import '../utilities/theme/theme_color.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  @override
  void initState() {
    super.initState();
    // Recargar el estado del usuario cuando se abre esta vista
    _reloadUser();
  }

  /// Recarga el estado del usuario desde Firebase
  Future<void> _reloadUser() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      log("Error al recargar usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Cuenta de Usuario', style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton(
                  onPressed: () async {
                    try {
                      // Obtener el usuario actual
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser == null) {
                        showToast("No hay usuario autenticado");
                        return;
                      }

                      var model = UsuarioModel(
                          id: 1,
                          uuid: currentUser.uid, // Usar el UID del usuario
                          nombre: currentUser.displayName,
                          contactoId: null,
                          empleadoId: 10022990,
                          adminTipo: 1,
                          status: 1,
                          creacion: DateTime.now(),
                          actualizacion: DateTime.now());

                      final db = FirebaseFirestore.instance;
                      // Usar el UID como ID del documento para que cada usuario tenga su propio documento
                      var coll = await db
                          .collection('users')
                          .where("id", isEqualTo: 1)
                          .get();

                      await db
                          .collection('users')
                          .doc(coll.docs.first.id)
                          .set(model.toJson());

                      showToast("Usuario guardado correctamente");
                    } catch (e) {
                      showToast("Error al guardar usuario: $e");
                      log("Error completo: $e");
                    }
                  },
                  icon: Icon(Icons.vaccines, color: ThemaMain.darkBlue))
            ]),
        body: Column(children: [
          Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                  padding: EdgeInsets.all(4.sp),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: InkWell(
                                      onTap: () async {
                                        var imagen =
                                            await CamaraFun.getGalleria(
                                                context, "Foto de perfil");
                                        try {
                                          if (imagen.isNotEmpty) {
                                            var bytes = await imagen.first
                                                .readAsBytes();
                                            var file = await CamaraFun.imagen(
                                                nombre: "imagen",
                                                imagenBytes: bytes);
                                            if (file != null) {
                                              await FirebaseAuth
                                                  .instance.currentUser
                                                  ?.updatePhotoURL(file.path);
                                              await FirebaseAuth
                                                  .instance.currentUser
                                                  ?.reload();
                                              showToast(
                                                  "Foto de perfil actualizada");
                                            }
                                          }
                                        } catch (e) {
                                          showToast("Error $e");
                                        }

                                        setState(() {});
                                      },
                                      child: Image.network(
                                          FirebaseAuth.instance.currentUser
                                                  ?.photoURL ??
                                              "",
                                          width: 25.w,
                                          height: 25.w,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              Icon(Icons.account_circle,
                                                  size: 25.w,
                                                  color: ThemaMain.yellow))))),
                          VerticalDivider(),
                          Expanded(
                              flex: 3,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextButton.icon(
                                        onPressed: () => showDialog(
                                            context: context,
                                            builder: (context) => DialogSend(
                                                cabeza:
                                                    "Ingresar nombre de cuenta",
                                                fun: (value) async {
                                                  await FirebaseAuth
                                                      .instance.currentUser
                                                      ?.updateDisplayName(
                                                          value);
                                                  showToast(
                                                      "Nombre de la cuenta actualizada");
                                                  await FirebaseAuth
                                                      .instance.currentUser
                                                      ?.reload();
                                                  setState(() {});
                                                },
                                                tipoTeclado: TextInputType.name,
                                                fecha: null,
                                                entradaTexto: FirebaseAuth
                                                    .instance
                                                    .currentUser
                                                    ?.displayName)),
                                        icon: Icon(Icons.person,
                                            size: 22.sp,
                                            color: ThemaMain.darkBlue),
                                        label: Text(
                                            FirebaseAuth.instance.currentUser
                                                    ?.displayName ??
                                                "Sin nombre",
                                            style: TextStyle(fontSize: 16.sp))),
                                    Row(children: [
                                      Expanded(
                                          flex: 5,
                                          child: TextButton.icon(
                                              onPressed: FirebaseAuth
                                                          .instance
                                                          .currentUser
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
                                                      loadingTitle:
                                                          "Autorizando correo",
                                                      onAcceptPressed:
                                                          (context) async {
                                                        try {
                                                          await FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              ?.sendEmailVerification();

                                                          showToast(
                                                              "Correo de verificación enviado. Por favor revisa tu bandeja de entrada.");
                                                        } catch (e) {
                                                          showToast(
                                                              "Error al enviar correo: $e");
                                                          log("Error al enviar verificación: $e");
                                                        }
                                                      }),
                                              icon: FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          ?.emailVerified ==
                                                      false
                                                  ? Icon(
                                                      Icons.mark_email_unread,
                                                      size: 22.sp,
                                                      color: ThemaMain.yellow)
                                                  : Icon(Icons.mark_email_read,
                                                      size: 22.sp,
                                                      color: ThemaMain.green),
                                              label: Text(
                                                  FirebaseAuth.instance
                                                          .currentUser?.email ??
                                                      "Sin correo",
                                                  style: TextStyle(fontSize: 16.sp)))),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                            onPressed: () async {
                                              await _reloadUser();
                                              if (FirebaseAuth
                                                      .instance
                                                      .currentUser
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
                                                size: 22.sp,
                                                color: ThemaMain.darkBlue)),
                                      )
                                    ]),
                                    TextButton.icon(
                                        onPressed: () {},
                                        icon: Icon(Icons.link,
                                            size: 22.sp,
                                            color: ThemaMain.darkBlue),
                                        label: Text("N. Empleado",
                                            style: TextStyle(fontSize: 16.sp))),
                                    ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: Icon(Icons.logout,
                                            size: 22.sp, color: ThemaMain.red),
                                        label: Text("Cerrar sesión",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                color: ThemaMain.red))),
                                  ]))
                        ])
                      ])))
        ]));
  }
}
