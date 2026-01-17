import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/tipos_model.dart';

import '../utilities/textos.dart';

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

  static Future<TiposModelo?> getItem({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return TiposModelo.fromJson(querySnapshot.docs.first.data());
  }

  static Future<bool> send({required TiposModelo tipo}) async {
    var data = await getItem(id: tipo.id);
    if (data == null) {
      var rdm = Textos.randomWord(30);
      await db.collection(name).doc(rdm).set(tipo.toJson());
      return true;
    } else {
      var docId = await getDocId(id: tipo.id);
      if (docId == null) return false;
      await db.collection(name).doc(docId).update(tipo.toJson());
      return true;
    }
  }
}
