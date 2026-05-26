import 'package:enrutador/controllers/fireController/zona_fire.dart';
import 'package:enrutador/models/zona_model.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/dialogs/dialogs_zonas.dart';
import 'package:enrutador/views/widgets/list_zona_widget.dart';
import 'package:enrutador/views/widgets/sliding_cards/slide_general.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

import '../controllers/zonas_controller.dart';
import '../utilities/services/dialog_services.dart';

class ZonasView extends StatefulWidget {
  const ZonasView({super.key});

  @override
  State<ZonasView> createState() => _ZonasViewState();
}

class _ZonasViewState extends State<ZonasView> {
  final ScrollController itemScrollController = ScrollController();
  List<bool> selects = [];
  bool carga = false;
  List<ZonasModel> zonas = [];
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
    zonas = await ZonasController.getAll();
    selects.addAll(zonas.map((e) => false).toList());
    setState(() {
      carga = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Zonas", style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton.filled(
                  iconSize: 20.sp,
                  onPressed: () => showDialog(
                      context: context, builder: (context) => DialogsZonas()),
                  icon: Icon(Icons.add, color: ThemaMain.green))
            ]),
        body: !carga
            ? Center(
                child: LoadingAnimationWidget.twoRotatingArc(
                    color: ThemaMain.primary, size: 36.sp))
            : zonas.isEmpty
                ? Center(
                    child: TextButton.icon(
                        onPressed: () async {
                          bool result = false;
                          await Dialogs.showMorph(
                              title: "Descargar zonas",
                              description:
                                  "Desea descargar las zonas de la base de datos?",
                              loadingTitle: "procesando",
                              onAcceptPressed: (context) async => setState(() {
                                    result = true;
                                  }));
                          if (result) {
                            carga = false;
                            var cont = await ZonasFire.getItems();
                            for (var element in cont) {
                              await ZonasController.insert(element);
                            }
                            await send();
                          }
                        },
                        icon: Icon(Icons.refresh, size: 20.sp),
                        label: Text("No se ha ingresado ninguna zona",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold))))
                : RefreshIndicator(
                    onRefresh: () async {
                      bool result = false;
                      await Dialogs.showMorph(
                          title: "Descargar zonas",
                          description:
                              "Desea descargar las zonas de la base de datos?",
                          loadingTitle: "procesando",
                          onAcceptPressed: (context) async => setState(() {
                                result = true;
                              }));
                      if (result) {
                        carga = false;
                        var cont = await ZonasFire.getItems();
                        for (var element in cont) {
                          await ZonasController.insert(element);
                        }
                        await send();
                      }
                    },
                    child: Scrollbar(
                        interactive: true,
                        controller: itemScrollController,
                        child: ListView.builder(
                            controller: itemScrollController,
                            shrinkWrap: true,
                            itemCount: zonas.length,
                            itemBuilder: (context, index) {
                              ZonasModel zona = zonas[index];
                              return SlideGeneral(
                                  id: zona.id!,
                                  ifDirecto: zona.status == 0,
                                  directo: () async {
                                    await Dialogs.showMorph(
                                        title: "Sincronizar",
                                        description:
                                            "Desea sincronizar la zona al servidor?",
                                        loadingTitle: "Procesando",
                                        onAcceptPressed: (context) async {
                                          var tempZ = zona.copyWith(status: 1);
                                          var result =
                                              await ZonasFire.send(zona: tempZ);
                                          if (result) {
                                            await ZonasController.insert(tempZ);
                                            await send();
                                          }
                                        });
                                  },
                                  model: ListZonaWidget(
                                      zona: zona,
                                      selected: selects[index],
                                      selectedVisible: true,
                                      onSelected: (p0) => setState(() {
                                            selects[index] = !selects[index];
                                          }),
                                      fun: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                DialogsZonas(item: zona));
                                        await send();
                                      }));
                            }))));
  }
}
