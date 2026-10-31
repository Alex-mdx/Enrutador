import 'package:sqflite/sqflite.dart' as sql;

import '../models/cartera_model.dart';

String nombreDB = "cartera";

class CarteraController {
  static Future<void> create(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
        codigo INTEGER,
        uuid TEXT,
        empleado_by TEXT,
        empleado_to TEXT,
        activo INTEGER,
        fecha_creado TEXT,
        fecha_actualizado TEXT,
        contactos TEXT
      )""");
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase('app_$nombreDB.db',
        version: 1,
        onCreate: (db, ver) => create(db),
        onUpgrade: (db, oldVersion, newVersion) => create(db));
  }

  static Future<void> insert(CarteraModel data) async {
    final db = await database();

    await db.insert(nombreDB, data.toJson());
  }

  static Future<void> update(CarteraModel data) async {
    final db = await database();
    await db.update(nombreDB, data.toJson(),
        where: "uuid = ?",
        whereArgs: [data.uuid],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<CarteraModel>> getItemEmpleadoTo(
      {required String empleado}) async {
    final db = await database();
    final modelo = (await db
        .query(nombreDB, where: "empleado_to = ?", whereArgs: [empleado]));
    List<CarteraModel> model = [];
    for (var element in modelo) {
      model.add(CarteraModel.fromJson(element));
    }
    return model;
  }

  static Future<List<CarteraModel>> getItemEmpleadoBy(
      {required String empleado}) async {
    final db = await database();
    final modelo = (await db
        .query(nombreDB, where: "empleado_by = ?", whereArgs: [empleado]));
    List<CarteraModel> model = [];
    for (var element in modelo) {
      model.add(CarteraModel.fromJson(element));
    }
    return model;
  }

  static Future<List<CarteraModel>> getItems() async {
    final db = await database();
    final modelo = (await db.query(nombreDB, orderBy: "fecha_creado ASC"));
    List<CarteraModel> model = [];
    for (var element in modelo) {
      model.add(CarteraModel.fromJson(element));
    }
    return model;
  }

  static Future<CarteraModel?> getItem({required String uuid}) async {
    final db = await database();
    final modelo =
        (await db.query(nombreDB, where: "uuid = ?", whereArgs: [uuid]));
    List<CarteraModel> model = [];
    for (var element in modelo) {
      model.add(CarteraModel.fromJson(element));
    }
    return model.firstOrNull;
  }

  static Future<void> deleteItem(String uuid) async {
    final db = await database();
    await db.delete(nombreDB, where: 'uuid = ?', whereArgs: [uuid]);
  }

  static Future<void> deleteAll() async {
    final db = await database();
    await db.delete(nombreDB);
  }
}
