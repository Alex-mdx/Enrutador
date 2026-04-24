import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

import 'contacto_controller.dart';
import 'usuario_controller.dart';

class SqlGenerator {
  static Future<void> aads() async {
    var db = await ContactoController.database();
    await SqlGenerator.existColumna(
        add: "aceptado_empleado", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "pendiente", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "empleado_id", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "status", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "creado", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "modificado", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "empleado_foto", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "empleado_foto_referencia", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "empleado_domicilio", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "empleado_numero", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "empleado_otro_num", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "empleado_tipo", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "empleado_estado", database: db, nombreDB: "contacto");
    await SqlGenerator.existColumna(
        add: "sincronizado", database: db, nombreDB: "contacto");
    var db2 = await UsuarioController.database();
    await SqlGenerator.existColumna(
        add: "children", database: db2, nombreDB: "usuario");
    await SqlGenerator.existColumna(
        add: "foto", database: db2, nombreDB: "usuario");
  }

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
