import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/estado_model.dart';

import '../utilities/textos.dart';

class EstadoFire {
  static final db = FirebaseFirestore.instance;
  static String name = "estado";

  static Future<String?> getDocId({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.id;
  }

  static Future<EstadoModel?> getItem({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return EstadoModel.fromJson(querySnapshot.docs.first.data());
  }

  static Future<bool> send({required EstadoModel estado}) async {
    var data = await getItem(id: estado.id);
    if (data == null) {
      var rdm = Textos.randomWord(30);
      await db.collection(name).doc(rdm).set(estado.toJson());
      return true;
    } else {
      var docId = await getDocId(id: estado.id);
      if (docId == null) return false;
      await db.collection(name).doc(docId).update(estado.toJson());
      return true;
    }
  }
}