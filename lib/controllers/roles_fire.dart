import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/roles_model.dart';

import '../utilities/textos.dart';

class RolesFire {
  static final db = FirebaseFirestore.instance;
  static String name = "roles";

  static Future<String?> getDocId({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.id;
  }

  static Future<List<RolesModel>> getItems() async {
    final querySnapshot = await db.collection(name).get();
    if (querySnapshot.docs.isEmpty) return [];
    return querySnapshot.docs.map((e) => RolesModel.fromJson(e.data())).toList();
  }

  static Future<RolesModel?> getItem({required int? id}) async {
    if (id == null) return null;
    final querySnapshot =
        await db.collection(name).where("id", isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    return RolesModel.fromJson(querySnapshot.docs.first.data());
  }

  static Future<bool> send({required RolesModel rol}) async {
    var data = await getItem(id: rol.id);
    if (data == null) {
      var rdm = Textos.randomWord(30);
      await db.collection(name).doc(rdm).set(rol.toJson());
      return true;
    } else {
      var docId = await getDocId(id: rol.id);
      if (docId == null) return false;
      await db.collection(name).doc(docId).update(rol.toJson());
      return true;
    }
  }
}
