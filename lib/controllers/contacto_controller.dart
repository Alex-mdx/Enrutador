import 'package:enrutador/models/contacto_model.dart';
import 'package:sqflite/sqflite.dart' as sql;

import 'sql_generator.dart';

String nombreDB = "contacto";

class ContactoController {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre_completo": nombreCompleto,
          latitud INTEGER,
          longitud INTEGER,
          domicilio TEXT,
          fecha_domicilio INTEGER,
          numero INTEGER,
          numero_fecha INTEGER,
          agendar INTEGER,
          contacto_enlances INTEGER,
          tipo INTEGER,
          tipo_fecha INTEGER,
          estado INTEGER,
          estado_fecha INTEGER,
          foto TEXT,
          foto_fecha INTEGER,
          foto_referencia TEXT,
          foto_referencia_fecha INTEGER,
          what_3_words TEXT,
          nota TEXT
      )""");
  }


  static Future<void> insert(ContactoModelo cate) async {
    final db = await SqlGenerator.database(tablas: createTables);
    await db.insert(nombreDB, cate.toJson(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<ContactoModelo?> getItem({required int id}) async {
    final db = await SqlGenerator.database(tablas: createTables);
    final categoria = (await db.query(nombreDB,
            where: "id = ?", whereArgs: [id], orderBy: "nombre"))
        .firstOrNull;

    return categoria == null ? null : ContactoModelo.fromJson(categoria);
  }

  static Future<List<ContactoModelo>> getItems() async {
    final db = await SqlGenerator.database(tablas: createTables);
    List<ContactoModelo> contactoModelo = [];
    List<Map<String, dynamic>> categoria =
        await db.query(nombreDB, orderBy: "nombre");
    for (var element in categoria) {
      contactoModelo.add(ContactoModelo.fromJson(element));
    }
    return contactoModelo;
  }

  static Future<List<ContactoModelo>> buscar(String word) async {
    final db = await SqlGenerator.database(tablas: createTables);
    List<ContactoModelo> contactoModelo = [];
    List<Map<String, dynamic>> categoria = await db.query(nombreDB,
        where: "nombre LIKE ?",
        whereArgs: ['%$word%'],
        orderBy: "nombre",
        limit: 10);
    for (var element in categoria) {
      contactoModelo.add(ContactoModelo.fromJson(element));
    }
    return contactoModelo;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SqlGenerator.database(tablas: createTables);
    await db.delete(nombreDB, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAll() async {
    final db = await SqlGenerator.database(tablas: createTables);
    await db.delete(nombreDB);
  }
}
