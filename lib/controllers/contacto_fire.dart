import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/contacto_model.dart';

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
          .get();
      var user = doc.docs.firstOrNull == null
          ? null
          : ContactoModelo.fromJson(doc.docs.firstOrNull!.data());
      debugPrint("${user?.toJson() ?? "nada"} - ${doc.docs.firstOrNull?.id}");
      if (user == null) {
        var docId = Textos.randomWord(30);
        await db.collection(name).doc(docId).set(data.toFirestore());
      } else {
        await db.collection(name).doc(doc.docs.first.id).update(data.toFirestore());
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
