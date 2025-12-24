import 'package:dynamic_background/dynamic_background.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/utilities/trans_fun.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login', style: TextStyle(fontSize: 18.sp)),
        ),
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
                            TextFormField(
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
                                            : Icons.visibility)))),
                            ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    setState(() => carga = true);
                                    var result = await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                            email: email.text,
                                            password: password.text);
                                    debugPrint(result.toString());
                                  } catch (e) {
                                    setState(() => carga = false);
                                    var tr = await TransFun.trad(e.toString());
                                    showToast(tr);
                                  }
                                },
                                icon: !carga
                                    ? RiveAnimatedIcon(
                                        riveIcon: RiveIcon.profile,
                                        color: ThemaMain.primary,
                                        strokeWidth: 2.w,
                                        onTap: () {})
                                    : Icon(Icons.login,
                                        size: 22.sp, color: ThemaMain.primary),
                                label: Text('Iniciar Sesion',
                                    style: TextStyle(fontSize: 16.sp)))
                          ]))),
              if (kDebugMode)
                ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await GoogleSignIn.instance.authenticate();
                      } catch (e) {
                        debugPrint(e.toString());
                        var tr = await TransFun.trad(e.toString());
                        showToast(tr);
                      }
                    },
                    icon: Icon(LineIcons.googleLogo,
                        size: 22.sp, color: ThemaMain.green),
                    label: Text('Entrar con Google',
                        style: TextStyle(fontSize: 16.sp)))
            ])));
  }
}
