import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/tipos_model.dart';

import '../../utilities/textos.dart';

class TipoFire {
  static final db = FirebaseFirestore.instance;
  static String name = "tipo";

  static Future<String?> getDocId({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.id;
  }

  static Future<List<TiposModelo>> getItems() async {
    final querySnapshot = await db.collection(name).get();
    if (querySnapshot.docs.isEmpty) return [];
    return querySnapshot.docs.map((e) => TiposModelo.fromJson(e.data())).toList();
  }

  static Future<TiposModelo?> getItem({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return TiposModelo.fromJson(querySnapshot.docs.first.data());
  }

  static Future<bool> send({required TiposModelo tipo}) async {
    try {
      var data = await getItem(id: tipo.id).timeout(const Duration(seconds: 15));
      if (data == null) {
        var rdm = Textos.randomWord(30);
        await db.collection(name).doc(rdm).set(tipo.toJson()).timeout(const Duration(seconds: 15));
        return true;
      } else {
        var docId = await getDocId(id: tipo.id).timeout(const Duration(seconds: 15));
        if (docId == null) return false;
        await db.collection(name).doc(docId).update(tipo.toJson()).timeout(const Duration(seconds: 15));
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
