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
    await db.update(nombreDB, data.toJson(),
        where: "id = ?",
        whereArgs: [data.id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<ReferenciaModelo>> getItems() async {
    final db = await database();
    final query = await db.query(nombreDB);
    List<ReferenciaModelo> modelo = [];
    for (var element in query) {
      modelo.add(ReferenciaModelo.fromJson(element));
    }
    return modelo;
  }

  static Future<ReferenciaModelo?> getId(ReferenciaModelo data) async {
    final db = await database();
    final query =
        (await db.query(nombreDB, where: "id = ?", whereArgs: [data.id]))
            .firstOrNull;
    return query == null ? null : ReferenciaModelo.fromJson(query);
  }

  static Future<List<ReferenciaModelo>> getIdPrin(ReferenciaModelo data) async {
    final db = await database();
    final query = await db.query(nombreDB,
        where: "id_foranea = ? OR (contacto_id_lat AND contacto_id_lng = ?)",
        whereArgs: [data.idForanea, data.contactoIdLat, data.contactoIdLng]);
    List<ReferenciaModelo> modelo = [];
    for (var element in query) {
      modelo.add(ReferenciaModelo.fromJson(element));
    }
    return modelo;
  }

  static Future<List<ReferenciaModelo>> getIdR(ReferenciaModelo data) async {
    final db = await database();
    final query = await db.query(nombreDB,
        where:
            "id_r_forenea = ? OR (contacto_id_r_lat = ? AND contacto_id_r_lng = ?)",
        whereArgs: [data.idForanea, data.contactoIdRLat, data.contactoIdRLng]);
    List<ReferenciaModelo> modelo = [];
    for (var element in query) {
      modelo.add(ReferenciaModelo.fromJson(element));
    }
    return modelo;
  }
}
