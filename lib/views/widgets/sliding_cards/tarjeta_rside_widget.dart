import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/contacto_controller.dart';
import '../../../controllers/fireController/contacto_fire.dart';
import '../../../controllers/enrutar_controller.dart';
import '../../../controllers/fireController/nota_fire.dart';
import '../../../controllers/fireController/referencia_fire.dart';
import '../../../controllers/nota_controller.dart';
import '../../../controllers/referencias_controller.dart';
import '../../../models/contacto_model.dart';
import '../../../models/enrutar_model.dart';
import '../../../utilities/main_provider.dart';
import '../../../utilities/map_fun.dart';
import '../../../utilities/services/dialog_services.dart';
import '../../../utilities/services/navigation_services.dart';
import '../../../utilities/theme/theme_color.dart';
import '../../dialogs/dialog_compartir.dart';
import '../map_widget/lauch_main_icon.dart';

class TarjetaRsideWidget extends StatefulWidget {
  const TarjetaRsideWidget({super.key});

  @override
  State<TarjetaRsideWidget> createState() => _TarjetaRsideWidgetState();
}

class _TarjetaRsideWidgetState extends State<TarjetaRsideWidget> {
  Future<void> funcion({required ContactoModelo contacto}) async {
    var data =
        await EnrutarController.getItemContacto(contactoId: contacto.id!);

    if (data != null) {
      var newEnrutar = data.copyWith(buscar: contacto);
      await EnrutarController.update(newEnrutar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Row(
        spacing: .1.w,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (provider.contacto?.id != null)
            IconButton.filledTonal(
                iconSize: 22.sp,
                onPressed: () async => await showDialog(
                    context: context,
                    builder: (context) =>
                        DialogCompartir(contacto: provider.contacto!)),
                icon: Icon(Icons.share, color: ThemaMain.darkBlue)),
          LauchMainIcon(
              coordenadas: LatLng(provider.contacto?.latitud ?? 0,
                  provider.contacto?.longitud ?? 0),
              words: provider.contacto?.nombreCompleto),
          if (provider.contacto?.id != null)
            FutureBuilder(
                future: EnrutarController.getItemContacto(
                    contactoId: provider.contacto!.id!),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? SizedBox()
                      : IconButton.filled(
                          iconSize: 22.sp,
                          onPressed: () async {
                            Dialogs.showMorph(
                                title: "Enrutar",
                                description:
                                    "¿Usar este contacto para enrutar?\nSe metera este contacto a una lista para visitar",
                                loadingTitle: "Enrutando...",
                                onAcceptPressed: (contexto) async {
                                  EnrutarModelo data = EnrutarModelo(
                                      visitado: 0,
                                      orden: 0,
                                      contactoId: provider.contacto!.id!,
                                      buscar: provider.contacto!);
                                  await EnrutarController.insert(data);
                                  showToast(
                                      "Contacto ingresado para el enrutamiento");
                                });
                          },
                          icon: Icon(LineIcons.directions,
                              color: ThemaMain.green));
                }),
          if (provider.contacto?.id != null)
            IconButton.filledTonal(
                iconSize: 22.sp,
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => Dialog(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              Text("Agendar visita",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                              CalendarDatePicker(
                                  initialCalendarMode: DatePickerMode.day,
                                  initialDate: provider.contacto?.agendar ??
                                      DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(Duration(days: 365 * 6)),
                                  onDateChanged: (time) => Dialogs.showMorph(
                                      title: "Seleccionar fecha",
                                      description:
                                          "¿Esta seguro de seleccionar dicha fecha para visitar?",
                                      loadingTitle: "Guardando",
                                      onAcceptPressed: (context) async {
                                        var newModel = provider.contacto
                                            ?.copyWith(
                                                agendar: time, pendiente: 1);
                                        await ContactoController.update(
                                            newModel!);
                                        funcion(contacto: newModel);
                                        provider.contacto = newModel;
                                        Navigation.pop();
                                      }))
                            ]))),
                icon: Icon(LineIcons.calendarWithDayFocus,
                    color: ThemaMain.darkBlue)),
          IconButton.filledTonal(
              iconSize: provider.contacto?.id == null ? 22.sp : 18.sp,
              onPressed: () async {
                if (provider.contacto?.id == null) {
                  await ContactoController.insert(provider.contacto!);
                  provider.marker = null;
                  provider.contacto = await ContactoController.getItem(
                      lat: provider.contacto!.latitud,
                      lng: provider.contacto!.longitud);
                } else {
                  if (provider.contacto?.pendiente == 1) {
                    await Dialogs.showMorph(
                        title: "Eliminar Punteo",
                        description:
                            "¿Desea eliminar este punteo?\nEste punteo solo existe localmente, si se elimina se perdera para siempre",
                        loadingTitle: "Eliminando",
                        onAcceptPressed: (context) async {
                          await ContactoController.deleteItem(
                              provider.contacto!.id!);
                          var model = ContactoModelo.fromJson({
                            "id": null,
                            "latitud": provider.contacto!.latitud,
                            "longitud": provider.contacto!.longitud,
                            "pendiente": 1,
                            "status": 0
                          });
                          provider.contacto = model;
                          await MapFun.touch(
                              provider: provider,
                              lat: double.parse(
                                  model.latitud.toStringAsFixed(7)),
                              lng: double.parse(
                                  model.longitud.toStringAsFixed(7)));
                          var datas = await EnrutarController.getItemContacto(
                              contactoId: provider.contacto!.id ?? -1);
                          if (datas != null) {
                            await EnrutarController.deleteItem(datas.id!);
                          }
                          showToast("Marcador limpiado");
                        });
                  }
                }
              },
              icon: provider.contacto?.id == null
                  ? Icon(Icons.save, color: ThemaMain.green)
                  : Icon(Icons.delete, color: ThemaMain.red)),
          if (provider.contacto?.id != null)
            IconButton.filledTonal(
                iconSize: 18.sp,
                onLongPress: () {
                  if (provider.internet) {
                    if (provider.contacto?.pendiente == 1) {
                      Dialogs.showMorph(
                          title: "Verificar Cambios",
                          description: "¿Desea sincronizar los cambios?",
                          loadingTitle: "Verificando",
                          onAcceptPressed: (context) async {
                            var cont = await ContactoController.getItemId(
                                id: provider.contacto!.id!);

                            var referencia =
                                await ReferenciasController.getIdPrin(
                                    idContacto: cont!.id!,
                                    lat: cont.latitud,
                                    lng: cont.longitud,
                                    status: -1);

                            var notas = await NotasController.getContactoId(
                                cont.id!,
                                pendiente: 1);
                            var data = cont.copyWith(
                                pendiente: 0,
                                empleadoEstado: ((cont.empleadoEstado == null ||
                                            cont.empleadoEstado ==
                                                provider.usuario?.empleadoId) &&
                                        (cont.estado != null &&
                                            cont.estado != -1))
                                    ? provider.usuario?.empleadoId
                                    : cont.empleadoEstado,
                                aceptadoEmpleado: provider.usuario?.empleadoId);
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
                              showToast("Envio\nContacto numero");
                            } else {
                              showToast("No se pudo enviar el contacto}");
                            }
                          });
                    } else {
                      showToast("Contacto sincronizado");
                    }
                  } else {
                    showToast("Sin internet\nintente mas tarde");
                  }
                },
                onPressed: () async {
                  if (provider.internet) {
                    if (provider.contacto?.pendiente == 1) {
                      Dialogs.showMorph(
                          title: "Cambios detectados",
                          description:
                              "¿Desea sincronizar los cambios?\nSe van a descargar los cambios del servidor y se van a sobreescribir los cambios locales",
                          loadingTitle: "Sincronizando",
                          onAcceptPressed: (context) async {
                            var contact = await ContactoFire.getItem(
                                id: provider.contacto!.id);
                            if (contact != null) {
                              var temp = contact.copyWith(pendiente: 0);
                              await ContactoController.update(temp);
                              provider.contacto = temp;
                              showToast("Contacto sincronizado");
                            } else {
                              if (provider.contacto?.pendiente == 1) {
                                showToast(
                                    "Contacto no encontrado en el servidor");
                              } else {
                                showToast(
                                    "Puede que este contacto esta pendiente a aceptar o no exista en el servidor");
                              }
                            }
                          });
                    } else {
                      showToast("Contacto sincronizado");
                    }
                  } else {
                    showToast("Sin internet\nintente mas tarde");
                  }
                },
                icon: Icon(
                    provider.contacto?.pendiente == 0
                        ? LineIcons.cloud
                        : LineIcons.alternateCloudDownload,
                    color: provider.contacto?.pendiente == 0
                        ? ThemaMain.green
                        : ThemaMain.darkBlue)),
          if (((provider.usuario?.adminTipo ?? 0) > 4 ||
                  (provider.usuario?.adminTipo ?? 0) == -1) &&
              (provider.contacto?.pendiente != 1) &&
              provider.contacto?.id != null)
            IconButton.filledTonal(
                iconSize: 18.sp,
                onPressed: () async {
                  if (provider.internet) {
                    await Dialogs.showMorph(
                        title: "Inhabilitar Punteo",
                        description:
                            "¿Desea inhabilitar este punteo?\nYa no se tendra acceso a este marcador de manera local ademas de bloquear su acceso a la aplicacion",
                        loadingTitle: "Inhabilitando",
                        onAcceptPressed: (context) async {
                          showToast("Buscando contacto...");
                          var contact = await ContactoFire.getItem(
                              id: provider.contacto!.id);
                          if (contact != null) {
                            showToast("Inhabilitando contacto...");
                            var result = await ContactoFire.sendItem(
                                data:
                                    contact.copyWith(pendiente: 0, status: 0));
                            if (result) {
                              showToast(
                                  "Contacto inhabilitado correctamente\nSe eliminara localmente");
                            } else {
                              showToast(
                                  "Error al inhabilitar contacto\nSe eliminara localmente");
                            }
                          } else {
                            showToast(
                                "Contacto no encontrado\nSe eliminara localmente");
                          }

                          await ContactoController.deleteItem(
                              provider.contacto!.id!);
                          var model = ContactoModelo.fromJson({
                            "id": provider.contacto!.id,
                            "latitud": provider.contacto!.latitud,
                            "longitud": provider.contacto!.longitud
                          });
                          provider.contacto =
                              model.copyWith(pendiente: 1, status: 0);
                          await MapFun.touch(
                              provider: provider,
                              lat: model.latitud,
                              lng: model.longitud);
                          var datas = await EnrutarController.getItemContacto(
                              contactoId: provider.contacto!.id ?? -1);
                          if (datas != null) {
                            await EnrutarController.deleteItem(datas.id!);
                          }
                          showToast("Marcador inhabilitado");
                        });
                  } else {
                    showToast("Sin internet\nintente mas tarde");
                  }
                },
                icon: Icon(LineIcons.userSlash, color: ThemaMain.pink))
        ]);
  }
}
