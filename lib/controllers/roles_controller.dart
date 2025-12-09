import 'package:enrutador/models/roles_model.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart' as sql;

String nombreDB = "roles";

class RolesController {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        icon INTEGER,
        color INTEGER,
        tipo INTEGER,
        creacion TEXT,
        actualizacion TEXT
      )""");
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase('app_$nombreDB.db',
        version: 1,
        onCreate: (db, ver) => createTables(db),
        onUpgrade: (db, oldVersion, newVersion) => createTables(db));
  }

  static Future<void> insert(RolesModel data) async {
    final db = await database();
    var existencia = await getId(data.id ?? -1);
    if (existencia == null) {
      await db.insert(
          nombreDB,
          data
              .copyWith(creacion: DateTime.now(), actualizacion: DateTime.now())
              .toJson(),
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
      debugPrint("ingreso");
    } else {
      await update(data);
      debugPrint("actualizo");
    }
  }

  static Future<List<RolesModel>> getAll() async {
    final db = await database();
    final query = await db.query(nombreDB, orderBy: "id DESC");
    debugPrint("$query");
    return query.map((e) => RolesModel.fromJson(e)).toList();
  }

  static Future<RolesModel?> getId(int id) async {
    final db = await database();
    final query = (await db.query(nombreDB, where: "id = ?", whereArgs: [id]))
        .firstOrNull;
    debugPrint("$query");
    return query == null ? null : RolesModel.fromJson(query);
  }

  static Future<void> deleteItem(int id) async {
    final db = await database();
    await db.delete(nombreDB, where: "id = ?", whereArgs: [id]);
  }

  static Future<void> update(RolesModel data) async {
    final db = await database();
    await db.update(
        nombreDB, data.copyWith(actualizacion: DateTime.now()).toJson(),
        where: "id = ?",
        whereArgs: [data.id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }
}
