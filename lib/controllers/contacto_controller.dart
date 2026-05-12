import 'package:enrutador/controllers/referencias_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

import '../utilities/textos.dart';

String nombreDB = "contacto";

class ContactoController {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre_completo TEXT,
          latitud REAL,
          longitud REAL,
          domicilio TEXT,
          fecha_domicilio TEXT,
          numero INTEGER,
          numero_fecha TEXT,
          otro_numero INTEGER,
          otro_numero_fecha TEXT,
          agendar TEXT,
          tipo INTEGER,
          tipo_fecha TEXT,
          zonas INTEGER,
          estado INTEGER,
          estado_fecha TEXT,
          foto TEXT,
          foto_fecha TEXT,
          foto_referencia TEXT,
          foto_referencia_fecha TEXT,
          empleado_foto TEXT,
          empleado_foto_referencia TEXT,
          empleado_domicilio TEXT,
          empleado_numero TEXT,
          empleado_otro_num TEXT,
          empleado_tipo TEXT,
          empleado_estado TEXT,
          what_3_words TEXT,
          nota TEXT,
          empleado_id TEXT,
          status INTEGER,
          pendiente INTEGER,
          aceptado_empleado TEXT,
          creado TEXT,
          modificado TEXT,
          uuid TEXT,
          sincronizado INTEGER
      )""");
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase('app_categoria.db',
        version: 1,
        onCreate: (db, ver) => createTables(db),
        onUpgrade: (db, oldVersion, newVersion) => createTables(db));
  }

  static Future<void> insert(ContactoModelo data) async {
    final db = await database();

    await db.insert(nombreDB, data.toJson(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> update(ContactoModelo data) async {
    final db = await database();
    var ref = await ReferenciasController.getIdPrin(
        idContacto: data.id, lat: null, lng: null);
    for (var element in ref) {
      var modify = element.copyWith(
          contactoIdLat: data.latitud, contactoIdLng: data.longitud);
      await ReferenciasController.update(modify);
    }
    var refR = await ReferenciasController.getIdR(
        idRContacto: data.id, lat: null, lng: null);
    for (var element in refR) {
      var modify = element.copyWith(
          contactoIdRLat: data.latitud, contactoIdRLng: data.longitud);
      await ReferenciasController.update(modify);
    }

    await db.update(nombreDB, data.toJson(),
        where: "(latitud = ? AND longitud = ?) OR id = ?",
        whereArgs: [data.latitud, data.longitud, data.id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<ContactoModelo?> getItem(
      {required double lat, required double lng, int? id}) async {
    final db = await database();
    final modelo = (await db.query(nombreDB,
            where: "(latitud = ? AND longitud = ?) OR id = ?",
            whereArgs: [lat, lng, id],
            orderBy: "id DESC"))
        .firstOrNull;

    return modelo == null ? null : ContactoModelo.fromJson(modelo);
  }

  static Future<ContactoModelo?> getItemId({required int id}) async {
    final db = await database();
    final modelo = (await db.query(nombreDB,
            where: "id = ?", whereArgs: [id], orderBy: "id DESC"))
        .firstOrNull;

    return modelo == null ? null : ContactoModelo.fromJson(modelo);
  }

  static Future<List<ContactoModelo>> getItembyAgenda(
      {required DateTime now}) async {
    final db = await database();
    final modelo = (await db.query(nombreDB,
        where: "agendar = ?",
        whereArgs: [Textos.fechaYMD(fecha: now)],
        columns: [
          "id",
          "latitud",
          "longitud",
          "agendar",
          "tipo",
          "estado",
          "nombre_completo"
        ],
        orderBy: "id DESC"));
    List<ContactoModelo> model = [];
    for (var element in modelo) {
      model.add(ContactoModelo.fromJson(element));
    }
    return model;
  }

  static Future<int> getCountPendiente() async {
    final db = await database();
    final result = await db.query(nombreDB,
        orderBy: "modificado DESC",
        columns: ["pendiente"],
        where: "pendiente IS NULL OR pendiente = 1");
    return result.length;
  }

  static Future<List<ContactoModelo>> getPendientes() async {
    final db = await database();
    final result = await db.query(nombreDB,
        where: "pendiente IS NULL OR pendiente = 1",
        limit: 50,
        orderBy: "modificado DESC");
    List<ContactoModelo> model = [];
    for (var element in result) {
      model.add(ContactoModelo.fromJson(element));
    }
    return model;
  }

  static Future<List<ContactoModelo>> getPersonalizado(
      {required String query,
      String? orderBy,
      List<String>? columns,
      int? limit}) async {
    final db = await database();
    final result = await db.rawQuery(
        "SELECT ${columns?.join(",") ?? "*"} FROM $nombreDB WHERE $query ${orderBy != null ? "ORDER BY $orderBy" : ""} ${limit != null ? "LIMIT $limit" : ""}");
    List<ContactoModelo> model = [];
    for (var element in result) {
      model.add(ContactoModelo.fromJson(element));
    }
    return model;
  }

  static Future<List<ContactoModelo>> getItems(double? zoom) async {
    final db = await database();
    List<String> query = [];
    if (zoom! < 15) {
      query = ["id", "latitud", "longitud"];
    } else {
      query = ["id", "latitud", "longitud", "tipo", "estado"];
    }
    final modelo = (await db.query(nombreDB, columns: query));
    List<ContactoModelo> model = [];
    for (var element in modelo) {
      model.add(ContactoModelo.fromJson(element));
    }
    var newModelfiltro1 = Preferences.tipos.isEmpty
        ? model
        : model
            .where((element) =>
                Preferences.tipos.contains(element.tipo.toString()))
            .toList();
    var newModelfiltro2 = Preferences.status.isEmpty
        ? newModelfiltro1
        : newModelfiltro1
            .where((element) =>
                Preferences.status.contains(element.estado.toString()))
            .toList();

    return newModelfiltro2;
  }

  static Future<List<ContactoModelo>> getAll() async {
    final db = await database();
    final modelo = (await db.query(nombreDB));
    List<ContactoModelo> model = [];
    for (var element in modelo) {
      model.add(ContactoModelo.fromJson(element));
    }

    return model;
  }

  static Future<List<ContactoModelo>> getItemsAll(
      {required String? nombre, required int limit, required int? page}) async {
    final db = await database();
    final modelo = (await db.query(nombreDB,
        where: nombre == "" || nombre == null || buildQueryFiltros().isEmpty
            ? null
            : "(nombre_completo LIKE ? OR numero LIKE ? OR otro_numero LIKE ?) ${buildQueryFiltros().isNotEmpty ? "AND ${buildQueryFiltros()}" : ""}",
        whereArgs: nombre == "" || nombre == null
            ? null
            : ['%$nombre%', '%$nombre%', '%$nombre%'],
        columns: [
          "id",
          "latitud",
          "longitud",
          "tipo",
          "estado",
          "nombre_completo",
          "tipo_fecha",
          "estado_fecha",
          "domicilio",
          "numero",
          "otro_numero",
          "pendiente",
          "creado"
        ],
        orderBy:
            "${Preferences.agruparFilt == 0 ? "nombre_completo" : Preferences.vaciosFilt ? Preferences.tiposFilt == 1 ? "tipo_fecha" : "estado_fecha" : "creado"} ${Preferences.ordenFilt ? "DESC" : "ASC"}",
        limit: limit,
        offset: ((page ?? 1) - 1) * limit));
    List<ContactoModelo> model = [];
    for (var element in modelo) {
      model.add(ContactoModelo.fromJson(element));
    }
    return buildList(model);
  }

  static Future<List<ContactoModelo>> buscar(String word, int? limit) async {
    final db = await database();
    List<ContactoModelo> contactoModelo = [];

    List<Map<String, dynamic>> categoria = await db.query(nombreDB,
        where: "nombre_completo LIKE ? OR numero LIKE ? OR otro_numero LIKE ?",
        orderBy: "nombre_completo ASC",
        columns: [
          "id",
          "latitud",
          "longitud",
          "tipo",
          "estado",
          "nombre_completo",
          "numero",
          "otro_numero"
        ],
        whereArgs: ['%$word%', '%$word%', '%$word%'],
        limit: limit ?? 10);
    for (var element in categoria) {
      contactoModelo.add(ContactoModelo.fromJson(element));
    }
    return contactoModelo;
  }

  static Future<void> deleteItem(int id) async {
    final db = await database();
    var ref = await ReferenciasController.getIdPrin(
        idContacto: id, lat: null, lng: null);
    for (var element in ref) {
      await ReferenciasController.deleteItem(id: element.id);
    }
    var refR = await ReferenciasController.getIdR(
        idRContacto: id, lat: null, lng: null);
    for (var element in refR) {
      await ReferenciasController.deleteItem(id: element.id);
    }
    await db.delete(nombreDB, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> getTotalRegistros() async {
    final db = await database();
    var resultado = await db.rawQuery(
        'SELECT COUNT(*) as total FROM $nombreDB ${buildQueryFiltros().isNotEmpty ? "WHERE ${buildQueryFiltros()}" : ""}');
    return resultado.first['total'] as int;
  }

  static Future<void> deleteItemByltlng(
      {required double lat, required double lng}) async {
    final db = await database();
    await db.delete(nombreDB,
        where: "latitud = ? AND longitud = ?", whereArgs: [lat, lng]);
  }

  static Future<void> deleteAll() async {
    final db = await database();
    await db.delete(nombreDB);
  }

  static String buildQueryFiltros() {
    String vacios = Preferences.tiposFilt == 0
        ? Preferences.vaciosFilt
            ? "nombre_completo IS NOT NULL"
            : ""
        : Preferences.tiposFilt == 1
            ? Preferences.vaciosFilt
                ? "tipo IS NOT NULL AND tipo_fecha IS NOT NULL"
                : ""
            : Preferences.vaciosFilt
                ? "estado IS NOT NULL AND estado_fecha IS NOT NULL"
                : "";
    debugPrint("vacios $vacios");
    vacios =
        "$vacios${(Preferences.pendientesFilt ? " AND (pendiente IS NULL OR pendiente = 1)" : "")}";
    debugPrint("vacios $vacios");
    return vacios;
  }

  static List<ContactoModelo> buildList(List<ContactoModelo> model) {
    var newModelfiltro1 = Preferences.tipos.isEmpty
        ? model
        : model
            .where((element) =>
                Preferences.tipos.contains(element.tipo.toString()))
            .toList();
    var newModelfiltro2 = Preferences.status.isEmpty
        ? newModelfiltro1
        : newModelfiltro1
            .where((element) =>
                Preferences.status.contains(element.estado.toString()))
            .toList();
    return newModelfiltro2;
  }
}
