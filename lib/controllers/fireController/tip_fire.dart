import 'dart:async';
import 'dart:developer';

import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/trans_fun.dart';
import 'package:flutter/foundation.dart';
import 'package:oktoast/oktoast.dart';

import '../../utilities/noti_fun.dart';
import '../../utilities/preferences.dart';
import 'fire_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:flutter/material.dart';
import '../../models/tip_model.dart';

class TipFire {
  static final db = FirebaseFirestore.instance;
  static String name = "tips";

  static Future<String?> getDocId({required int? id}) async {
    if (id == null) return null;
    final querySnapshot = await db
        .collection(name)
        .where("id", isEqualTo: id)
        .limit(1)
        .get(options);
    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.id;
  }

  static Future<TipModel?> getItem({required int? id}) async {
    if (id == null) return null;
    final querySnapshot = await db
        .collection(name)
        .where("id", isEqualTo: id)
        .limit(1)
        .get(options);
    if (querySnapshot.docs.isEmpty) return null;
    return TipModel.fromJson(querySnapshot.docs.first.data());
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

  static Future<List<TipModel>> getItemPersonalizado(
      {int? id,
      List<Filter>? filters,
      int max = 50,
      String orderBy = "fecha_creacion",
      bool descending = false}) async {
    try {
      Query<Map<String, dynamic>> query = db.collection(name);
      if (id != null || (filters != null && filters.isNotEmpty)) {
        if (filters != null && filters.isNotEmpty) {
          for (var f in filters) {
            query = query.where(f);
          }
        } else if (id != null) {
          query = query.where("empleado_creado", isEqualTo: id.toString());
        }
      }
      query = query.orderBy(orderBy, descending: descending).limit(max);
      final querySnapshot = await query.get();
      log("query: ${query.toString()}");
      log("querySnapshot: ${querySnapshot.docs.length}");
      return querySnapshot.docs
          .map((doc) => TipModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log(e.toString());
      return <TipModel>[];
    }
  }

  static Future<bool> deleteItem({required TipModel model}) async {
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
      {required TipModel data,
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

      var tip = doc.docs.firstOrNull == null
          ? null
          : TipModel.fromJson(doc.docs.firstOrNull!.data());
      debugPrint("${tip?.toFire() ?? "nada"} - ${doc.docs.firstOrNull?.id}");

      if (tip == null) {
        var docId = Textos.randomWord(30);
        await db
            .collection(name)
            .doc(docId)
            .set(data.toFire())
            .timeout(const Duration(seconds: firebaseTimeout));
      } else {
        await db
            .collection(name)
            .doc(doc.docs.first.id)
            .update(data.toFire())
            .timeout(const Duration(seconds: firebaseTimeout));
      }
      return true;
    } catch (e) {
      var strFunc = await TransFun.trad(e.toString());
      showToast(strFunc);
      log(strFunc);
      return false;
    }
  }

  static Future<void> findTips(
      {required String empleadoId, bool? abierto, bool? estadoTip}) async {
    List<Filter> filters = [];
    filters.add(Filter("empleado_to", isEqualTo: empleadoId));

    if (abierto != null) {
      filters.add(Filter("abierto", isEqualTo: abierto == true ? 1 : 0));
    }
    if (estadoTip != null) {
      filters.add(Filter("estado_tip", isEqualTo: estadoTip == true ? 1 : 0));
    }
    var tips = await TipFire.getItemPersonalizado(filters: filters);
    log("tips: ${tips.length}");
    if (tips.isNotEmpty) {
      await NotiFun().showNotification(
          title: "Nuevas asignaciones",
          body:
              "Tienes ${tips.length + Preferences.tipsReaded.length} tip(s) aignado(s) que requieren tu atencion.");
      for (var tip in tips) {
        await TipFire.sendItem(data: tip.copyWith(abierto: 1));
        if (!Preferences.tipsReaded.contains(tip.uuid)) {
          log("tip: ${tip.toFire()}");

          Preferences.tipsReaded = [...Preferences.tipsReaded, tip.uuid];
        }
      }
    }
  }
}
