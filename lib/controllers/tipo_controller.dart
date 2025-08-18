import 'package:enrutador/models/tipos_model.dart';
import 'package:sqflite/sqflite.dart' as sql;

String nombreDB = "tipo";

class TipoController {
  static Future<void> create(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT,
          descripcion TEXT,
          icon INTEGER,
          color INTEGER
      )""");
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase('app_tipos.db',
        version: 1,
        onCreate: (db, ver) => create(db),
        onUpgrade: (db, oldVersion, newVersion) => create(db));
  }

  static Future<void> insert(TiposModelo data) async {
    final db = await database();

    await db.insert(nombreDB, data.toJson(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> update(TiposModelo data) async {
    final db = await database();
    await db.update(nombreDB, data.toJson(),
        where: "id = ?",
        whereArgs: [data.id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<TiposModelo?> getItem({required int data}) async {
    final db = await database();
    final modelo =
        (await db.query(nombreDB, where: "id = ?", whereArgs: [data], limit: 1))
            .firstOrNull;

    return modelo == null ? null : TiposModelo.fromJson(modelo);
  }

  static Future<List<TiposModelo>> getItems() async {
    final db = await database();
    final modelo = (await db.query(nombreDB));
    List<TiposModelo> model = [];
    for (var element in modelo) {
      model.add(TiposModelo.fromJson(element));
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
