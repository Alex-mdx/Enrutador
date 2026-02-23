import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:oktoast/oktoast.dart';

import '../utilities/textos.dart';

class NotaFire {
  static final db = FirebaseFirestore.instance;
  static String name = "notas";

  static Future<String?> getDocId({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.id;
  }

  static Future<List<NotaModel>> getItems() async {
    final querySnapshot = await db.collection(name).get();
    List<NotaModel> model = [];
    for (var element in querySnapshot.docs) {
      model.add(NotaModel.fromJson(element.data()));
    }
    return model;
  }

  static Future<NotaModel?> getItem({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return NotaModel.fromJson(querySnapshot.docs.first.data());
  }

  static Future<bool> send({required NotaModel nota}) async {
    var data = await getItem(id: nota.id);
    if (data == null) {
      var rdm = Textos.randomWord(30);
      await db.collection(name).doc(rdm).set(nota.toJson());
      return true;
    } else {
      var docId = await getDocId(id: nota.id);
      if (docId == null) return false;
      await db.collection(name).doc(docId).update(nota.toJson());
      return true;
    }
  }

  static Future<bool> delete({required NotaModel nota}) async {
    var data = await getItem(id: nota.id);
    if (data == null) {
      showToast("No se encontro la nota");
      return false;
    } else {
      var docId = await getDocId(id: nota.id);
      if (docId == null) return false;
      await db.collection(name).doc(docId).delete();
      return true;
    }
  }
}
