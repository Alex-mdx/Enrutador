import 'dart:developer';
import 'package:dynamic_background/dynamic_background.dart';
import 'package:enrutador/controllers/usuario_controller.dart';
import 'package:enrutador/controllers/usuario_fire.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/utilities/trans_fun.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:sizer/sizer.dart';

import 'dialogs/dialog_politica_uso.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool show = true;

  bool carga = false;
  bool politica = [
    Preferences.camara,
    Preferences.ubicacion,
    Preferences.contactos
  ].every((element) => element = true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Login', style: TextStyle(fontSize: 18.sp))),
        body: DynamicBg(
            painterData: ScrollerPainterData(
                shape: ScrollerShape.circles,
                backgroundColor: ThemaMain.background,
                color: ThemaMain.primary,
                shapeOffset: ScrollerShapeOffset.shiftAndMesh),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Card(
                  margin: EdgeInsets.all(20),
                  child: Padding(
                      padding: EdgeInsets.all(12.sp),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: TextFormField(
                                    enabled: !carga,
                                    controller: email,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        fillColor: ThemaMain.background,
                                        labelText: 'Correo Electronico'))),
                            Padding(
                                padding: EdgeInsets.all(12.sp),
                                child: TextFormField(
                                    enabled: !carga,
                                    obscureText: show,
                                    controller: password,
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                        fillColor: ThemaMain.background,
                                        labelText: 'Password',
                                        suffixIcon: IconButton(
                                            onPressed: () =>
                                                setState(() => show = !show),
                                            icon: Icon(show
                                                ? Icons.visibility_off
                                                : Icons.visibility))))),
                            ElevatedButton.icon(
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        ThemaMain.dialogbackground)),
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => DialogPoliticaUso()),
                                label: Text("Aceptar politicas de uso",
                                    style: TextStyle(fontSize: 15.sp)),
                                icon: Icon(
                                    politica
                                        ? Icons.check_circle
                                        : Icons.check_box_outline_blank,
                                    size: 18.sp)),
                            Consumer<MainProvider>(
                                builder: (context, provider, child) =>
                                    ElevatedButton.icon(
                                        onPressed: () async {
                                          if (politica) {
                                            if (email.text.isNotEmpty &&
                                                password.text.isNotEmpty) {
                                              setState(() => carga = true);
                                              try {
                                                var user = await FirebaseAuth
                                                    .instance
                                                    .signInWithEmailAndPassword(
                                                        email: email.text,
                                                        password:
                                                            password.text);
                                                log("result: ${user.toString()}");
                                                await inLogin(user, provider);
                                                setState(() => carga = false);
                                              } catch (e) {
                                                setState(() => carga = false);
                                                var tr = await TransFun.trad(
                                                    e.toString());
                                                showToast(tr);
                                              }
                                            }
                                          } else {
                                            showToast(
                                                "Debes aceptar las politicas de uso");
                                          }
                                        },
                                        icon: carga
                                            ? RiveAnimatedIcon(
                                                riveIcon: RiveIcon.profile,
                                                color: ThemaMain.primary,
                                                strokeWidth: 6.w,
                                                height: 6.w,
                                                width: 6.w)
                                            : Icon(Icons.login,
                                                size: 22.sp,
                                                color: ThemaMain.primary),
                                        label: Text('Iniciar Sesion',
                                            style: TextStyle(fontSize: 16.sp))))
                          ]))),
              Consumer<MainProvider>(
                  builder: (context, provider, child) => ElevatedButton.icon(
                      onPressed: () async {
                        if (politica) {
                          if (email.text.isNotEmpty &&
                              password.text.isNotEmpty) {
                            setState(() => carga = true);
                            await Dialogs.showMorph(
                                    title: "Crear cuenta",
                                    description:
                                        "Se intento acceder con un usuario y contraseña inexistente\n¿Deseas crear una cuenta y acceder a la aplicacion con estos datos?",
                                    loadingTitle: "Creando",
                                    onAcceptPressed: (context) async {
                                      var result = await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                              email: email.text,
                                              password: password.text);
                                      log(result.toString());
                                      try {
                                        if (result.user != null) {
                                          showToast(
                                              "Cuenta creada exitosamente");
                                          var user = await FirebaseAuth.instance
                                              .signInWithEmailAndPassword(
                                                  email: email.text,
                                                  password: password.text);
                                          log("result: ${user.toString()}");
                                          await inLogin(user, provider);
                                        }
                                      } catch (e) {
                                        var tr =
                                            await TransFun.trad(e.toString());
                                        showToast(tr);
                                      }
                                    })
                                .whenComplete(
                                    () => setState(() => carga = false));
                          } else {
                            showToast(
                                "Ingrese ${email.text.isEmpty ? "Correo electronico en su respectivo campo" : ""}${email.text.isEmpty && password.text.isEmpty ? " y " : ""}${password.text.isEmpty ? "Contraseña en su respectivo campo" : ""}");
                          }
                        } else {
                          showToast("Debes aceptar las politicas de uso");
                        }
                      },
                      icon: Icon(LineIcons.userPlus,
                          size: 22.sp, color: ThemaMain.green),
                      label: Text('Registrar cuenta',
                          style: TextStyle(fontSize: 16.sp)))),
              ElevatedButton.icon(
                  onPressed: () async {
                    if (email.text.isNotEmpty && password.text.isEmpty) {
                      setState(() => carga = true);
                      await Dialogs.showMorph(
                          title: "Resetear contraseña",
                          description:
                              "Se esta intentando restablecer su contraseña de la cuenta ${email.text}",
                          loadingTitle: "Restableciendo",
                          onAcceptPressed: (context) async {
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: email.text);
                              showToast(
                                  "Se ha enviado un codigo de restablecimiento de su contraseña");
                            } catch (e) {
                              var tr = await TransFun.trad(e.toString());
                              showToast(tr);
                            }
                          }).whenComplete(() => setState(() => carga = false));
                    } else {
                      showToast(
                          "${email.text.isEmpty ? "Ingrese correo electronico en su respectivo campo" : ""}${email.text.isEmpty && password.text.isNotEmpty ? " y " : ""}${password.text.isNotEmpty ? "Deje vacio el campo de contraseña" : ""}");
                    }
                  },
                  icon: Icon(LineIcons.alternateUnlock,
                      size: 22.sp, color: ThemaMain.primary),
                  label: Text('Resetear contraseña',
                      style: TextStyle(fontSize: 16.sp))),
              Consumer<MainProvider>(
                builder: (context, provider, child) => SignInButton(
                    Buttons.google,
                    text: "Entrar con Google",
                    textStyle: TextStyle(fontSize: 16.sp), onPressed: () async {
                  try {
                    setState(() => carga = true);
                    if (politica) {
                      if (GoogleSignIn.instance.supportsAuthenticate()) {
                        var auth = await GoogleSignIn.instance.authenticate();
                        if (auth.authentication.idToken != null) {
                          // Usar GoogleAuthProvider.credential para obtener la credencial correcta
                          AuthCredential cred = GoogleAuthProvider.credential(
                              idToken: auth.authentication.idToken);
                          var user = await FirebaseAuth.instance
                              .signInWithCredential(cred);
                          await inLogin(user, provider);
                        }
                      } else {
                        showToast("Debes aceptar las politicas de uso");
                      }
                    }
                  } catch (e) {
                    setState(() => carga = false);
                    debugPrint(e.toString());
                    var tr = await TransFun.trad(e.toString());
                    showToast(tr);
                  }
                }),
              )
            ])));
  }

  Future<void> inLogin(UserCredential user, MainProvider provider) async {
    if (user.user != null) {
      Preferences.login = true;
      showToast("Autenticación exitosa");
      var uservalid =
          await UsuarioFire.getItem(table: "uuid", query: "${user.user?.uid}");
      log("valid: ${uservalid?.toJson()}");
      if (uservalid != null) {
        log("${uservalid.toJson()}");
        await UsuarioController.insert(uservalid);
        provider.usuario = uservalid;
      }
      if (user.user!.emailVerified) {
        await Navigation.pushNamed(route: "home");
      } else {
        await Navigation.pushNamed(route: "account");
      }
    }
  }
}
