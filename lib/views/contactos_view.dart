import 'package:enrutador/controllers/referencias_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/views/dialogs/dialog_filtro_contacto.dart';
import 'package:enrutador/views/widgets/extras/paginador_widget.dart';
import 'package:enrutador/views/widgets/search/row_filtro.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../controllers/fireController/fire_constants.dart';
import '../controllers/nota_controller.dart';
import '../utilities/preferences.dart';
import 'widgets/card_contacto_widget.dart';
import 'widgets/extras/multi_opcion.dart';
import 'widgets/sliding_cards/slide_general.dart';

class ContactosView extends StatefulWidget {
  const ContactosView({super.key});

  @override
  State<ContactosView> createState() => _ContactosViewState();
}

class _ContactosViewState extends State<ContactosView> {
  FocusNode focusNode = FocusNode();
  TextEditingController buscador = TextEditingController();
  GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();
  List<ContactoModelo> selects = [];
  bool carga = false;
  List<ContactoModelo> contactos = [];
  var index = 1;
  int max = 1;
  @override
  void initState() {
    super.initState();
    send(1);
  }

  Future<void> send(int idx) async {
    var mx = await ContactoController.getTotalRegistros();

    setState(() {
      max = mx;
      carga = false;
    });
    debugPrint("Total de registros: $max");
    index = idx;
    contactos = await ContactoController.getItemsAll(
        nombre: buscador.text, limit: 100, page: index);

    setState(() {
      if (itemScrollController.isAttached) {
        itemScrollController.jumpTo(index: 0);
      }
      carga = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            title: Text("Contactos ($max)", style: TextStyle(fontSize: 18.sp)),
            actions: [
              OverflowBar(spacing: 1.w, children: [
                /* if (kDebugMode)
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                              horizontal: 3.sp, vertical: 0))),
                      onPressed: () async {
                        final tamanio =
                            (await ContactoController.getItems(null)).length;
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
                      label: Text("Enviar todo",
                          style: TextStyle(fontSize: 13.sp)),
                      icon: Icon(Icons.done_all,
                          color: ThemaMain.primary, size: 18.sp)), */

                IconButton.filledTonal(
                    iconSize: 22.sp,
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => DialogFiltroContacto(
                            ordenar: Preferences.ordenFilt,
                            agrupar: Preferences.agruparFilt,
                            pendientes: Preferences.pendientesFilt,
                            tipo: Preferences.tiposFilt,
                            vacios: Preferences.vaciosFilt,
                            apply:
                                (tipo, agrupar, ordenar, vacios, pendientes) {
                              Preferences.pendientesFilt = pendientes;
                              Preferences.tiposFilt = tipo;
                              Preferences.vaciosFilt = vacios;
                              Preferences.ordenFilt = ordenar;
                              Preferences.agruparFilt = agrupar;
                            },
                            fun: () async {
                              index = 1;
                              await send(index);
                            })),
                    icon: Icon(LineIcons.filter))
              ])
            ]),
        body: Column(children: [
          Padding(
              padding: EdgeInsets.all(10.sp),
              child: TextFormField(
                  controller: buscador,
                  enabled: carga,
                  focusNode: focusNode,
                  onTapOutside: (event) {
                    if (focusNode.hasFocus) focusNode.unfocus();
                  },
                  onEditingComplete: () async => await send(index),
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
                          onPressed: () async => await send(index),
                          icon: Icon(Icons.youtube_searched_for,
                              color: ThemaMain.green)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 1.h)))),
          RowFiltro(
              tipos: Preferences.tipos,
              estados: Preferences.status,
              zonas: Preferences.zonas,
              updateData: (tipo, estado, zona) => setState(() {
                    Preferences.tipos = tipo;
                    Preferences.status = estado;
                    Preferences.zonas = zona;
                  }),
              press: () => send(index)),
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
                      : Scrollbar(
                          thickness: 1.w,
                          child:
                              stick(provider, () async => await send(index)))),
          PaginadorGroupedWidget(
              max: max,
              length: contactos.length,
              send: (index) async => await send(index),
              itemScrollController: itemScrollController)
        ]),
        floatingActionButton: selects.isNotEmpty
            ? MultiOpcion(selects: selects, send: () async => await send(index))
            : null,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniEndFloat);
  }

  StickyGroupedListView<ContactoModelo, String?> stick(
      MainProvider provider, Function() send) {
    return StickyGroupedListView<ContactoModelo, String?>(
        shrinkWrap: true,
        elements: contactos,
        padding: EdgeInsets.symmetric(horizontal: .5.w, vertical: .1.h),
        groupBy: (element) => Preferences.tiposFilt == 0
            ? Preferences.agruparFilt == 0
                ? element.nombreCompleto?.substring(0, 1)
                : DateTime.parse(Textos.fechaYMD(fecha: element.creado ?? DateTime(0000, 1, 1)))
                    .toString()
            : Preferences.tiposFilt == 1
                ? (Preferences.agruparFilt == 1
                        ? DateTime.parse(Textos.fechaYMD(
                            fecha: element.tipoFecha ?? DateTime(0000, 1, 1)))
                        : (element.tipo ?? -1).toString())
                    .toString()
                : (Preferences.agruparFilt == 1
                    ? DateTime.parse(Textos.fechaYMD(fecha: element.estadoFecha ?? DateTime(0000, 1, 1)))
                        .toString()
                    : (element.estado ?? -1).toString()),
        groupSeparatorBuilder: (element) => Text(
            Preferences.tiposFilt == 0
                ? Preferences.agruparFilt == 0
                    ? (element.nombreCompleto ?? "?").substring(0, 1)
                    : element.creado == null
                        ? "Sin fecha"
                        : DateTime.parse(Textos.fechaYMD(fecha: element.creado ?? DateTime(0000, 1, 1)))
                            .toString()
                : Preferences.tiposFilt == 1
                    ? Preferences.agruparFilt == 1
                        ? " ${element.tipoFecha == null ? "Sin fecha" : Textos.fechaYMD(fecha: element.tipoFecha ?? DateTime(0001, 1, 1))} - ${element.tipoFecha == null ? "Desconocido" : Textos.conversionDiaNombre(element.tipoFecha ?? DateTime(0001, 1, 1), DateTime.now())}"
                        : provider.tipos
                                .firstWhereOrNull((e) => e.id == element.tipo)
                                ?.nombre ??
                            "Sin tipo"
                    : Preferences.agruparFilt == 1
                        ? " ${element.estadoFecha == null ? "Sin fecha" : Textos.fechaYMD(fecha: element.estadoFecha ?? DateTime(0001, 1, 1))} - ${element.estadoFecha == null ? "Desconocido" : Textos.conversionDiaNombre(element.estadoFecha ?? DateTime(0001, 1, 1), DateTime.now())}"
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
          var existencia =
              selects.firstWhereOrNull((element) => element.id == contacto.id);
          return contacto.pendiente != 0
              ? slider(
                  contacto,
                  provider,
                  CardContactoWidget(
                      entrada: buscador.text,
                      contacto: contacto,
                      funContact: (p0) {},
                      onSelected: (p0) => setState(() {
                            if (existencia != null) {
                              selects.remove(existencia);
                            } else {
                              selects.add(contacto);
                            }
                          }),
                      compartir: true,
                      selected: existencia != null,
                      selectedVisible: true),
                  () => send())
              : CardContactoWidget(
                  entrada: buscador.text,
                  contacto: contacto,
                  funContact: (p0) {},
                  onSelected: (p0) => setState(() {
                        if (existencia != null) {
                          selects.remove(existencia);
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

  Widget slider(ContactoModelo contacto, MainProvider provider, Widget modelo,
      Function() send) {
    return SlideGeneral(
        id: contacto.id!,
        delete: () async {
          await Dialogs.showMorph(
              title: "Eliminar envio",
              description:
                  "¿Desea quitar este cambio de los pendientes?\nTodos los cambios se mantendran de manera local",
              loadingTitle: "Eliminando",
              onAcceptPressed: (context) async {
                var data = contacto.copyWith(pendiente: 0);
                await ContactoController.update(data);
                await send();
              });
        },
        pendiente: () async {
          var referencia = await ReferenciasController.getIdPrin(
              idContacto: contacto.id!,
              lat: contacto.latitud,
              lng: contacto.longitud,
              status: -1);

          var notas =
              await NotasController.getContactoId(contacto.id!, pendiente: 1);
          await Dialogs.showMorph(
              title: "Pendiente",
              description:
                  "¿Desea enviar este contacto para que sea revisado?\nEstas enviando ${referencia.length} referencias y ${notas.length} notas ligadas a este contacto",
              loadingTitle: "Enviando",
              onAcceptPressed: (contexto) async {
                await FireConstants.pendienteServer(
                    cont: contacto,
                    referencia: referencia,
                    notas: notas,
                    empleado: provider.usuario!.empleadoId!,
                    send: () async => await send());
              });
        },
        ifDirecto: ((provider.usuario?.adminTipo ?? 1) >= 2 ||
            (provider.usuario?.adminTipo ?? 1) == -1),
        directo: () async {
          var referencia = await ReferenciasController.getIdPrin(
              idContacto: contacto.id!,
              lat: contacto.latitud,
              lng: contacto.longitud,
              status: -1);

          var notas =
              await NotasController.getContactoId(contacto.id!, pendiente: 1);
          await Dialogs.showMorph(
              title: "Sincronizar",
              description:
                  "¿Desea guardar este contacto con sus cambios de manera directa?\nEstas enviando ${referencia.length} referencia(s) y ${notas.length} nota(s) ligada(s) a este contacto",
              loadingTitle: "Guardando",
              onAcceptPressed: (contexto) async =>
                  await FireConstants.sendServer(
                      contacto: contacto,
                      referencia: referencia,
                      notas: notas,
                      empleado: provider.usuario!.empleadoId!,
                      send: () async => await send()));
        },
        model: modelo);
  }
}
