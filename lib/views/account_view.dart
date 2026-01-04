import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import '../models/usuario_model.dart';
import '../utilities/theme/theme_color.dart';
import 'widgets/card_accout.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  List<UsuarioModel> usuarios = [
    UsuarioModel(
        id: 1,
        uuid: null,
        nombre: 'Martha patricia Tun',
        contactoId: null,
        empleadoId: 10020395,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 2,
        uuid: null,
        nombre: 'Maribel Ake',
        contactoId: null,
        empleadoId: 10016280,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 3,
        uuid: null,
        nombre: 'Maria Esther Rodriguez',
        contactoId: null,
        empleadoId: 10020441,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 4,
        uuid: null,
        nombre: 'Erick Daniel Huchin',
        contactoId: null,
        empleadoId: 10023726,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 5,
        uuid: null,
        nombre: 'Jose Gerardo Esteban Castro',
        contactoId: null,
        empleadoId: 10010357,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 6,
        uuid: null,
        nombre: 'Rommel Yahir Garcia',
        contactoId: null,
        empleadoId: 10017701,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 7,
        uuid: null,
        nombre: 'Dianele Yaquelin Gutierrez',
        contactoId: null,
        empleadoId: 10022228,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 8,
        uuid: null,
        nombre: 'Astrid Montserrat Canul',
        contactoId: null,
        empleadoId: 10022872,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 9,
        uuid: null,
        nombre: 'Wendy Misolha Angulo',
        contactoId: null,
        empleadoId: 10023528,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 10,
        uuid: null,
        nombre: 'Cesar Andres Sandoval',
        contactoId: null,
        empleadoId: 10018890,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 11,
        uuid: null,
        nombre: 'Jose Gabino Magaña',
        contactoId: null,
        empleadoId: 10020717,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 12,
        uuid: null,
        nombre: 'Alexis Armando De Jesus Castro',
        contactoId: null,
        empleadoId: 10022990,
        adminTipo: 0,
        status: 5,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 13,
        uuid: null,
        nombre: 'Perla De La Cruz',
        contactoId: null,
        empleadoId: 10023514,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 14,
        uuid: null,
        nombre: 'Antonio De Jesus Moya',
        contactoId: null,
        empleadoId: 10023518,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now()),
    UsuarioModel(
        id: 15,
        uuid: null,
        nombre: 'Moises Ernesto Angulo',
        contactoId: null,
        empleadoId: 10023803,
        adminTipo: 1,
        status: 1,
        creacion: DateTime.now(),
        actualizacion: DateTime.now())
  ];

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
                      if (currentUser?.emailVerified == false) {
                        showToast("Usuario no verificado");
                        return;
                      }
                      for (var element in usuarios) {
                        var model = element.copyWith(
                            creacion: DateTime.now(),
                            actualizacion: DateTime.now());
                        final db = FirebaseFirestore.instance;
                        var rdm = Textos.randomWord(30);
                        await db
                            .collection('users')
                            .doc(rdm)
                            .set(model.toJson());
                      }

                      showToast("Usuario guardado correctamente");
                    } catch (e) {
                      showToast("Error al guardar usuario: $e");
                      log("Error completo: $e");
                    }
                  },
                  icon: Icon(Icons.vaccines, color: ThemaMain.darkBlue))
            ]),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RefreshIndicator(
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: CardAccout())),
                  onRefresh: () async {}),
              FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .where("uuid",
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .get(),
                  builder: (context, snapshot) {
                    return ElevatedButton.icon(
                        iconAlignment: IconAlignment.end,
                        onPressed: () {},
                        icon: Icon(Icons.navigate_next,
                            size: 20.sp,
                            color: FirebaseAuth.instance.currentUser!.emailVerified == true &&
                                    snapshot.data?.docs.firstOrNull?.data()["empleado_id"] !=
                                        null
                                ? ThemaMain.darkBlue
                                : ThemaMain.yellow),
                        label: Text(
                            FirebaseAuth.instance.currentUser!.emailVerified == true &&
                                    snapshot.data?.docs.firstOrNull?.data()["empleado_id"] !=
                                        null
                                ? "Pantalla Principal"
                                : FirebaseAuth.instance.currentUser!.emailVerified ==
                                        false
                                    ? "Verifique su Cuenta"
                                    : snapshot.data?.docs.firstOrNull
                                                ?.data()["empleado_id"] !=
                                            null
                                        ? "Enlace a su Cuenta a un numero de empleado"
                                        : "",
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FirebaseAuth.instance.currentUser!.emailVerified == true &&
                                        snapshot.data?.docs.firstOrNull?.data()["empleado_id"] != null
                                    ? FontWeight.bold
                                    : FontWeight.normal)));
                  })
            ]));
  }
}
