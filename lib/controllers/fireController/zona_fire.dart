import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/zona_model.dart';
import '../../utilities/textos.dart';

class ZonasFire {
  static final db = FirebaseFirestore.instance;
  static String name = "zonas";

  static Future<String?> getDocId({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.id;
  }

  static Future<List<ZonasModel>> getItems() async {
    final querySnapshot = await db.collection(name).get();
    if (querySnapshot.docs.isEmpty) return [];
    return querySnapshot.docs.map((e) => ZonasModel.fromJson(e.data())).toList();
  }

  static Future<ZonasModel?> getItem({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return ZonasModel.fromJson(querySnapshot.docs.first.data());
  }

  static Future<bool> send({required ZonasModel zona}) async {
    try {
      var data = await getItem(id: zona.id).timeout(const Duration(seconds: 15));
      if (data == null) {
        var rdm = Textos.randomWord(30);
        await db.collection(name).doc(rdm).set(zona.toJson()).timeout(const Duration(seconds: 15));
        return true;
      } else {
        var docId = await getDocId(id: zona.id).timeout(const Duration(seconds: 15));
        if (docId == null) return false;
        await db.collection(name).doc(docId).update(zona.toJson()).timeout(const Duration(seconds: 15));
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> delete({required ZonasModel zona}) async {
    try {
      var data = await getItem(id: zona.id).timeout(const Duration(seconds: 15));
      if (data == null) return false;
      var docId = await getDocId(id: zona.id).timeout(const Duration(seconds: 15));
      if (docId == null) return false;
      await db.collection(name).doc(docId).delete().timeout(const Duration(seconds: 15));
      return true;
    } catch (e) {
      return false;
    }
  }
}
