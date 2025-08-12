import 'dart:developer';

import 'package:enrutador/models/contacto_model.dart';
import 'package:flutter/material.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:sqflite/sqflite.dart' as sql;

import 'sql_generator.dart';

String nombreDB = "contacto";

class ContactoController {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $nombreDB(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre_completo nombreCompleto,
          latitud INTEGER,
          longitud INTEGER,
          domicilio TEXT,
          fecha_domicilio INTEGER,
          numero INTEGER,
          numero_fecha INTEGER,
          otro_numero INTEGER,
          otro_numero_fecha INTEGER,
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
          nota TEXT,
          plus_code TEXT
      )""");
  }

  static Future<void> insert(ContactoModelo data) async {
    final db = await SqlGenerator.database(tablas: createTables);

    await db.insert(nombreDB, data.toJson(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> update(ContactoModelo data) async {
    final db = await SqlGenerator.database(tablas: createTables);
    await db.update(nombreDB, data.toJson(),
        where: "latitud = ? AND longitud = ?",
        whereArgs: [data.latitud, data.longitud],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<ContactoModelo?> getItem(
      {required double lat, required double lng}) async {
    final db = await SqlGenerator.database(tablas: createTables);
    final modelo = (await db.query(nombreDB,
            where: "latitud = ? AND longitud = ?",
            whereArgs: [lat, lng],
            orderBy: "id DESC"))
        .firstOrNull;

    return modelo == null ? null : ContactoModelo.fromJson(modelo);
  }

  static Future<List<ContactoModelo>> getItems() async {
    final db = await SqlGenerator.database(tablas: createTables);
    final modelo = (await db.query(nombreDB,
        columns: ["latitud", "longitud", "contacto_enlances"]));
    List<ContactoModelo> model = [];
    for (var element in modelo) {
      model.add(ContactoModelo.fromJson(element));
    }
    return model;
  }

  static Future<List<ContactoModelo>> buscar(String word, int? limit) async {
    final db = await SqlGenerator.database(tablas: createTables);
    List<ContactoModelo> contactoModelo = [];

    List<Map<String, dynamic>> categoria = await db.query(nombreDB,
        where: "nombre_completo LIKE ? OR numero LIKE ? OR otro_numero LIKE ?",
        orderBy: "nombre_completo",
        whereArgs: ['%$word%', '%$word%', '%$word%'],
        limit: limit ?? 10);
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
