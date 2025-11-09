import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/views/dialogs/dialog_filtro_contacto.dart';
import 'package:enrutador/views/widgets/search/row_filtro.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

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
  @override
  void initState() {
    super.initState();
    send();
  }

  Future<void> send() async {
    setState(() {
      carga = false;
    });
    contactos =
        await ContactoController.getItemsAll(nombre: buscador.text, limit: 100);
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
                            final all = await ContactoController.getItemsAll(
                                nombre: null, limit: null);
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
                        var archivo = await ShareFun.shareDatas(
                            nombre: "contactos", datas: selects);
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
                  iconSize: 20.sp,
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => DialogFiltroContacto()),
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
                      : Scrollbar(
                          child: StickyGroupedListView(
                              shrinkWrap: true,
                              elements: contactos,
                              groupBy: (element) =>
                                  element.nombreCompleto?.substring(0, 1),
                              groupSeparatorBuilder: (element) => Text(
                                  (element.nombreCompleto ?? "?")
                                      .substring(0, 1),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      backgroundColor: ThemaMain.darkBlue,
                                      color: ThemaMain.dialogbackground,
                                      fontWeight: FontWeight.bold)),
                              itemBuilder: (context, contacto) {
                                var existencia = selects.firstWhereOrNull(
                                    (element) =>
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
                                  (e1.nombreCompleto ?? "").compareTo(
                                      e2.nombreCompleto ?? ""), // optional
                              elementIdentifier: (element) => element.id,
                              itemScrollController: itemScrollController)))
        ]));
  }
}
