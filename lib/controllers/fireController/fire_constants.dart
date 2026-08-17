import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:oktoast/oktoast.dart';

import '../../models/contacto_model.dart';
import '../../models/pendiente_model.dart';
import '../../models/referencia_model.dart';
import '../../utilities/textos.dart';
import '../contacto_controller.dart';
import '../nota_controller.dart';
import '../referencias_controller.dart';
import 'contacto_fire.dart';
import 'nota_fire.dart';
import 'pendiente_fire.dart';
import 'referencia_fire.dart';

const int firebaseTimeout = 60;

final GetOptions options = GetOptions(source: Source.serverAndCache);

class FireConstants {
  static Future<bool> sendServer(
      {required ContactoModelo contacto,
      required List<ReferenciaModelo> referencia,
      required List<NotaModel> notas,
      required String empleado,
      required Future<void> Function() send}) async {
    var sqlContacto = await ContactoController.getItemId(id: contacto.id!);
    debugPrint(
        "${sqlContacto?.estado} - ${sqlContacto?.empleadoEstado}\n${(sqlContacto?.empleadoEstado == null || sqlContacto?.empleadoEstado == empleado) && (sqlContacto?.estado != null || sqlContacto?.estado != -1)}");
    var zonasTemp = await MapFun.checkPointWithZona(
        point:
            LatLng((sqlContacto?.latitud ?? 0), (sqlContacto?.longitud ?? 0)));
    var data = sqlContacto!.copyWith(
        zonas: zonasTemp.map((e) => e.id!).toList(),
        pendiente: 0,
        empleadoEstado: ((sqlContacto.empleadoEstado == null ||
                    sqlContacto.empleadoEstado == empleado) &&
                (sqlContacto.estado != null && sqlContacto.estado != -1))
            ? empleado
            : sqlContacto.empleadoEstado,empleadoId: empleado,
        aceptadoEmpleado: empleado);
    debugPrint("empleadoEstado: ${data.empleadoEstado}");
    var result = await ContactoFire.sendItem(
        data: data,
        table: "id",
        query: contacto.id.toString(),
        itsNumber: true);
    if (!result) return false;

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
    showToast("Contacto enviado correctamente");
    return true;
  }

  static Future<bool> pendienteServer(
      {required ContactoModelo cont,
      required List<ReferenciaModelo> referencia,
      required List<NotaModel> notas,
      required String empleado,
      required Future<void> Function() send}) async {
    var sqlContacto = await ContactoController.getItemId(id: cont.id!);
    var zonasTemp = await MapFun.checkPointWithZona(
        point:
            LatLng((sqlContacto?.latitud ?? 0), (sqlContacto?.longitud ?? 0)));
    var data = sqlContacto!.copyWith(
        zonas: zonasTemp.map((e) => e.id!).toList(),
        pendiente: 0,
        empleadoEstado: ((sqlContacto.empleadoEstado == null ||
                    sqlContacto.empleadoEstado == empleado) &&
                (sqlContacto.estado != null && sqlContacto.estado != -1))
            ? empleado
            : sqlContacto.empleadoEstado,empleadoId: empleado,
        aceptadoEmpleado: empleado);
    debugPrint("empleadoEstado: ${data.empleadoEstado}");
    referencia = referencia.map((e) => e.copyWith(estatus: 1)).toList();
    notas = notas.map((e) => e.copyWith(pendiente: 1)).toList();

    PendienteModel pendiente = PendienteModel(
        id: Textos.randomWord(6),
        empleadoId: empleado,
        fechaPendiente: DateTime.now(),
        sincronizado: 0,
        aceptadoEmpleadoId: null,
        fechaSincronizado: null,
        notasGuia: null,
        contactos: [data],
        referencias: referencia,
        notas: notas);
    var result =
        await PendienteFire.sendItem(data: pendiente, query: pendiente.id);
    if (!result) return false;

    await ContactoController.update(data);
    for (var item in referencia) {
      await ReferenciasController.update(item);
    }

    for (var item in notas) {
      await NotasController.update(item);
    }
    await send();
    return true;
  }
}
