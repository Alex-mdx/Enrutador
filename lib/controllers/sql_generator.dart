import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlGenerator {
  static Future<bool> existColumna(
      {required String add,
      required sql.Database database,
      required String nombreDB}) async {
    List<Map<String, dynamic>> columnas =
        await database.rawQuery('PRAGMA table_info($nombreDB)');

    for (Map<String, dynamic> columna in columnas) {
      String name = columna['name'];
      if (name == add) {
        //debugPrint('existe $columnaAdd');
        return true;
      }
    }
    debugPrint('agregando $add');
    await database.execute('ALTER TABLE $nombreDB ADD COLUMN $add INTEGER');
    return false;
  }


  static Future<bool> renombrar(
      {required String actual,
      required String nuevo,
      required sql.Database database,
      required String nombreDB}) async {
    List<Map<String, dynamic>> columnas =
        await database.rawQuery('PRAGMA table_info($nombreDB)');

    // Verificar si la columna actual existe
    bool columnaExiste = columnas.any((columna) => columna['name'] == actual);

    if (columnaExiste) {
      debugPrint('cambiando nombre "$actual" a "$nuevo"');
      await database
          .execute("""ALTER TABLE $nombreDB RENAME COLUMN $actual TO $nuevo""");
      return true;
    } else {
      debugPrint('no existe $actual');
      return false;
    }
  }

  static Future<void> logout() async {
    ///await GastosController.deleteAll();
    
  }
}
