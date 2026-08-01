import 'fire_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:oktoast/oktoast.dart';

import '../../utilities/textos.dart';

class NotaFire {
  static final db = FirebaseFirestore.instance;
  static String name = "notas";

  static Future<String?> getDocId(
      {required int? id, List<Filter>? filters, int max = 50}) async {
    Query<Map<String, dynamic>> query = db.collection(name);
    if (filters != null && filters.isNotEmpty) {
      for (var f in filters) {
        query = query.where(f);
      }
    }
    query = query.orderBy("id").limit(max);
    final querySnapshot = await query
        .get(options)
        .timeout(const Duration(seconds: firebaseTimeout));
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

  static Future<List<NotaModel>> getItemPersonalizado(
      {int? id,
      List<Filter>? filters,
      int max = 50,
      String orderBy = "id",
      bool descending = false}) async {
    Query<Map<String, dynamic>> query = db.collection(name);
    if (id != null || (filters != null && filters.isNotEmpty)) {
      if (filters != null && filters.isNotEmpty) {
        for (var f in filters) {
          query = query.where(f);
        }
      } else if (id != null) {
        query = query.where("id", isEqualTo: id);
      }
    }
    query = query.orderBy(orderBy, descending: descending).limit(max);
    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => NotaModel.fromJson(doc.data()))
        .toList();
  }

  static Future<bool> send({required NotaModel nota}) async {
    try {
      var filtros = Filter.and(
          Filter("id", isEqualTo: nota.id),
          Filter("empleado_id", isEqualTo: nota.empleadoId),
          Filter("contacto_id", isEqualTo: nota.contactoId));
      var data = await getItemPersonalizado(filters: [
        filtros
      ]);
      if (data.isEmpty) {
        var rdm = Textos.randomWord(30);
        await db
            .collection(name)
            .doc(rdm)
            .set(nota.toFirestore())
            .timeout(const Duration(seconds: firebaseTimeout));
        return true;
      } else {
        var docId = await getDocId(id: nota.id, filters: [
          filtros
        ]);
        if (docId == null) return false;
        await db
            .collection(name)
            .doc(docId)
            .update(nota.toFirestore())
            .timeout(const Duration(seconds: firebaseTimeout));
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> delete({required NotaModel nota}) async {
    var filtros = Filter.and(
          Filter("id", isEqualTo: nota.id),
          Filter("empleado_id", isEqualTo: nota.empleadoId),
          Filter("contacto_id", isEqualTo: nota.contactoId));
    var data = await getItemPersonalizado(filters: [filtros]);
    if (data.isEmpty) {
      showToast("No se encontro la nota");
      return false;
    } else {
      var docId = await getDocId(id: nota.id, filters: [filtros]);
      if (docId == null) return false;
      await db.collection(name).doc(docId).delete();
      return true;
    }
  }
}
