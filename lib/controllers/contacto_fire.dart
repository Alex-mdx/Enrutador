import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  static Future<bool> send({required ContactoModelo contacto, String? empleadoId}) async {
    var data = await getItem(id: contacto.id);
    if (data == null) {
      var rdm = Textos.randomWord(30);
      await db.collection(name).doc(rdm).set(contacto
          .copyWith(empleadoId: empleadoId, status: 1)
          .toJson());
      return true;
    } else {
      var docId = await getDocId(id: contacto.id);
      if (docId == null) return false;
      await db.collection(name).doc(docId).update(contacto
          .copyWith(empleadoId: empleadoId ?? FirebaseAuth.instance.currentUser!.uid, status: 1)
          .toJson());
      return true;
    }
  }
}
