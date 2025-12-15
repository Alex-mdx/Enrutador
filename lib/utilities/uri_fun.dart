import 'dart:convert';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/estado_controller.dart';
import 'package:enrutador/controllers/tipo_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/models/estado_model.dart';
import 'package:enrutador/models/tipos_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';

import '../controllers/roles_controller.dart';
import '../models/roles_model.dart';
import 'map_fun.dart';
import 'pluscode_fun.dart';

class UriFun {
  static const _channel =
      MethodChannel('com.example.enrutador/content_uri_reader');

  static Future<void> readContentUriSafe(
      String uriString, MainProvider provider) async {
    debugPrint(uriString);
    if (uriString.contains("q=")) {
      showToast("Buscando ubicacion...");
      Future.delayed(Duration(seconds: kDebugMode ? 2 : 1),
          () async => await MapFun.getUri(provider: provider, uri: uriString));
    } else {
      try {
        // Paso 1: Obtener tamaño
        final fileSize = await _getFileSizeSafe(uriString);
        if (fileSize > 100 * 1024 * 1024) {
          return debugPrint("Archivo demasiado grande");
        }

        // Paso 2: Leer contenido
        final content = await _getContentSafe(uriString);
        if (content == null) return debugPrint("No pudo obtener el dato");

        // Paso 3: Parsear JSON
        await _parseJsonSafe(content, provider);
      } catch (e) {
        debugPrint('❌ Error seguro: $e');
      }
    }
  }

  static Future<int> _getFileSizeSafe(String uriString) async {
    try {
      final result =
          await _channel.invokeMethod<int>('getFileSize', {'uri': uriString});
      return result ?? 0;
    } catch (e) {
      debugPrint("$e");
      return 0;
    }
  }

  static Future<String?> _getContentSafe(String uriString) async {
    try {
      final result = await _channel
          .invokeMethod<String>('readContentUri', {'uri': uriString});
      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<void> _parseJsonSafe(
      String content, MainProvider provider) async {
    try {
      if (!provider.cargaDatos) {
        provider.cargaDatos = true;
        debugPrint("intentando mostrar datos");
        Map<String, dynamic> datas = jsonDecode(content.toString());
        debugPrint("contenido parseado $datas");
        debugPrint(datas.keys.single);
        switch (datas.keys.firstOrNull) {
          case "contactos":
            List<dynamic> contactos = datas["contactos"];
            provider.cargaLenght = contactos.length;
            for (var contacto in contactos) {
              var model = ContactoModelo.fromJson(contacto);
              var datamodel = await ContactoController.getItem(
                  lat: model.latitud, lng: model.longitud);
              var pc = PlusCodeFun.psCODE(model.latitud, model.longitud);
              var newlocation = PlusCodeFun.truncPlusCode(pc);
              debugPrint("result: ${model.toJson()}");
              if (datamodel != null) {
                debugPrint("actualizar");
                var newPlus = model;
                await ContactoController.update(newPlus);
              } else {
                var newPlus = model.copyWith(
                    latitud:
                        double.parse(newlocation.latitude.toStringAsFixed(6)),
                    longitud:
                        double.parse(newlocation.longitude.toStringAsFixed(6)));
                debugPrint("nuevo");
                await ContactoController.insert(newPlus);
              }

              provider.cargaProgress++;
            }
            showToast("Contactos guardados");
            break;
          case "tipos":
            List<dynamic> tipos = datas["tipos"];
            provider.cargaLenght = tipos.length;
            for (var tipo in tipos) {
              var model = TiposModelo.fromJson(tipo);
              var datamodel = await TipoController.getItem(data: model.id!);
              if (datamodel != null) {
                await TipoController.update(model);
              } else {
                await TipoController.insert(model);
              }

              provider.cargaProgress++;
            }
            provider.tipos = await TipoController.getItems();
            showToast("Tipos guardados");
            break;
          case "estados":
            List<dynamic> estados = datas["estados"];
            provider.cargaLenght = estados.length;
            for (var tipo in estados) {
              var model = EstadoModel.fromJson(tipo);
              var datamodel = await EstadoController.getItem(data: model.id!);
              if (datamodel != null) {
                await EstadoController.update(model);
              } else {
                await EstadoController.insert(model);
              }

              provider.cargaProgress++;
            }
            provider.estados = await EstadoController.getItems();
            showToast("Estados guardados");
            break;
          case "roles":
            List<dynamic> roles = datas["roles"];
            provider.cargaLenght = roles.length;
            for (var rol in roles) {
              var model = RolesModel.fromJson(rol);
              var datamodel = await RolesController.getId(model.id!);
              if (datamodel != null) {
                await RolesController.update(model);
              } else {
                await RolesController.insert(model);
              }

              provider.cargaProgress++;
            }
            provider.estados = await EstadoController.getItems();
            showToast("Estados guardados");
            break;
          default:
            showToast("No se detecto el tipo de dato a mostrar");
            break;
        }
        provider.cargaDatos = false;
        provider.cargaLenght = 0;
        provider.cargaProgress = 0;
      }
    } catch (e) {
      provider.cargaDatos = false;
      provider.cargaLenght = 0;
      provider.cargaProgress = 0;
      debugPrint("error $e");
      showToast("error $e");
    }
  }
}
