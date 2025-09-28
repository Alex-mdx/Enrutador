import 'package:enrutador/models/estado_model.dart';
import 'package:sqflite/sqflite.dart' as sql;

String nombreDB = "estado";

class EstadoController {
  static Future<void> create(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT,
          descripcion TEXT,
          orden INTEGER,
          color INTEGER
      )""");
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase('app_$nombreDB.db',
        version: 1,
        onCreate: (db, ver) => create(db),
        onUpgrade: (db, oldVersion, newVersion) => create(db));
  }

  static Future<void> insert(EstadoModel data) async {
    final db = await database();

    await db.insert(nombreDB, data.toJson(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> update(EstadoModel data) async {
    final db = await database();
    await db.update(nombreDB, data.toJson(),
        where: "id = ?",
        whereArgs: [data.id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<EstadoModel?> getItem({required int data}) async {
    final db = await database();
    final modelo =
        (await db.query(nombreDB, where: "id = ?", whereArgs: [data], limit: 1))
            .firstOrNull;

    return modelo == null ? null : EstadoModel.fromJson(modelo);
  }

  static Future<List<EstadoModel>> getItems() async {
    final db = await database();
    final modelo = (await db.query(nombreDB,orderBy: "orden ASC"));
    List<EstadoModel> model = [];
    for (var element in modelo) {
      model.add(EstadoModel.fromJson(element));
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
