import 'package:enrutador/views/dialogs/dialog_send.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:sizer/sizer.dart';
import '../../../utilities/number_fun.dart';
import '../../../utilities/theme/theme_color.dart';
import '../../dialogs/dialogs_comunicar.dart';

class TarjetaContactoCall extends StatelessWidget {
  final String? number;
  final DateTime? fechaNum;
  final bool compartir;
  final String mensaje;
  final String entradaTexto;
  final IconAlignment? iconAlignment;
  final Function(String)? fun;
  const TarjetaContactoCall(
      {super.key,
      required this.number,
      required this.fechaNum,
      required this.compartir,
      required this.mensaje,
      required this.entradaTexto,
      this.iconAlignment,
      this.fun});

  @override
  Widget build(BuildContext context) {
    if (!compartir) {
      return ElevatedButton.icon(
          style: ButtonStyle(
              padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 0, horizontal: .5.w))),
          iconAlignment: iconAlignment ?? IconAlignment.end,
          onLongPress: () async {
            await Clipboard.setData(
                ClipboardData(text: number ?? "Sin numero"));
            showToast("$mensaje copiado");
          },
          onPressed: () {
            String? lada = NumberFun.onlyLada(number);
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => DialogSend(
                    lenght: 10,
                    lada: lada == null ? null : "+$lada",
                    entradaTexto: number == null
                        ? null
                        : NumberFun.formatNumber(number!).removeAllWhitespace,
                    fun: (p0) async {
                      if (fun != null) {
                        fun!(p0!);
                      }
                    },
                    tipoTeclado: TextInputType.phone,
                    fecha: fechaNum,
                    cabeza: entradaTexto));
          },
          label: Text("$mensaje\n${NumberFun.formatNumber(number ?? "0")}",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
          icon: PhoneNumber.findPotentialPhoneNumbers(
                          (number ?? "0").toString())
                      .firstOrNull
                      ?.isValid(type: PhoneNumberType.mobile) ??
                  false
              ? GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) =>
                          DialogsComunicar(number: number!)),
                  child: Stack(alignment: Alignment.center, children: [
                    Icon(Icons.circle, size: 25.sp, color: ThemaMain.green),
                    Icon(LineIcons.tty, size: 23.sp, color: ThemaMain.second)
                  ]))
              : null);
    } else {
      return Text("$mensaje\n${NumberFun.formatNumber(number ?? "0")}",
          style: TextStyle(fontSize: 14.sp));
    }
  }
}
