import 'package:enrutador/controllers/estado_controller.dart';
import 'package:enrutador/models/estado_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/dialogs/dialogs_estados.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'widgets/list_estado_widget.dart';

class EstadoView extends StatefulWidget {
  const EstadoView({super.key});

  @override
  State<EstadoView> createState() => _TiposViewState();
}

class _TiposViewState extends State<EstadoView> {
  List<bool> selects = [];
  bool carga = false;
  List<EstadoModel> estados = [];
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
    estados = await EstadoController.getItems();
    selects.addAll(estados.map((e) => false).toList());
    setState(() {
      carga = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return PopScope(
        onPopInvokedWithResult: (didPop, result) async =>
            provider.estados = await EstadoController.getItems(),
        child: Scaffold(
            appBar: AppBar(
                title: Text("Estados", style: TextStyle(fontSize: 18.sp)),
                actions: [
                  ElevatedButton.icon(
                      onPressed: () async {
                        var estados = await EstadoController.getItems();
                        Dialogs.showMorph(
                            title: "Estados",
                            description:
                                "Estas seguro de enviar los ${estados.length} estado(s)\nEste proceso puede tardar unos segundos dependiendo de el tamaño de los datos obtenidos",
                            loadingTitle: "procesando",
                            onAcceptPressed: (context) async {
                              var archivo = await ShareFun.shareDatas(
                                  nombre: "estados", datas: estados);
                              if (archivo.isNotEmpty) {
                                await ShareFun.share(
                                    titulo:
                                        "Este es un contenido compacto de tipos",
                                    mensaje: "objeto de contactos",
                                    files: archivo
                                        .map((e) => XFile(e.path))
                                        .toList());
                              }
                            });
                      },
                      label: Text("Enviar todo",
                          style: TextStyle(fontSize: 14.sp)),
                      icon: Icon(Icons.done_all,
                          color: ThemaMain.primary, size: 20.sp)),
                  if (selects.any((element) => element == true))
                    ElevatedButton(
                        onPressed: () async {
                          List<EstadoModel> temp = [];
                          for (var i = 0; i < selects.length; i++) {
                            if (selects[i]) {
                              temp.add(estados[i]);
                            }
                          }
                          var archivo = await ShareFun.shareDatas(
                              nombre: "tipos", datas: temp);
                          if (archivo.isNotEmpty) {
                            await ShareFun.share(
                                titulo:
                                    "Este es un contenido compacto de tipos",
                                mensaje: "objeto de contactos",
                                files:
                                    archivo.map((e) => XFile(e.path)).toList());
                          }
                        },
                        child: Text(
                            "Enviar (${selects.where((element) => element == true).length})",
                            style: TextStyle(fontSize: 14.sp)))
                ]),
            body: !carga
                ? Center(child: CircularProgressIndicator())
                : estados.isEmpty
                    ? Center(
                        child: Text("No se ha ingresado ningun estado",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)))
                    : Timeline.builder(
                        theme: TimelineThemeData.vertical(),
                        itemBuilder: (context, index) => Column(children: [
                          SizedBox(height: 2.h, child: DashedLineConnector()),
                          ListEstadoWidget(
                              share: true,
                              estado: estados[index],
                              selected: selects[index],
                              selectedVisible: true,
                              onSelected: (p0) => setState(() {
                                    selects[index] = !selects[index];
                                  }),
                              fun: () async {
                                await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        DialogsEstados(estado: estados[index]));
                                await send();
                              }),
                          SizedBox(height: 2.h, child: DashedLineConnector()),
                          if (estados.length - 1 == index) DotIndicator()
                        ]),
                        itemCount: estados.length,
                      ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (context) => DialogsEstados(estado: null));
                  await send();
                },
                child: Icon(Icons.add_comment, size: 24.sp))));
  }
}
