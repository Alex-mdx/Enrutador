import 'package:enrutador/controllers/tipo_controller.dart';
import 'package:enrutador/models/tipos_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'dialogs/dialogs_tipos.dart';
import 'widgets/list_tipo_widget.dart';

class TiposView extends StatefulWidget {
  const TiposView({super.key});

  @override
  State<TiposView> createState() => _TiposViewState();
}

class _TiposViewState extends State<TiposView> {
  List<bool> selects = [];
  bool carga = false;
  List<TiposModelo> contactos = [];
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
    contactos = await TipoController.getItems();
    selects.addAll(contactos.map((e) => false).toList());
    setState(() {
      carga = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async =>
          provider.tipos = await TipoController.getItems(),
      child: Scaffold(
          appBar: AppBar(
              title: Text("Tipos", style: TextStyle(fontSize: 18.sp)),
              actions: [
                ElevatedButton.icon(
                    onPressed: () {},
                    label:
                        Text("Enviar todo", style: TextStyle(fontSize: 14.sp)),
                    icon: Icon(Icons.done_all,
                        color: ThemaMain.primary, size: 20.sp)),
                if (selects.any((element) => element == true))
                  ElevatedButton(
                      onPressed: () async {
                        List<TiposModelo> temp = [];
                        for (var i = 0; i < selects.length; i++) {
                          if (selects[i]) {
                            temp.add(contactos[i]);
                          }
                        }
                        var archivo = await ShareFun.shareDatas(
                            nombre: "tipos", datas: temp);
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
              ]),
          body: !carga
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
                        TiposModelo tipo = contactos[index];
                        return ListTipoWidget(
                            share: true,
                            tipo: tipo,
                            selected: selects[index],
                            selectedVisible: true,
                            onSelected: (p0) => setState(() {
                                  selects[index] = !selects[index];
                                }),
                            fun: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) =>
                                      DialogsTipos(tipo: tipo));
                              await send();
                            });
                      }),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) => DialogsTipos(tipo: null));
                await send();
              },
              child: Icon(Icons.add_comment, size: 24.sp))),
    );
  }
}
