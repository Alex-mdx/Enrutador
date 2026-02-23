import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/pendiente_model.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendienteFire {
  static var db = FirebaseFirestore.instance;

  static String name = "pendientes";

  static Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getDoc(
      {required String table,
      required String query,
      bool itsNumber = false}) async {
    var data = await db
        .collection(name)
        .where(table, isEqualTo: itsNumber ? int.tryParse(query) : query)
        .limit(1)
        .get();
    return data.docs.firstOrNull;
  }

  static Future<PendienteModel?> getItem(
      {required String table,
      required String query,
      bool itsNumber = false}) async {
    var data = await db
        .collection(name)
        .where(table, isEqualTo: itsNumber ? int.tryParse(query) : query)
        .limit(1)
        .get();
    var user = data.docs.firstOrNull == null
        ? null
        : PendienteModel.fromJson(data.docs.firstOrNull!.data());
    return user;
  }

  static Future<List<PendienteModel>> getItems(
      {required String table,
      required String query,
      bool itsNumber = false}) async {
    var data = await db
        .collection(name)
        .where(table, isEqualTo: itsNumber ? int.tryParse(query) : query)
        .get();
    List<PendienteModel> list = [];
    for (var item in data.docs) {
      list.add(PendienteModel.fromJson(item.data()));
    }
    return list;
  }

  static Future<List<PendienteModel>> getAllItems({int limit = 50}) async {
    var data = await db.collection(name).limit(limit).get();
    List<PendienteModel> list = [];
    for (var item in data.docs) {
      list.add(PendienteModel.fromJson(item.data()));
    }
    return list;
  }

  static Future<bool> sendItem(
      {required PendienteModel data,
      String? table,
      String? query,
      bool itsNumber = false}) async {
    var doc = await db
        .collection(name)
        .where(table ?? "id",
            isEqualTo: itsNumber
                ? int.tryParse(
                    query ?? FirebaseAuth.instance.currentUser?.uid ?? "")
                : query ?? FirebaseAuth.instance.currentUser?.uid)
        .limit(1)
        .get();
    var uuid = doc.docs.firstOrNull?.id ?? Textos.randomWord(30);
    await db.collection(name).doc(uuid).set(data.toJson());
    return true;
  }

  static Future<bool> deleteItem(
      {String? table, String? query, bool itsNumber = false}) async {
    var doc = await db
        .collection(name)
        .where(table ?? "id",
            isEqualTo: itsNumber
                ? int.tryParse(
                    query ?? FirebaseAuth.instance.currentUser?.uid ?? "")
                : query ?? FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (doc.docs.firstOrNull == null) return false;
    await db.collection(name).doc(doc.docs.first.id).delete();
    return true;
  }
}
