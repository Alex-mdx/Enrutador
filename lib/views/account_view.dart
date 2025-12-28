import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/views/dialogs/dialog_send.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart';
import 'package:sizer/sizer.dart';

import '../utilities/theme/theme_color.dart';

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
            title:
                Text('Cuenta de Usuario', style: TextStyle(fontSize: 18.sp))),
        body: Column(children: [
          Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                  padding: EdgeInsets.all(4.sp),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Image.network(
                                      FirebaseAuth
                                              .instance.currentUser?.photoURL ??
                                          "",
                                      width: 25.w,
                                      height: 25.w,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                              Icons.account_circle,
                                              size: 25.w,
                                              color: ThemaMain.yellow)))),
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
                                    TextButton.icon(
                                        onPressed: () => Dialogs.showMorph(
                                            title: "Autorizar correo",
                                            description:
                                                "¿Desea autorizar el correo de su cuenta?",
                                            loadingTitle: "Autorizando correo",
                                            onAcceptPressed: (context) async {
                                              await FirebaseAuth
                                                  .instance.currentUser
                                                  ?.sendEmailVerification();
                                              showToast(
                                                  "Correo de verificación enviado");
                                            }),
                                        icon: FirebaseAuth.instance.currentUser
                                                    ?.emailVerified ==
                                                false
                                            ? Icon(Icons.mark_email_unread,
                                                size: 22.sp,
                                                color: ThemaMain.yellow)
                                            : Icon(Icons.mark_email_read,
                                                size: 22.sp,
                                                color: ThemaMain.green),
                                        label: Text(
                                            FirebaseAuth.instance.currentUser
                                                    ?.email ??
                                                "Sin correo",
                                            style: TextStyle(fontSize: 16.sp))),
                                    TextButton.icon(
                                        onPressed: () => showDialog(
                                            context: context,
                                            builder: (context) => DialogSend(
                                                cabeza:
                                                    "Ingresar numero telefonico de la cuenta",
                                                fun: (value) async {
                                                  await FirebaseAuth.instance
                                                      .verifyPhoneNumber(
                                                    phoneNumber: value,
                                                    verificationCompleted:
                                                        (phoneAuthCredential) {},
                                                    verificationFailed:
                                                        (verificationFailure) {},
                                                    codeSent:
                                                        (verificationId, id) {},
                                                    codeAutoRetrievalTimeout:
                                                        (verificationId) {},
                                                  );
                                                  await FirebaseAuth
                                                      .instance.currentUser
                                                      ?.reload();
                                                  setState(() {});
                                                },
                                                lada: Preferences.lada,
                                                lenght: 10,
                                                tipoTeclado:
                                                    TextInputType.phone,
                                                fecha: null,
                                                entradaTexto: FirebaseAuth
                                                    .instance
                                                    .currentUser
                                                    ?.phoneNumber)),
                                        icon: Icon(Icons.phone,
                                            size: 22.sp,
                                            color: ThemaMain.primary),
                                        label: Text(
                                            FirebaseAuth.instance.currentUser
                                                    ?.phoneNumber ??
                                                "Sin número",
                                            style: TextStyle(fontSize: 16.sp)))
                                  ]))
                        ])
                      ])))
        ]));
  }
}
