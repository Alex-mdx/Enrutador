import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class DialogsComunicar extends StatelessWidget {
  final String number;
  const DialogsComunicar({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text("Opciones de comunicacion",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Card(
            child: Column(children: [
          IconButton(
              onPressed: () async {
                final link = WhatsAppUnilink(phoneNumber: number);
                await launchUrl(link.asUri(),
                    mode: LaunchMode.externalNonBrowserApplication);
              },
              icon: Icon(LineIcons.whatSApp,
                  size: 42.sp, color: ThemaMain.green)),
          Text("Whatsapp",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))
        ])),
        Card(
            child: Column(children: [
          IconButton(
              onPressed: () async {
                var res = await FlutterPhoneDirectCaller.callNumber("+$number");
                if (res != true) {
                  showToast("No se pudo ejecutar la llamada");
                }
              },
              icon: Icon(LineIcons.phoneVolume,
                  size: 42.sp, color: ThemaMain.primary)),
          Text("Llamar",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))
        ]))
      ])
    ]));
  }
}
