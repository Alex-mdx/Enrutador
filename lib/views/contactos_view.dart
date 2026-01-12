import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/views/dialogs/dialog_filtro_contacto.dart';
import 'package:enrutador/views/widgets/search/row_filtro.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../utilities/preferences.dart';
import 'widgets/card_contacto_widget.dart';

class ContactosView extends StatefulWidget {
  const ContactosView({super.key});

  @override
  State<ContactosView> createState() => _ContactosViewState();
}

class _ContactosViewState extends State<ContactosView> {
  TextEditingController buscador = TextEditingController();
  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();
  List<ContactoModelo> selects = [];
  bool carga = false;
  List<ContactoModelo> contactos = [];
  var index = 1;
  @override
  void initState() {
    super.initState();
    send();
  }

  Future<void> send() async {
    setState(() {
      carga = false;
    });
    contactos = await ContactoController.getItemsAll(
        nombre: buscador.text, limit: 100, page: index);
    setState(() {
      carga = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            title: Text("Contactos", style: TextStyle(fontSize: 18.sp)),
            actions: [
              OverflowBar(spacing: 2.w, children: [
                ElevatedButton.icon(
                    style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                            horizontal: 3.sp, vertical: 1.h))),
                    onPressed: () async {
                      final tamanio =
                          (await ContactoController.getItems()).length;
                      Dialogs.showMorph(
                          title: "Contactos",
                          description:
                              "Estas seguro de enviar los $tamanio contacto(s)\nEste proceso puede tardar unos segundos dependiendo de el tamaño de los datos obtenidos",
                          loadingTitle: "procesando",
                          onAcceptPressed: (context) async {
                            final all = await ContactoController.getAll();
                            var archivo = await ShareFun.shareDatas(
                                nombre: "contactos", datas: all);
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
                    label:
                        Text("Enviar todo", style: TextStyle(fontSize: 13.sp)),
                    icon: Icon(Icons.done_all,
                        color: ThemaMain.primary, size: 19.sp)),
                if (selects.isNotEmpty)
                  ElevatedButton(
                      style: ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                              horizontal: 3.sp, vertical: 1.h))),
                      onPressed: () async {
                        List<ContactoModelo> temps = [];
                        for (var element in selects) {
                          var cont = await ContactoController.getItemId(
                              id: element.id!);
                          if (cont != null) {
                            temps.add(cont);
                          }
                        }
                        var archivo = await ShareFun.shareDatas(
                            nombre: "contactos", datas: temps);
                        if (archivo.isNotEmpty) {
                          await ShareFun.share(
                              titulo: "Este es un contenido compacto de tipos",
                              mensaje: "objeto de contactos",
                              files:
                                  archivo.map((e) => XFile(e.path)).toList());
                        }
                      },
                      child: Text("Enviar (${selects.length})",
                          style: TextStyle(fontSize: 13.sp)))
              ]),
              IconButton.filledTonal(
                  iconSize: 22.sp,
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => DialogFiltroContacto(fun: () async {
                            index = 1;
                            await send();
                          })),
                  icon: Icon(LineIcons.filter))
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
                          "Nombre | PlusCode | Telefono${kDebugMode ? " | What3Word" : ""}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 15.sp,
                              color: ThemaMain.darkGrey)),
                      suffixIcon: IconButton.filledTonal(
                          iconSize: 22.sp,
                          onPressed: () async => await send(),
                          icon: Icon(Icons.youtube_searched_for,
                              color: ThemaMain.green)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 1.h)))),
          RowFiltro(press: () => send()),
          Expanded(
              flex: 10,
              child: !carga
                  ? Center(
                      child: LoadingAnimationWidget.twoRotatingArc(
                          color: ThemaMain.primary, size: 24.sp))
                  : contactos.isEmpty
                      ? Center(
                          child: Text("No se encontraron contactos",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)))
                      : Scrollbar(child: stick(provider))),
          FutureBuilder(
              future: ContactoController.getTotalRegistros(),
              builder: (context, snapshot) {
                var max = (((contactos.length >= 100
                                    ? (snapshot.data ?? 1)
                                    : contactos.length) ==
                                0
                            ? 1
                            : (contactos.length >= 100
                                ? (snapshot.data ?? 1)
                                : index * 100)) /
                        100)
                    .ceil();
                return Column(children: [
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                            iconSize: 19.sp,
                            onPressed: () async =>
                                await itemScrollController.scrollTo(
                                    index: 0, duration: Duration(seconds: 1)),
                            icon: Icon(LineIcons.arrowCircleUp,
                                color: ThemaMain.primary)),
                        IconButton.filledTonal(
                            iconSize: 19.sp,
                            onPressed: () async {
                              if (index != 1) {
                                index = 1;
                                debugPrint("$index");
                                await send();
                              } else {
                                showToast("Este es el inicio de la pagina");
                              }
                            },
                            icon: Icon(LineIcons.angleDoubleLeft,
                                color: ThemaMain.green)),
                        IconButton.filledTonal(
                            iconSize: 19.sp,
                            onPressed: () async {
                              if (index != 1) {
                                if (index > 1) {
                                  index--;
                                }
                                debugPrint("$index");
                                await send();
                              } else {
                                showToast("Este es el inicio de la pagina");
                              }
                            },
                            icon: Icon(LineIcons.angleLeft,
                                color: ThemaMain.green)),
                        Text("$index - $max",
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        IconButton.filledTonal(
                            iconSize: 19.sp,
                            onPressed: () async {
                              if (index != max) {
                                if (index < max) {
                                  index++;
                                }
                                debugPrint("$index");
                                await send();
                              } else {
                                showToast("Esta es la ultima pagina");
                              }
                            },
                            icon: Icon(LineIcons.angleRight,
                                color: ThemaMain.green)),
                        IconButton.filledTonal(
                            iconSize: 19.sp,
                            onPressed: () async {
                              if (index != max) {
                                index = max;
                                debugPrint("$index");
                                await send();
                              } else {
                                showToast("Esta es la ultima pagina");
                              }
                            },
                            icon: Icon(LineIcons.angleDoubleRight,
                                color: ThemaMain.green)),
                        IconButton.filledTonal(
                            iconSize: 19.sp,
                            onPressed: () async =>
                                await itemScrollController.scrollTo(
                                    index: 100, duration: Duration(seconds: 1)),
                            icon: Icon(LineIcons.arrowCircleDown,
                                color: ThemaMain.primary)),
                      ]),
                  LinearProgressIndicator(
                      color: ThemaMain.primary,
                      value: (index == 0 ? 1 : index / max),
                      minHeight: .7.h)
                ]);
              })
        ]));
  }

  StickyGroupedListView<ContactoModelo, String?> stick(MainProvider provider) {
    return StickyGroupedListView<ContactoModelo, String?>(
        shrinkWrap: true,
        elements: contactos,
        groupBy: (element) => Preferences.tiposFilt == 0
            ? element.nombreCompleto?.substring(0, 1)
            : Preferences.tiposFilt == 1
                ? (Preferences.agruparFilt == 1
                        ? DateTime.parse(Textos.fechaYMD(
                            fecha: element.tipoFecha ?? DateTime(0000, 1, 1)))
                        : (element.tipo ?? -1).toString())
                    .toString()
                : (Preferences.agruparFilt == 1
                    ? DateTime.parse(Textos.fechaYMD(
                            fecha: element.estadoFecha ?? DateTime(0000, 1, 1)))
                        .toString()
                    : (element.estado ?? -1).toString()),
        groupSeparatorBuilder: (element) => Text(
            Preferences.tiposFilt == 0
                ? (element.nombreCompleto ?? "?").substring(0, 1)
                : Preferences.tiposFilt == 1
                    ? Preferences.agruparFilt == 1
                        ? "${Textos.fechaYMD(fecha: element.tipoFecha ?? DateTime(0001, 1, 1))} - ${Textos.conversionDiaNombre(element.tipoFecha ?? DateTime(0001, 1, 1), DateTime.now())}"
                        : provider.tipos
                                .firstWhereOrNull((e) => e.id == element.tipo)
                                ?.nombre ??
                            "Sin tipo"
                    : Preferences.agruparFilt == 1
                        ? "${Textos.fechaYMD(fecha: element.estadoFecha ?? DateTime(0001, 1, 1))} - ${Textos.conversionDiaNombre(element.estadoFecha ?? DateTime(0001, 1, 1), DateTime.now())}"
                        : provider.estados
                                .firstWhereOrNull((e) => e.id == element.estado)
                                ?.nombre ??
                            "Sin Estado",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize:
                    Preferences.tiposFilt == 0 && Preferences.agruparFilt != 0
                        ? 14.sp
                        : Preferences.tiposFilt != 0
                            ? 15.sp
                            : 16.sp,
                backgroundColor: ThemaMain.darkBlue,
                color: ThemaMain.dialogbackground,
                fontWeight: FontWeight.bold)),
        itemBuilder: (context, contacto) {
          var existencia = selects.firstWhereOrNull((element) =>
              element.latitud == contacto.latitud &&
              element.longitud == contacto.longitud);
          return CardContactoWidget(
              entrada: buscador.text,
              contacto: contacto,
              funContact: (p0) {},
              onSelected: (p0) => setState(() {
                    if (existencia != null) {
                      selects.remove(contacto);
                    } else {
                      selects.add(contacto);
                    }
                  }),
              compartir: true,
              selected: existencia != null,
              selectedVisible: true);
        },
        itemComparator: (e1, e2) =>
            (e1.nombreCompleto ?? "?").compareTo(e2.nombreCompleto ?? "?"),
        itemScrollController: itemScrollController,
        order: Preferences.ordenFilt
            ? StickyGroupedListOrder.DESC
            : StickyGroupedListOrder.ASC);
  }
}
