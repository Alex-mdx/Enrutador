import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
import 'package:open_location_code/open_location_code.dart';

class UriFun {
  static const _channel =
      MethodChannel('com.example.enrutador/content_uri_reader');

  static Future<void> readContentUriSafe(
      String uriString, MainProvider provider) async {
    final isLocationUri = uriString.contains("q=") ||
        uriString.contains("query=") ||
        uriString.contains("maps") ||
        uriString.startsWith("geo:");
    if (isLocationUri) {
      showToast("Buscando ubicacion...");
      while (provider.local == null) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      await _processLocationUri(provider: provider, uri: uriString);
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
        debugPrint('X Error seguro: $e');
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
        Map<String, dynamic> datas = jsonDecode(content.toString());

        if (datas.containsKey("cartera")) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = "cartera.json";
          final file = File('${directory.path}/$fileName');

          Map<String, dynamic> carteraOnly = {"cartera": datas["cartera"]};

          await file.writeAsString(jsonEncode(carteraOnly));
          showToast("Cartera guardada como archivo");

          provider.cargaDatos = false;
          provider.cargaLenght = 0;
          provider.cargaProgress = 0;
          return;
        }

        for (var clave in datas.keys) {
          switch (clave) {
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
                          double.parse(newlocation.latitude.toStringAsFixed(7)),
                      longitud: double.parse(
                          newlocation.longitude.toStringAsFixed(7)));
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
              provider.roles = await RolesController.getAll();
              showToast("Roles guardados");
              break;
            default:
              showToast("No se detecto el tipo de dato a mostrar");
              break;
          }
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

  static Future<void> _processLocationUri(
      {required MainProvider provider, required String uri}) async {
    try {
      String decodedUri = Uri.decodeFull(uri).replaceAll('+', ' ');

      final qIndex = decodedUri.indexOf('q=');
      final queryIndex = decodedUri.indexOf('query=');
      String textToSearch = decodedUri;
      if (qIndex != -1) {
        textToSearch = decodedUri.substring(qIndex);
      } else if (queryIndex != -1) {
        textToSearch = decodedUri.substring(queryIndex);
      }

      final regExp = RegExp(r'(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)');
      final match =
          regExp.firstMatch(textToSearch) ?? regExp.firstMatch(decodedUri);

      if (match != null) {
        double lat = double.parse(match.group(1)!);
        double lng = double.parse(match.group(2)!);

        var pc = PlusCodeFun.psCODE(lat, lng);
        var newlocation = PlusCode(pc).decode().center;
        await MapFun.sendInitUri(
            provider: provider,
            lat: double.parse(newlocation.latitude.toStringAsFixed(7)),
            lng: double.parse(newlocation.longitude.toStringAsFixed(7)));
      } else {
        showToast("No se pudo obtener las coordenadas del enlace");
        debugPrint("No match for coordinates in URI: $uri");
      }
    } catch (e) {
      debugPrint("Error procesando URI de ubicación: $e");
      showToast("Error al procesar la ubicación");
    }
  }
}
