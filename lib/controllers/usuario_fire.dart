import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario_model.dart';

class UsuarioFire {
  static var db = FirebaseFirestore.instance;

  static Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getDoc(
      {required String table, required String query, bool itsNumber = false}) async {
    var data = await db
        .collection("users")
        .where(table, isEqualTo: itsNumber ? int.tryParse(query) : query)
        .limit(1)
        .get();
    return data.docs.firstOrNull;
  }

  static Future<UsuarioModel?> getItem(
      {required String table, required String query, bool itsNumber = false}) async {
    var data = await db
        .collection("users")
        .where(table, isEqualTo: itsNumber ? int.tryParse(query) : query)
        .limit(1)
        .get();
    var user = data.docs.firstOrNull == null
        ? null
        : UsuarioModel.fromJson(data.docs.firstOrNull!.data());
    return user;
  }

  static Future<List<UsuarioModel>> getItems(
      {required String table, required String query, bool itsNumber = false}) async {
    var data =
        await db.collection("users").where(table, isEqualTo: itsNumber ? int.tryParse(query) : query).get();
    List<UsuarioModel> list = [];
    for (var item in data.docs) {
      list.add(UsuarioModel.fromJson(item.data()));
    }
    return list;
  }

  static Future<List<UsuarioModel>> getAllItems({int limit = 50}) async {
    var data = await db.collection("users").limit(limit).get();
    List<UsuarioModel> list = [];
    for (var item in data.docs) {
      list.add(UsuarioModel.fromJson(item.data()));
    }
    return list;
  }

  static Future<bool> updateItem({required UsuarioModel data, String? table, String? query,bool itsNumber = false}) async {
    var doc = await db
        .collection("users")
        .where(table ??"uuid", isEqualTo: itsNumber ? int.tryParse(query ?? FirebaseAuth.instance.currentUser?.uid ?? "") : query ?? FirebaseAuth.instance.currentUser?.uid)
        .limit(1)
        .get();
    var user = doc.docs.firstOrNull == null
        ? null
        : UsuarioModel.fromJson(doc.docs.firstOrNull!.data());
    if (user == null) return false;
    await db.collection("users").doc(doc.docs.first.id).update(data.toJson());
    return true;
  }

    static Future<bool> sendItem({required UsuarioModel data, String? table, String? query, bool itsNumber = false}) async {
    var doc = await db
        .collection("users")
        .where(table ?? "uuid", isEqualTo: itsNumber ? int.tryParse(query ?? FirebaseAuth.instance.currentUser?.uid ?? "") : query ?? FirebaseAuth.instance.currentUser?.uid)
        .limit(1)
        .get();
    var user = doc.docs.firstOrNull == null
        ? null
        : UsuarioModel.fromJson(doc.docs.firstOrNull!.data());
    if (user == null) return false;
    await db.collection("users").doc(doc.docs.first.id).set(data.toJson());
    return true;
  }

  static Future<bool> itemStatus({String? table, String? query, bool itsNumber = false}) async {
    var doc = await db
        .collection("users")
        .where(table ?? "uuid", isEqualTo: itsNumber ? int.tryParse(query ?? FirebaseAuth.instance.currentUser?.uid ?? "") : query ?? FirebaseAuth.instance.currentUser?.uid)
        .limit(1)
        .get();
    var user = doc.docs.firstOrNull == null
        ? null
        : UsuarioModel.fromJson(doc.docs.firstOrNull!.data());
    if (user == null){ return false;}
    await db.collection("users").doc(doc.docs.first.id).update(user.copyWith(status: 0).toJson());
    return true;
  }

  static Future<bool> deleteItem({String? table, String? query, bool itsNumber = false}) async {
    var doc = await db
        .collection("users")
        .where(table ?? "uuid", isEqualTo: itsNumber ? int.tryParse(query ?? FirebaseAuth.instance.currentUser?.uid ?? "") : query ?? FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (doc.docs.firstOrNull == null) return false;
    await db.collection("users").doc(doc.docs.first.id).delete();
    return true;
  }
}
