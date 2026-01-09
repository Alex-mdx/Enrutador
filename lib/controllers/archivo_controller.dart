import 'package:sqflite/sqflite.dart' as sql;

import '../models/archivo_model.dart';

var nombreDB = "archivo";

class ArchivoController {
  static Future<void> create(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contacto_id INTEGER,
        nombre TEXT,
        archivo TEXT,
        actualizacion TEXT
      )""");
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase('app_$nombreDB.db',
        version: 1,
        onCreate: (db, ver) => create(db),
        onUpgrade: (db, oldVersion, newVersion) => create(db));
  }

  static Future<void> insert(ArchivoModel data) async {
    final db = await database();

    await db.insert(nombreDB, data
              .copyWith(actualizacion: DateTime.now())
              .toJson(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> update(ArchivoModel data) async {
    final db = await database();
    await db.update(nombreDB, data.copyWith(actualizacion: DateTime.now()).toJson(),
        where: "id = ?",
        whereArgs: [data.id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<ArchivoModel>> getAll() async {
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query(nombreDB);
    return maps.map((x) => ArchivoModel.fromJson(x)).toList();
  }

  static Future<ArchivoModel?> getId(int id) async {
    final db = await database();
    final Map<String, dynamic> maps = (await db.query(nombreDB,
        where: "id = ?", whereArgs: [id])).first;
    return  maps.isNotEmpty ? ArchivoModel.fromJson(maps) : null;
  }

  static Future<List<ArchivoModel>> getAllByContactoId(int contactoId) async {
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query(nombreDB,
        where: "contacto_id = ?", whereArgs: [contactoId]);
    return maps.map((x) => ArchivoModel.fromJson(x)).toList();
  }

  static Future<void> delete(int id) async {
    final db = await database();
    await db.delete(nombreDB, where: "id = ?", whereArgs: [id]);
  }
}
