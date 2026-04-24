import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/models/pendiente_model.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Operadores de comparación disponibles para [PendienteFire.getCompareItems].
enum QueryOperator {
  equalTo,
  greaterThan,
  greaterThanOrEqualTo,
  lessThan,
  lessThanOrEqualTo,
}

class PendienteFire {
  static var db = FirebaseFirestore.instance;

  static String name = "pendientes";

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

  static Future<PendienteModel?> getItem(
      {required String table,
      required String query,
      bool itsNumber = false}) async {
    var data = await db
        .collection(name)
        .where(table, isEqualTo: itsNumber ? int.tryParse(query) : query)
        .limit(1)
        .get();
    var user = data.docs.firstOrNull == null
        ? null
        : PendienteModel.fromJson(data.docs.firstOrNull!.data());
    return user;
  }

  static Future<List<PendienteModel>> getCompareItems(
      {required String table,
      required dynamic query,
      bool itsNumber = false,
      QueryOperator operator = QueryOperator.equalTo,
      int limit = 50}) async {
    // Parsea el valor si es número
    final value = itsNumber ? int.tryParse(query.toString()) : query;

    // Aplica el operador de comparación correspondiente
    Query<Map<String, dynamic>> ref;
    switch (operator) {
      case QueryOperator.greaterThan:
        ref = db.collection(name).where(table, isGreaterThan: value);
        break;
      case QueryOperator.greaterThanOrEqualTo:
        ref = db.collection(name).where(table, isGreaterThanOrEqualTo: value);
        break;
      case QueryOperator.lessThan:
        ref = db.collection(name).where(table, isLessThan: value);
        break;
      case QueryOperator.lessThanOrEqualTo:
        ref = db.collection(name).where(table, isLessThanOrEqualTo: value);
        break;
      case QueryOperator.equalTo:
        ref = db.collection(name).where(table, isEqualTo: value);
        break;
    }

    ref = ref.limit(limit);

    var data = await ref.get();
    List<PendienteModel> list = [];
    for (var item in data.docs) {
      list.add(PendienteModel.fromJson(item.data()));
    }
    return list;
  }

  static Future<List<PendienteModel>> getItems(
      {required String table,
      required dynamic query,
      bool itsNumber = false,
      String? orden,
      bool decender = true,
      int limit = 50}) async {
    Query<Map<String, dynamic>> ref;

    if (query is List) {
      // whereIn no puede combinarse con orderBy sin índice compuesto,
      // se omite el orderBy y el ordenamiento se hace en memoria en la vista.
      if(query.isNotEmpty){
        final parsedList = itsNumber
          ? query.map((e) => int.tryParse(e.toString())).toList()
          : query.map((e) => e.toString()).toList();

      ref = db.collection(name).where(table, whereIn: parsedList).limit(limit);
      }else{
        ref = db.collection(name).limit(1);
      }
    } else {
      // Comportamiento original con un valor único
      ref = db
          .collection(name)
          .where(table, isEqualTo: itsNumber ? int.tryParse(query) : query)
          .orderBy(orden ?? "id", descending: decender)
          .limit(limit);
    }

    var data = await ref.get();
    List<PendienteModel> list = [];
    for (var item in data.docs) {
      list.add(PendienteModel.fromJson(item.data()));
    }
    return list;
  }

  static Future<List<PendienteModel>> getAllItems({int limit = 50}) async {
    var data = await db.collection(name).limit(limit).get();
    List<PendienteModel> list = [];
    for (var item in data.docs) {
      list.add(PendienteModel.fromJson(item.data()));
    }
    return list;
  }


  static Future<bool> sendItem(
      {required PendienteModel data,
      String? table,
      String? query,
      bool itsNumber = false}) async {
    var doc = await db
        .collection(name)
        .where(table ?? "id",
            isEqualTo: itsNumber
                ? int.tryParse(
                    query ?? FirebaseAuth.instance.currentUser?.uid ?? "")
                : query ?? FirebaseAuth.instance.currentUser?.uid)
        .limit(1)
        .get();
    var uuid = doc.docs.firstOrNull?.id ?? Textos.randomWord(30);
    await db.collection(name).doc(uuid).set(data.toFirestore());
    return true;
  }

  static Future<bool> deleteItem(
      {String? table, String? query, bool itsNumber = false}) async {
    var doc = await db
        .collection(name)
        .where(table ?? "id",
            isEqualTo: itsNumber
                ? int.tryParse(
                    query ?? FirebaseAuth.instance.currentUser?.uid ?? "")
                : query ?? FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (doc.docs.firstOrNull == null) return false;
    await db.collection(name).doc(doc.docs.first.id).delete();
    return true;
  }
}
