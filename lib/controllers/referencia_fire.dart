import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/referencia_model.dart';

import '../utilities/textos.dart';

class ReferenciaFire {
  static final db = FirebaseFirestore.instance;
  static String name = "referencias";

  static Future<String?> getDocId({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.id;
  }

  static Future<List<ReferenciaModelo>> getItems() async {
    final querySnapshot = await db.collection(name).get();
    List<ReferenciaModelo> model = [];
    for (var element in querySnapshot.docs) {
      model.add(ReferenciaModelo.fromJson(element.data()));
    }
    return model;
  }

  static Future<ReferenciaModelo?> getItem({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return ReferenciaModelo.fromJson(querySnapshot.docs.first.data());
  }

  static Future<bool> send({required ReferenciaModelo referencia}) async {
    var data = await getItem(id: referencia.id);
    if (data == null) {
      var rdm = Textos.randomWord(30);
      await db.collection(name).doc(rdm).set(referencia.toJson());
      return true;
    } else {
      var docId = await getDocId(id: referencia.id);
      if (docId == null) return false;
      await db.collection(name).doc(docId).update(referencia.toJson());
      return true;
    }
  }
}