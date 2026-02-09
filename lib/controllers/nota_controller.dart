import 'package:enrutador/models/nota_model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

String nombreDB = "notas";

class NotasController {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contacto_id INTEGER,
        descripcion TEXT,
        empleado_id TEXT,
        pendiente INTEGER,
        creado TEXT
      )""");
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase('app_$nombreDB.db',
        version: 1,
        onCreate: (db, ver) => createTables(db),
        onUpgrade: (db, oldVersion, newVersion) => createTables(db));
  }

  static Future<void> insert(NotaModel data) async {
    final db = await database();
    var existencia = await getId(data.id ?? -1);
    if (existencia == null) {
      await db.insert(nombreDB, data.copyWith(creado: DateTime.now()).toJson(),
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
      debugPrint("ingreso");
    } else {
      await update(data);
      debugPrint("actualizo");
    }
  }

  static Future<List<NotaModel>> getAll({int? long, int? pendiente, String? order}) async {
    final db = await database();
    final query = await db.query(nombreDB,
        orderBy: order ?? "id DESC", limit: long, where: pendiente != null ? "pendiente = ?" : "", whereArgs:pendiente == null ? null: [pendiente]);
    debugPrint("$query");
    return query.map((e) => NotaModel.fromJson(e)).toList();
  }

  static Future<List<NotaModel>> getContactoId(int contactoId,
      {int? pendiente, String? order}) async {
    final db = await database();
    final query = await db.query(nombreDB,
        where:
            "contacto_id = ? ${pendiente != null ? "AND pendiente = ?" : ""}",
        whereArgs: pendiente == null ? [contactoId] : [contactoId, pendiente],
        limit: 50, orderBy: order ?? "id DESC");
    List<NotaModel> notas = query.map((e) => NotaModel.fromJson(e)).toList();
    return notas;
  }

  static Future<NotaModel?> getId(int id) async {
    final db = await database();
    final query = (await db.query(nombreDB, where: "id = ?", whereArgs: [id]))
        .firstOrNull;
    debugPrint("$query");
    return query == null ? null : NotaModel.fromJson(query);
  }

  static Future<void> deleteItem(int id) async {
    final db = await database();
    await db.delete(nombreDB, where: "id = ?", whereArgs: [id]);
  }

  static Future<void> update(NotaModel data) async {
    final db = await database();
    await db.update(nombreDB, data.toJson(),
        where: "id = ?",
        whereArgs: [data.id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }
}
