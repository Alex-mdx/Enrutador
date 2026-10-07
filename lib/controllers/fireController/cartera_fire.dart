import 'package:enrutador/models/cartera_model.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../../utilities/trans_fun.dart';
import 'fire_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/textos.dart';

/// Operadores de comparación disponibles para [PendienteFire.getCompareItems].
enum QueryOperator {
  equalTo,
  greaterThan,
  greaterThanOrEqualTo,
  lessThan,
  lessThanOrEqualTo
}

class CarteraFire {
  static var db = FirebaseFirestore.instance;

  static String name = "carteras";

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

  static Future<CarteraModel?> getItem({required int? id}) async {
    if (id == null) return null;
    final querySnapshot = await db
        .collection(name)
        .where("id", isEqualTo: id)
        .limit(1)
        .get(options);
    if (querySnapshot.docs.isEmpty) return null;
    return CarteraModel.fromJson(querySnapshot.docs.first.data());
  }

  static Future<int> countItems({List<Filter>? filters}) async {
    Query<Map<String, dynamic>> query = db.collection(name);
    if (filters != null && filters.isNotEmpty) {
      for (var f in filters) {
        query = query.where(f);
      }
    }
    final querySnapshot = await query.count().get();
    return querySnapshot.count ?? 0;
  }

  static Future<List<CarteraModel>> getItemPersonalizado(
      {int? id,
      List<Filter>? filters,
      int max = 50,
      String orderBy = "uuid",
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
        .map((doc) => CarteraModel.fromJson(doc.data()))
        .toList();
  }

  static Future<bool> deleteItem({required CarteraModel model}) async {
    try {
      final querySnapshot = await db
          .collection(name)
          .where("uuid", isEqualTo: model.uuid)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return false;
      await db.collection(name).doc(querySnapshot.docs.first.id).delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> sendItem(
      {required CarteraModel data,
      String? table,
      String? query,
      bool itsNumber = false}) async {
    try {
      var doc = await db
          .collection(name)
          .where(table ?? "uuid",
              isEqualTo: itsNumber
                  ? int.tryParse(query ?? data.uuid)
                  : query ?? data.uuid)
          .limit(1)
          .get(options)
          .timeout(const Duration(seconds: firebaseTimeout));

      var user = doc.docs.firstOrNull == null
          ? null
          : CarteraModel.fromJson(doc.docs.firstOrNull!.data());
      debugPrint("${user?.toJson() ?? "nada"} - ${doc.docs.firstOrNull?.id}");

      if (user == null) {
        var docId = Textos.randomWord(30);
        await db
            .collection(name)
            .doc(docId)
            .set(data.toJson())
            .timeout(const Duration(seconds: firebaseTimeout));
      } else {
        await db
            .collection(name)
            .doc(doc.docs.first.id)
            .update(data.toJson())
            .timeout(const Duration(seconds: firebaseTimeout));
      }
      return true;
    } catch (e) {
      var strFunc = await TransFun.trad(e.toString());
      showToast(strFunc);
      debugPrint(strFunc);
      return false;
    }
  }
}
