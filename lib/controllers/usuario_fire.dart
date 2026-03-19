import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/usuario_model.dart';

class UsuarioFire {
  static var db = FirebaseFirestore.instance;
  static String collection = "users";
  static Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getDoc(
      {required String table,
      required String query,
      bool itsNumber = false}) async {
    var data = await db
        .collection(collection)
        .where(table, isEqualTo: itsNumber ? int.tryParse(query) : query)
        .limit(1)
        .get();
    return data.docs.firstOrNull;
  }

  static Future<UsuarioModel?> getItem(
      {required String table,
      required String query,
      bool itsNumber = false}) async {
    var data = await db
        .collection(collection)
        .where(table, isEqualTo: itsNumber ? int.tryParse(query) : query)
        .limit(1)
        .get();
    var user = data.docs.firstOrNull == null
        ? null
        : UsuarioModel.fromJson(data.docs.firstOrNull!.data());
    return user;
  }

  static Future<List<UsuarioModel>> getItems(
      {required String table,
      required String query,
      bool itsNumber = false}) async {
    var data = await db
        .collection(collection)
        .where(table, isEqualTo: itsNumber ? int.tryParse(query) : query)
        .get();
    List<UsuarioModel> list = [];
    for (var item in data.docs) {
      list.add(UsuarioModel.fromJson(item.data()));
    }
    return list;
  }

  static Future<List<UsuarioModel>> getAllItems(
      {int limit = 50, int index = 0}) async {
    final baseRef = db.collection(collection);

    Query<Map<String, dynamic>> pageRef;

    if (index <= 0) {
      // Primera página: sin cursor usando solo el limite establecido
      pageRef = baseRef.limit(limit);
    } else {
      // Páginas siguientes: obtenemos el ultimo doc de la página previa
      final cursorSnap = await baseRef.limit(limit * index).get();

      if (cursorSnap.docs.isEmpty) {
        // El índice sale del rango, se devuelve vacío
        return [];
      }

      // Empezamos DESPUÉS del último documento del bloque anterior
      pageRef = baseRef.startAfterDocument(cursorSnap.docs.last).limit(limit);
    }

    final data = await pageRef.get();
    final list =
        data.docs.map((doc) => UsuarioModel.fromJson(doc.data())).toList();
    return list;
  }

  /// Retorna el número total de documentos en [collection].
  /// Usa la API de agregación de Firestore (no descarga los docs, es eficiente).
  static Future<int> countAll() async {
    final snapshot = await db.collection(collection).count().get();
    return snapshot.count ?? 0;
  }


  static Future<bool> updateItem(
      {required UsuarioModel data,
      String? table,
      String? query,
      bool itsNumber = false}) async {
    var doc = await db
        .collection(collection)
        .where(table ?? "uuid",
            isEqualTo: itsNumber
                ? int.tryParse(
                    query ?? FirebaseAuth.instance.currentUser?.uid ?? "")
                : query ?? FirebaseAuth.instance.currentUser?.uid)
        .limit(1)
        .get();
    var user = doc.docs.firstOrNull == null
        ? null
        : UsuarioModel.fromJson(doc.docs.firstOrNull!.data());
    debugPrint("${user?.toJson() ?? "nada"} - ${doc.docs.firstOrNull?.id}");
    if (user == null) return false;
    await db
        .collection(collection)
        .doc(doc.docs.first.id)
        .update(data.toJson());
    return true;
  }

  static Future<bool> sendItem(
      {required UsuarioModel data,
      String? table,
      String? query,
      bool itsNumber = false}) async {
    var doc = await db
        .collection(collection)
        .where(table ?? "uuid",
            isEqualTo: itsNumber
                ? int.tryParse(
                    query ?? FirebaseAuth.instance.currentUser?.uid ?? "")
                : query ?? FirebaseAuth.instance.currentUser?.uid)
        .limit(1)
        .get();
    var user = doc.docs.firstOrNull == null
        ? null
        : UsuarioModel.fromJson(doc.docs.firstOrNull!.data());
    if (user == null) return false;
    await db.collection(collection).doc(doc.docs.first.id).set(data.toJson());
    return true;
  }

  static Future<bool> itemStatus(
      {String? table, String? query, bool itsNumber = false}) async {
    var doc = await db
        .collection(collection)
        .where(table ?? "uuid",
            isEqualTo: itsNumber
                ? int.tryParse(
                    query ?? FirebaseAuth.instance.currentUser?.uid ?? "")
                : query ?? FirebaseAuth.instance.currentUser?.uid)
        .limit(1)
        .get();
    var user = doc.docs.firstOrNull == null
        ? null
        : UsuarioModel.fromJson(doc.docs.firstOrNull!.data());
    if (user == null) {
      return false;
    }
    await db
        .collection(collection)
        .doc(doc.docs.first.id)
        .update(user.copyWith(status: 0).toJson());
    return true;
  }

  static Future<bool> deleteItem(
      {String? table, String? query, bool itsNumber = false}) async {
    var doc = await db
        .collection(collection)
        .where(table ?? "uuid",
            isEqualTo: itsNumber
                ? int.tryParse(
                    query ?? FirebaseAuth.instance.currentUser?.uid ?? "")
                : query ?? FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (doc.docs.firstOrNull == null) return false;
    await db.collection(collection).doc(doc.docs.first.id).delete();
    return true;
  }
}
