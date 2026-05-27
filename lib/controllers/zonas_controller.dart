import 'package:sqflite/sqflite.dart' as sql;

import '../models/zona_model.dart';

class ZonasController {
  static var nombreDB = "zonas";
  static Future<void> create(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        notas TEXT,
        color INTEGER,
        latlongs INTEGER
      )""");
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase('app_$nombreDB.db',
        version: 1,
        onCreate: (db, ver) => create(db),
        onUpgrade: (db, oldVersion, newVersion) => create(db));
  }

  static Future<void> insert(ZonasModel data) async {
    final db = await database();
    var find = await getId(data.id);
    if (find == null) {
      await db.insert(nombreDB, data.toJson(),
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
    } else {
      await update(data);
    }
  }

  static Future<void> update(ZonasModel data) async {
    final db = await database();
    await db.update(nombreDB, data.toJson(),
        where: "id = ?",
        whereArgs: [data.id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<ZonasModel>> getAll() async {
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query(nombreDB);
    return maps.map((x) => ZonasModel.fromJson(x)).toList();
  }

  static Future<ZonasModel?> getId(int? id) async {
    if (id == null) return null;
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query(
        nombreDB, where: "id = ?", whereArgs: [id]);
    return maps.isEmpty ? null : ZonasModel.fromJson(maps.first);
  }

  static Future<void> delete(int id) async {
    final db = await database();
    await db.delete(nombreDB, where: "id = ?", whereArgs: [id]);
  }

  static Future<List<ZonasModel>> deleteAll() async {
    final db = await database();
    await db.delete(nombreDB);
    return [];
  }
}
