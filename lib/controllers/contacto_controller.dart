import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

import '../utilities/textos.dart';

String nombreDB = "contacto";

class ContactoController {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre_completo INTEGER,
          latitud INTEGER,
          longitud INTEGER,
          domicilio TEXT,
          fecha_domicilio INTEGER,
          numero INTEGER,
          numero_fecha INTEGER,
          otro_numero INTEGER,
          otro_numero_fecha INTEGER,
          agendar INTEGER,
          contacto_enlances INTEGER,
          tipo INTEGER,
          tipo_fecha INTEGER,
          estado INTEGER,
          estado_fecha INTEGER,
          foto TEXT,
          foto_fecha INTEGER,
          foto_referencia TEXT,
          foto_referencia_fecha INTEGER,
          what_3_words TEXT,
          nota TEXT,
          plus_code TEXT
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
    debugPrint("$modelo");

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
          "contacto_enlances",
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

  static Future<List<ContactoModelo>> getItems() async {
    final db = await database();
    final modelo = (await db.query(nombreDB, columns: [
      "latitud",
      "longitud",
      "contacto_enlances",
      "tipo",
      "estado"
    ]));
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
    String vacios = Preferences.tiposFilt == 0
        ? "nombre_completo IS NOT NULL"
        : Preferences.tiposFilt == 1
            ? "tipo IS NOT NULL AND tipo_fecha IS NOT NULL"
            : "estado IS NOT NULL AND estado_fecha IS NOT NULL";
    final db = await database();
    final modelo = (await db.query(nombreDB,
        where: nombre == "" || nombre == null
            ? Preferences.vaciosFilt
                ? vacios
                : null
            : "(nombre_completo LIKE ? OR numero LIKE ? OR otro_numero LIKE ?) ${Preferences.vaciosFilt ? "AND $vacios" : ""}",
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
          "estado_fecha"
        ],
        orderBy:
            "${Preferences.agruparFilt == 0 ? "nombre_completo" : Preferences.tiposFilt == 1 ? "tipo_fecha" : "estado_fecha"} ${Preferences.ordenFilt ? "DESC" : "ASC"}",
        limit: limit,
        offset: ((page ?? 1) - 1) * limit));
    List<ContactoModelo> model = [];
    for (var element in modelo) {
      model.add(ContactoModelo.fromJson(element));
    }
    var newModelfiltro1 = Preferences.tipos.isEmpty
        ? model
            .where((element) =>
                Preferences.tiposFilt == 1 ? (element.tipo ?? -1) > -1 : true)
            .toList()
        : model
            .where((element) =>
                Preferences.tipos.contains(element.tipo.toString()))
            .toList();
    var newModelfiltro2 = Preferences.status.isEmpty
        ? newModelfiltro1
            .where((element) =>
                Preferences.tiposFilt == 2 ? (element.estado ?? -1) > -1 : true)
            .toList()
        : newModelfiltro1
            .where((element) =>
                Preferences.status.contains(element.estado.toString()))
            .toList();

    return newModelfiltro2;
  }

  static Future<List<ContactoModelo>> buscar(String word, int? limit) async {
    final db = await database();
    List<ContactoModelo> contactoModelo = [];

    List<Map<String, dynamic>> categoria = await db.query(nombreDB,
        where: "nombre_completo LIKE ? OR numero LIKE ? OR otro_numero LIKE ?",
        orderBy: "nombre_completo ASC",
        whereArgs: ['%$word%', '%$word%', '%$word%'],
        limit: limit ?? 10);
    for (var element in categoria) {
      contactoModelo.add(ContactoModelo.fromJson(element));
    }
    return contactoModelo;
  }

  static Future<void> deleteItem(int id) async {
    final db = await database();
    await db.delete(nombreDB, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> getTotalRegistros() async {
    final db = await database();
    var resultado =
        await db.rawQuery('SELECT COUNT(*) as total FROM $nombreDB');
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
}
