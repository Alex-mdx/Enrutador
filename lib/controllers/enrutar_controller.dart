import 'package:sqflite/sqflite.dart' as sql;

import '../models/enrutar_model.dart';

String nombreDB = "enrutar";

class EnrutarController {
  static Future<void> create(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          orden INTEGER,
          visitado INTEGER,
          contacto_id INTEGER,
          buscar INTEGER
      )""");
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase('app_$nombreDB.db',
        version: 1,
        onCreate: (db, ver) => create(db),
        onUpgrade: (db, oldVersion, newVersion) => create(db));
  }

  static Future<void> insert(EnrutarModelo data) async {
    final db = await database();

    await db.insert(nombreDB, data.toJson(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> update(EnrutarModelo data) async {
    final db = await database();
    await db.update(nombreDB, data.toJson(),
        where: "id = ?",
        whereArgs: [data.id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<EnrutarModelo?> getItem({required int data}) async {
    final db = await database();
    final modelo =
        (await db.query(nombreDB, where: "id = ?", whereArgs: [data], limit: 1))
            .firstOrNull;

    return modelo == null ? null : EnrutarModelo.fromJson(modelo);
  }

  static Future<EnrutarModelo?> getItemContacto({required int contactoId}) async {
    final db = await database();
    final modelo =
        (await db.query(nombreDB, where: "contacto_id = ?", whereArgs: [contactoId], limit: 1))
            .firstOrNull;

    return modelo == null ? null : EnrutarModelo.fromJson(modelo);
  }

  static Future<List<EnrutarModelo>> getItems() async {
    final db = await database();
    final modelo = (await db.query(nombreDB,orderBy: "orden ASC"));
    List<EnrutarModelo> model = [];
    for (var element in modelo) {
      model.add(EnrutarModelo.fromJson(element));
    }
    return model;
  }

  static Future<void> deleteItem(int id) async {
    final db = await database();
    await db.delete(nombreDB, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAll() async {
    final db = await database();
    await db.delete(nombreDB);
  }
}
