import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/contacto_model.dart';

class ContactoFire {
  static final db = FirebaseFirestore.instance;
  static String name = "contactos";

  static Future<String?> getDocId({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.id;
  }

  static Future<ContactoModelo?> getItem({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return ContactoModelo.fromJson(querySnapshot.docs.first.data());
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

  static Future<List<ContactoModelo>> getItemPersonalizado(
      {int? id,
      List<Filter>? filters,
      int max = 50,
      String orderBy = "nombre_completo",
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
        .map((doc) => ContactoModelo.fromJson(doc.data()))
        .toList();
  }

  static Future<bool> deleteItem({required ContactoModelo model}) async {
    try {
      final querySnapshot = await db
          .collection(name)
          .where("id", isEqualTo: model.id)
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
      {required ContactoModelo data,
      String? table,
      String? query,
      bool itsNumber = false}) async {
    try {
      var doc = await db
          .collection(name)
          .where(table ?? "uuid",
              isEqualTo: itsNumber
                  ? int.tryParse(
                      query ?? FirebaseAuth.instance.currentUser?.uid ?? "")
                  : query ?? FirebaseAuth.instance.currentUser?.uid)
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 15));
          
      var user = doc.docs.firstOrNull == null
          ? null
          : ContactoModelo.fromJson(doc.docs.firstOrNull!.data());
      debugPrint("${user?.toJson() ?? "nada"} - ${doc.docs.firstOrNull?.id}");
      
      if (user == null) {
        var docId = Textos.randomWord(30);
        await db.collection(name).doc(docId).set(data.toFirestore())
            .timeout(const Duration(seconds: 15));
      } else {
        await db
            .collection(name)
            .doc(doc.docs.first.id)
            .update(data.toFirestore())
            .timeout(const Duration(seconds: 15));
      }
      return true;
    } catch (e) {
      debugPrint("Error al enviar a Firebase: $e");
      return false;
    }
  }
}
