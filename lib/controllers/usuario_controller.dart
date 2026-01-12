import 'package:sqflite/sqflite.dart' as sql;

import '../models/usuario_model.dart';

class UsuarioController {
  static String nombreDB = "usuario";
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT,
          nombre TEXT,
          contacto_id INTEGER,
          empleado_id INTEGER,
          admin_tipo INTEGER,
          status INTEGER,
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

  static Future<void> insert(UsuarioModel data) async {
    final db = await database();
    var object = await getItem(data.id);
    if (object != null) {
      await updateItem(data.id, data);
    } else {
      await db.insert(nombreDB, data.toJson(),
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
    }
  }

  static Future<void> updateItem(int id, UsuarioModel data) async {
    final db = await database();
    await db.update(nombreDB, data.toJson(), where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteItem(int id) async {
    final db = await database();
    await db.delete(nombreDB, where: 'id = ?', whereArgs: [id]);
  }

  static Future<UsuarioModel?> getItem(int id) async {
    final db = await database();
    final result = await db.query(nombreDB, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? UsuarioModel.fromJson(result.first) : null;
  }
}
