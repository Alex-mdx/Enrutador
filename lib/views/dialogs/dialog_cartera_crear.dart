import 'package:enrutador/models/cartera_model.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/extras/pin_widget.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/services/navigation_services.dart';
import '../widgets/extras/card_user_select.dart';

class DialogCarteraCrear extends StatefulWidget {
  final CarteraModel? cartera;
  final List<String> addContactos;
  const DialogCarteraCrear(
      {super.key, required this.addContactos, this.cartera});

  @override
  State<DialogCarteraCrear> createState() => _DialogCarteraCrearState();
}

class _DialogCarteraCrearState extends State<DialogCarteraCrear> {
  final TextEditingController _passwordController = TextEditingController();
  String? empleadoAsingado;
  bool fisico = false;

  bool charge = false;

  @override
  void initState() {
    super.initState();
    if (widget.cartera != null) {
      empleadoAsingado = widget.cartera!.empleadoTo;
      _passwordController.text = widget.cartera!.codigo.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(
          title:
              Text("${widget.cartera != null ? "Editar" : "Crear"} Cartera")),
      Text("Has ingresado ${widget.addContactos.length} contacto(s)",
          style: TextStyle(fontSize: 16.sp)),
      Divider(),
      SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                  style: ButtonStyle(
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 0))),
                  icon: Icon(Icons.person, size: 20.sp),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => Dialog(
                          child: CardUserSelect(
                              empleadoSelected: empleadoAsingado,
                              onTap: (e) {
                                setState(() {
                                  empleadoAsingado = e.empleadoId;
                                });
                                Navigation.pop();
                              },
                              onlyOwn: true))),
                  label: Text("Asignar: ${empleadoAsingado ?? "Sin asignar"}",
                      style: TextStyle(fontSize: 14.sp))),
              Expanded(
                child: CheckboxListTile.adaptive(
                    tileColor: ThemaMain.second,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 1.w, vertical: 0),
                    dense: true,
                    value: fisico,
                    onChanged: (value) =>
                        setState(() => fisico = value ?? false),
                    title: Text("Fisico",
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "Se generara un archivo fisico con la cartera ingresada para compartir",
                        style: TextStyle(fontSize: 14.sp))),
              )
            ]),
        Text("Ingrese una contraseña de seguridad para proteger su cartera",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        TextButton.icon(
            onPressed: () {
              setState(() {
                String nPassword = Textos.randomWord(5, onlyNumbers: true);
                _passwordController.text = nPassword;
                showToast(
                    "Se genero una contraseña de seguridad para su cartera");
              });
            },
            icon: Icon(LineIcons.random, size: 18.sp),
            label: Text("Generar contraseña aleatoria",
                style: TextStyle(fontSize: 15.sp))),
        Card(
            child: PinWidget(
                textController: _passwordController,
                pin: _passwordController.text,
                lenght: 5,
                onCompleted: (p0) {}))
      ])),
      ElevatedButton.icon(
          onPressed: () {},
          label: Text("Aceptar ${widget.cartera != null ? "Cambios" : ""}",
              style: TextStyle(fontSize: 16.sp)),
          icon:
              Icon(LineIcons.doubleCheck, size: 18.sp, color: ThemaMain.green))
    ]));
  }
}
