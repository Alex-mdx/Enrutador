import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import '../models/usuario_model.dart';
import '../utilities/services/navigation_services.dart';
import '../utilities/theme/theme_color.dart';
import 'widgets/card_accout.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Cuenta de Usuario', style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton(
                  onPressed: () async {
                    try {
                    

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
                        onPressed: () async {
                          if (FirebaseAuth
                                      .instance.currentUser!.emailVerified ==
                                  true &&
                              snapshot.data?.docs.firstOrNull
                                      ?.data()["empleado_id"] !=
                                  null) {
                            Preferences.login = true;
                            await Navigation.pushNamed(route: "home");
                          }
                        },
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
