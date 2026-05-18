import 'package:enrutador/controllers/contacto_fire.dart';
import 'package:enrutador/controllers/pendiente_fire.dart';
import 'package:enrutador/controllers/referencia_fire.dart';
import 'package:enrutador/controllers/referencias_controller.dart';
import 'package:enrutador/models/pendiente_model.dart';
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
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../controllers/nota_controller.dart';
import '../controllers/nota_fire.dart';
import '../utilities/preferences.dart';
import 'widgets/card_contacto_widget.dart';
import 'widgets/sliding_cards/slide_general.dart';

class ContactosView extends StatefulWidget {
  const ContactosView({super.key});

  @override
  State<ContactosView> createState() => _ContactosViewState();
}

class _ContactosViewState extends State<ContactosView> {
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
      itemScrollController = GroupedItemScrollController();
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
              OverflowBar(spacing: 1.w, children: [
                if (kDebugMode)
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
                          color: ThemaMain.primary, size: 18.sp)),
                if (selects.isNotEmpty)
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                              horizontal: 3.sp, vertical: .5.h))),
                      onPressed: () async {
                        var envio = ((provider.usuario?.adminTipo ?? 0) >= 3 ||
                            (provider.usuario?.adminTipo ?? 0) == -1);
                        if (selects.length <= 10) {
                          await Dialogs.showMorph(
                              title: envio ? "Envio de datos" : "Sincronizar",
                              description:
                                  "¿Desea enviar este(os) contacto(s) a ${envio ? "sincronización" : "revision como pendiente"}?",
                              loadingTitle: envio
                                  ? "sincronizando"
                                  : "Generando pendientes",
                              loadingDescription:
                                  "Este proceso puede tomar unos minutos sea paciente",
                              onAcceptPressed: (context) async {
                                for (var i = 0; i < selects.length; i++) {
                                  var cont = await ContactoController.getItemId(
                                      id: selects[i].id!);

                                  var referencia =
                                      await ReferenciasController.getIdPrin(
                                          idContacto: cont!.id!,
                                          lat: cont.latitud,
                                          lng: cont.longitud,
                                          status: -1);

                                  var notas =
                                      await NotasController.getContactoId(
                                          cont.id!,
                                          pendiente: 1);
                                  if (envio) {
                                    var data = cont.copyWith(
                                        pendiente: 0,
                                        empleadoEstado:
                                            ((cont.empleadoEstado == null ||
                                                        cont.empleadoEstado ==
                                                            provider.usuario
                                                                ?.empleadoId) &&
                                                    (cont.estado != null &&
                                                        cont.estado != -1))
                                                ? provider.usuario?.empleadoId
                                                : cont.empleadoEstado,
                                        aceptadoEmpleado:
                                            provider.usuario?.empleadoId);
                                    var result = await ContactoFire.sendItem(
                                        data: data,
                                        table: data.id.toString(),
                                        query: "id",
                                        itsNumber: true);
                                    if (result) {
                                      await ContactoController.update(data);
                                      for (var item in referencia) {
                                        var newItem = item.copyWith(estatus: 0);
                                        var result = await ReferenciaFire.send(
                                            referencia: newItem);
                                        if (result) {
                                          await ReferenciasController.update(
                                              newItem);
                                        }
                                      }
                                      for (var item in notas) {
                                        var newItem =
                                            item.copyWith(pendiente: 0);
                                        var result =
                                            await NotaFire.send(nota: newItem);
                                        if (result) {
                                          await NotasController.update(newItem);
                                        }
                                      }
                                      showToast(
                                          "Envio\nContacto numero ${i + 1} de ${selects.length}");
                                    } else {
                                      showToast(
                                          "No se pudo enviar el contacto numero ${i + 1}");
                                    }
                                  } else {
                                    var data = cont.copyWith(
                                        pendiente: 0,
                                        empleadoEstado:
                                            ((cont.empleadoEstado == null ||
                                                        cont.empleadoEstado ==
                                                            provider.usuario
                                                                ?.empleadoId) &&
                                                    (cont.estado != null &&
                                                        cont.estado != -1))
                                                ? provider.usuario?.empleadoId
                                                : cont.empleadoEstado,
                                        aceptadoEmpleado:
                                            provider.usuario?.empleadoId);
                                    debugPrint(
                                        "empleadoEstado: ${data.empleadoEstado}");
                                    for (var i = 0;
                                        i < referencia.length;
                                        i++) {
                                      var newItem =
                                          referencia[i].copyWith(estatus: 1);
                                      referencia[i] = newItem;
                                    }
                                    for (var i = 0; i < notas.length; i++) {
                                      var newItem =
                                          notas[i].copyWith(pendiente: 1);
                                      notas[i] = newItem;
                                    }
                                    PendienteModel pendiente = PendienteModel(
                                        id: Textos.randomWord(6),
                                        empleadoId:
                                            provider.usuario!.empleadoId!,
                                        fechaPendiente: DateTime.now(),
                                        sincronizado: 0,
                                        aceptadoEmpleadoId: null,
                                        fechaSincronizado: null,
                                        notasGuia: null,
                                        contactos: [data],
                                        referencias: referencia,
                                        notas: notas);
                                    var result = await PendienteFire.sendItem(
                                        data: pendiente, query: pendiente.id);
                                    if (result) {
                                      await ContactoController.update(data);
                                      for (var item in referencia) {
                                        await ReferenciasController.update(
                                            item);
                                      }

                                      for (var item in notas) {
                                        await NotasController.update(item);
                                      }
                                      showToast(
                                          "Envio\nContacto numero ${i + 1} de ${selects.length}");
                                    } else {
                                      showToast(
                                          "No se pudo enviar el contacto numero ${i + 1}");
                                    }
                                  }
                                }
                                selects.clear();
                                await send(index);
                              });
                        } else {
                          showToast(
                              "No puedes enviar mas de 5 contactos al mismo tiempo.\nPor favor selecciona 5 o menos para enviar");
                        }
                      },
                      label: Text("Enviar (${selects.length})",
                          style: TextStyle(fontSize: 13.sp)),
                      icon: RiveAnimatedIcon(
                          enableAbsorbPointer: true,
                          riveIcon: RiveIcon.reload,
                          color: ThemaMain.green,
                          height: 3.h,
                          width: 3.h)),
                if (selects.isNotEmpty)
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                              horizontal: 3.sp, vertical: .5.h))),
                      onPressed: () async {
                        if (selects.length <= 100) {
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
                                titulo:
                                    "Este es un contenido compacto de tipos",
                                mensaje: "objeto de contactos",
                                files:
                                    archivo.map((e) => XFile(e.path)).toList());
                          }
                        } else {
                          showToast(
                              "No compartir de mas de 100 contactos.\nPor favor selecciona 100 o menos para compartir");
                        }
                      },
                      label: Text("Enviar (${selects.length})",
                          style: TextStyle(fontSize: 13.sp)),
                      icon: RiveAnimatedIcon(
                          enableAbsorbPointer: true,
                          riveIcon: RiveIcon.copy,
                          color: ThemaMain.primary,
                          height: 3.h,
                          width: 3.h))
              ]),
              IconButton.filledTonal(
                  iconSize: 22.sp,
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => DialogFiltroContacto(fun: () async {
                            index = 1;
                            await send(index);
                          })),
                  icon: Icon(LineIcons.filter))
            ]),
        body: Column(children: [
          Padding(
              padding: EdgeInsets.all(10.sp),
              child: TextFormField(
                  controller: buscador,
                  enabled: carga,
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
          RowFiltro(press: () => send(index)),
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
        ]));
  }

  StickyGroupedListView<ContactoModelo, String?> stick(
      MainProvider provider, Function() send) {
    return StickyGroupedListView<ContactoModelo, String?>(
        shrinkWrap: true,
        elements: contactos,
        padding: EdgeInsets.symmetric(horizontal: .5.w, vertical: .1.h),
        groupBy: (element) => Preferences.tiposFilt == 0
            ? Preferences.vaciosFilt
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
                ? Preferences.vaciosFilt
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
                var sqlContacto =
                    await ContactoController.getItemId(id: contacto.id!);
                debugPrint(
                    "${sqlContacto?.estado} ${(sqlContacto?.empleadoEstado == null || sqlContacto?.empleadoEstado == provider.usuario?.empleadoId) && (sqlContacto?.estado != null || sqlContacto?.estado != -1)}");
                var data = sqlContacto!.copyWith(
                    pendiente: 0,
                    empleadoEstado: ((sqlContacto.empleadoEstado == null ||
                                sqlContacto.empleadoEstado ==
                                    provider.usuario?.empleadoId) &&
                            (sqlContacto.estado != null &&
                                sqlContacto.estado != -1))
                        ? provider.usuario?.empleadoId
                        : sqlContacto.empleadoEstado,
                    aceptadoEmpleado: provider.usuario?.empleadoId);
                debugPrint("empleadoEstado: ${data.empleadoEstado}");
                for (var i = 0; i < referencia.length; i++) {
                  var newItem = referencia[i].copyWith(estatus: 1);
                  referencia[i] = newItem;
                }
                for (var i = 0; i < notas.length; i++) {
                  var newItem = notas[i].copyWith(pendiente: 1);
                  notas[i] = newItem;
                }
                PendienteModel pendiente = PendienteModel(
                    id: Textos.randomWord(6),
                    empleadoId: provider.usuario!.empleadoId!,
                    fechaPendiente: DateTime.now(),
                    sincronizado: 0,
                    aceptadoEmpleadoId: null,
                    fechaSincronizado: null,
                    notasGuia: null,
                    contactos: [data],
                    referencias: referencia,
                    notas: notas);
                var result = await PendienteFire.sendItem(
                    data: pendiente, query: pendiente.id);
                if (result) {
                  await ContactoController.update(data);
                  for (var item in referencia) {
                    await ReferenciasController.update(item);
                  }

                  for (var item in notas) {
                    await NotasController.update(item);
                  }
                  await send();
                }
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
              onAcceptPressed: (contexto) async {
                var sqlContacto =
                    await ContactoController.getItemId(id: contacto.id!);
                debugPrint(
                    "${sqlContacto?.estado} - ${sqlContacto?.empleadoEstado}\n${(sqlContacto?.empleadoEstado == null || sqlContacto?.empleadoEstado == provider.usuario?.empleadoId) && (sqlContacto?.estado != null || sqlContacto?.estado != -1)}");
                var data = sqlContacto!.copyWith(
                    pendiente: 0,
                    empleadoEstado: ((sqlContacto.empleadoEstado == null ||
                                sqlContacto.empleadoEstado ==
                                    provider.usuario?.empleadoId) &&
                            (sqlContacto.estado != null &&
                                sqlContacto.estado != -1))
                        ? provider.usuario?.empleadoId
                        : sqlContacto.empleadoEstado,
                    aceptadoEmpleado: provider.usuario?.empleadoId);
                debugPrint("empleadoEstado: ${data.empleadoEstado}");
                var result = await ContactoFire.sendItem(
                    data: data,
                    table: "id",
                    query: contacto.id.toString(),
                    itsNumber: true);
                if (result) {
                  await ContactoController.update(data);
                  for (var item in referencia) {
                    var newItem = item.copyWith(estatus: 0);
                    var result = await ReferenciaFire.send(referencia: newItem);
                    if (result) {
                      await ReferenciasController.update(newItem);
                    }
                  }
                  for (var item in notas) {
                    var newItem = item.copyWith(pendiente: 0);
                    var result = await NotaFire.send(nota: newItem);
                    if (result) {
                      await NotasController.update(newItem);
                    }
                  }
                  await send();
                  showToast("Contacto enviado");
                } else {
                  showToast("Error al enviar datos");
                }
              });
        },
        model: modelo);
  }
}
