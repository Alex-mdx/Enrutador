import 'dart:developer';
import 'dart:ffi';

import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/cartera_model.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/extras/pin_widget.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../controllers/referencias_controller.dart';
import '../../models/referencia_model.dart';
import '../../utilities/main_provider.dart';
import '../../utilities/services/navigation_services.dart';
import '../widgets/extras/card_user_select.dart';

class DialogCarteraCrear extends StatefulWidget {
  final CarteraModel? cartera;
  final List<String> addContactos;
  final List<ContactoModelo> contacts;
  const DialogCarteraCrear(
      {super.key,
      required this.addContactos,
      this.cartera,
      this.contacts = const []});

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
    final provider = Provider.of<MainProvider>(context);
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
        CheckboxListTile.adaptive(
            tileColor: ThemaMain.second,
            contentPadding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0),
            dense: true,
            value: fisico,
            onChanged: (value) => setState(() => fisico = value ?? false),
            title: Text("Fisico",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            subtitle: Text(
                "Se generara un archivo fisico de la cartera con los contactos para. (Recomendado cuando el contacto seleccionado solo existe en su dispositivo)",
                style: TextStyle(fontSize: 14.sp))),
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
                onCompleted: (p0) {})),
        Text(
            "Si no coloca una contraseña, aquellos que puedan ver su cartera podran acceder a ella y sus contactos, sin restricciones",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, fontStyle: FontStyle.italic)),
      ])),
      ElevatedButton.icon(
          onPressed: () async {
            if (empleadoAsingado == null) {
              showToast("Asigne un empleado");
              return;
            }
            if (_passwordController.text.isEmpty) {
              showToast("Ingrese una contraseña");
              return;
            }
            if (_passwordController.text.length != 5) {
              showToast("La contraseña debe tener 5 digitos");
              return;
            }
            setState(() {
              charge = true;
            });
            try {
              List<ContactoModelo> cTemp = [];
              List<ReferenciaModelo> refs = [];
              if (widget.contacts.isEmpty) {
                for (var element in widget.addContactos) {
                  var idCont = int.parse(element.split("-")[0]);
                  var empleadoId = element.split("-")[1];
                  var a = await ContactoController.getItemId(
                      id: idCont, empleadoId: empleadoId);
                  if (a != null) {
                    var refsTemp = await ReferenciasController.getIdPrin(
                        idContacto: a.id!, lat: a.latitud, lng: a.longitud);
                    refs.addAll(refsTemp);
                    log("referencia ${refs.length}");
                    cTemp.add(a);
                    List<ContactoModelo> ntemp = [];
                    for (var ref in refsTemp) {
                      var cTemp = await ContactoController.getItemId(
                          id: ref.idRForenea!);
                      if (cTemp != null) {
                        ntemp.add(cTemp);
                      }
                    }
                    cTemp.addAll(ntemp);
                  }
                }
              }
              var uuidTemp = widget.cartera?.uuid ?? Textos.randomWord(6);
              var carteraTemp = CarteraModel(
                  codigo: int.parse(_passwordController.text),
                  empleadoTo: empleadoAsingado!,
                  contactos: widget.addContactos,
                  activo: 0,
                  empleadoBy: provider.usuario!.empleadoId!,
                  fechaActualizado: DateTime.now(),
                  fechaCreado: widget.cartera?.fechaCreado ?? DateTime.now(),
                  uuid: uuidTemp);
              if (fisico) {
                await ShareFun.shareDatas(
                    datas: [cTemp, carteraTemp],
                    nombre: "Cartera_$uuidTemp",
                    nombres: ["contactos", "cartera"]);
              }

              ///await ShareFun.shareDatas(datas: datas,)
            } catch (e) {
              showToast("Error al crear cartera");
              setState(() {
                charge = false;
              });
            }
          },
          label: Text("Aceptar ${widget.cartera != null ? "Cambios" : ""}",
              style: TextStyle(fontSize: 16.sp)),
          icon: charge
              ? CircularProgressIndicator.adaptive()
              : Icon(
                  widget.cartera != null
                      ? LineIcons.pen
                      : LineIcons.doubleCheck,
                  size: 18.sp,
                  color: ThemaMain.green))
    ]));
  }
}
