import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'widgets/card_contacto_widget.dart';

class ContactosView extends StatefulWidget {
  const ContactosView({super.key});

  @override
  State<ContactosView> createState() => _ContactosViewState();
}

class _ContactosViewState extends State<ContactosView> {
  TextEditingController buscador = TextEditingController();
  List<bool> selects = [];
  bool carga = false;
  List<ContactoModelo> contactos = [];
  @override
  void initState() {
    super.initState();
    send();
  }

  Future<void> send() async {
    setState(() {
      carga = false;
    });
    selects = [];
    contactos = await ContactoController.getItemsAll(nombre: buscador.text);
    selects.addAll(contactos.map((e) => false).toList());
    setState(() {
      carga = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Contactos", style: TextStyle(fontSize: 18.sp)),
            actions: [
              OverflowBar(spacing: 1.w, children: [
                ElevatedButton.icon(
                    onPressed: () {},
                    label:
                        Text("Enviar todo", style: TextStyle(fontSize: 14.sp)),
                    icon: Icon(Icons.done_all,
                        color: ThemaMain.primary, size: 20.sp)),
                if (selects.any((element) => element == true))
                  ElevatedButton(
                      onPressed: () async {
                        List<ContactoModelo> contactosTemp = [];
                        for (var i = 0; i < selects.length; i++) {
                          if (selects[i]) {
                            contactosTemp.add(contactos[i]);
                          }
                        }
                        var archivo = await ShareFun.shareDatas(
                            nombre: "contactos", datas: contactosTemp);
                        if (archivo != null) {
                          await ShareFun.share(
                              titulo:
                                  "Este es un contenido compacto de contactos",
                              mensaje: "objeto de contactos",
                              files: [XFile(archivo.path)]);
                        }
                      },
                      child: Text(
                          "Enviar (${selects.where((element) => element == true).length})",
                          style: TextStyle(fontSize: 14.sp)))
              ])
            ]),
        body: Column(children: [
          Padding(
              padding: EdgeInsets.all(10.sp),
              child: TextFormField(
                  controller: buscador,
                  enabled: carga,
                  onEditingComplete: () async => await send(),
                  style: TextStyle(fontSize: 18.sp),
                  decoration: InputDecoration(
                      fillColor: ThemaMain.second,
                      label: Text(
                          "Nombre | PlusCode | Telefono(s)${kDebugMode ? " | What3Word" : ""}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16.sp,
                              color: ThemaMain.darkGrey)),
                      suffixIcon: IconButton.filledTonal(
                          iconSize: 22.sp,
                          onPressed: () async => await send(),
                          icon: Icon(Icons.youtube_searched_for,
                              color: ThemaMain.green)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 1.h)))),
          !carga
              ? Center(child: CircularProgressIndicator())
              : contactos.isEmpty
                  ? Center(
                      child: Text("No se ha ingresado ningun contacto",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: contactos.length,
                      itemBuilder: (context, index) {
                        ContactoModelo contacto = contactos[index];
                        return CardContactoWidget(
                            contacto: contacto,
                            funContact: (p0) {},
                            onSelected: (p0) => setState(() {
                                  selects[index] = !selects[index];
                                }),
                            compartir: true,
                            selected: selects[index],
                            selectedVisible: true);
                      })
        ]));
  }
}
