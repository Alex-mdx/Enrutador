import 'package:enrutador/controllers/sql_generator.dart';
import 'package:enrutador/models/referencia_model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

String nombreDB = "referencias";

class ReferenciasController {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_foranea INTEGER,
          id_r_forenea INTEGER,
          contacto_id_lat INTEGER,
          contacto_id_lng INTEGER,
          contacto_id_r_lat INTEGER,
          contacto_id_r_lng INTEGER,
          buscar INTEGER,
          tipo_cliente INTEGER,
          estatus INTEGER,
          fecha TEXT
      )""");
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase('app_$nombreDB.db',
        version: 1,
        onCreate: (db, ver) => createTables(db),
        onUpgrade: (db, oldVersion, newVersion) => createTables(db));
  }

  static Future<void> insert(ReferenciaModelo data) async {
    final db = await database();
    var existencia = await getId(data);
    await SqlGenerator.existColumna(
        add: "rol_id", database: db, nombreDB: nombreDB);
    if (existencia == null) {
      await db.insert(nombreDB, data.toJson(),
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
      debugPrint("ingreso");
    } else {
      await update(data);
      debugPrint("actualizo");
    }
  }

  static Future<void> update(ReferenciaModelo data) async {
    final db = await database();
    await SqlGenerator.existColumna(
        add: "rol_id", database: db, nombreDB: nombreDB);
    await db.update(nombreDB, data.toJson(),
        where: "id = ? OR (id_foranea = ? AND id_r_forenea = ?)",
        whereArgs: [data.id, data.idForanea, data.idRForenea],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  

  static Future<List<ReferenciaModelo>> getItems({int? long, int? estatus}) async {
    final db = await database();
    final query = await db.query(nombreDB, limit: long, where: estatus != null ? "estatus = ?" : "", whereArgs: [estatus]);
    List<ReferenciaModelo> modelo = [];
    for (var element in query) {
      modelo.add(ReferenciaModelo.fromJson(element));
    }
    return modelo;
  }

  static Future<ReferenciaModelo?> getId(ReferenciaModelo data) async {
    final db = await database();
    final query = (await db.query(nombreDB,
            where: "id = ? OR (id_foranea = ? AND id_r_forenea = ?)",
            whereArgs: [data.id, data.idForanea, data.idRForenea]))
        .firstOrNull;
    debugPrint("$query");
    return query == null ? null : ReferenciaModelo.fromJson(query);
  }

  static Future<List<ReferenciaModelo>> getIdPrin(
      {required int? idContacto,
      required double? lat,
      required double? lng,
      int? status}) async {
    final db = await database();
    final query = await db.query(nombreDB,
        where:
            "id_foranea = ? OR (contacto_id_lat = ? AND contacto_id_lng = ?) ${status != null ? "AND estatus = ?" : ""}",
        whereArgs: [idContacto, lat, lng, status]);
    List<ReferenciaModelo> modelo = [];
    for (var element in query) {
      modelo.add(ReferenciaModelo.fromJson(element));
    }
    return modelo;
  }

  static Future<List<ReferenciaModelo>> getIdR(
      {required int? idRContacto,
      required double? lat,
      required double? lng,
      int? status}) async {
    final db = await database();
    final query = await db.query(nombreDB,
        where:
            "id_r_forenea = ? OR (contacto_id_r_lat = ? AND contacto_id_r_lng = ?) ${status != null ? "AND estatus = ?" : ""}",
        whereArgs: [idRContacto, lat, lng, status]);
    List<ReferenciaModelo> modelo = [];
    for (var element in query) {
      modelo.add(ReferenciaModelo.fromJson(element));
    }
    return modelo;
  }

  static Future<void> deleteItem({required int? id}) async {
    final db = await database();
    await db.delete(nombreDB, where: "id = ?", whereArgs: [id]);
  }
}
