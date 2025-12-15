import 'package:geocoding/geocoding.dart';
import 'package:open_location_code/open_location_code.dart';

class PlusCodeFun {
  // Detecta si es un código completo o corto
  static bool _isFullPlusCode(String code) {
    // Un código completo normalmente tiene 10-11 caracteres antes del espacio o localidad
    // Ejemplo: "76GGV6RQ+WJ7" tiene 11 caracteres
    // Ejemplo: "W756+W4" tiene 6 caracteres (código corto)

    // Primero separamos el código de la localidad si existe
    String codePart = code.split(' ').first;

    // Verificar si es válido como código completo
    if (PlusCode(codePart).isValid) {
      // Si tiene 10 o más caracteres (incluyendo el +)
      return codePart.length >= 10;
    }

    return false;
  }

  // Convertir cualquier formato a "Código Local + Localidad"
  static Future<String> toShortFormat(String input) async {
    try {
      // Separar código y localidad si ya viene combinado
      List<String> parts = input.split(' ');
      String codePart = parts[0];
      String existingLocality =
          parts.length > 1 ? parts.sublist(1).join(' ') : '';

      double lat, lng;

      if (_isFullPlusCode(codePart)) {
        // Es código completo, convertir a coordenadas
        final codeArea = PlusCode(codePart).decode();
        lat = codeArea.southWest.latitude;
        lng = codeArea.southWest.longitude;
      } else {
        // Es código corto, necesitamos la localidad para geocodificar
        if (existingLocality.isEmpty) {
          throw Exception('Para códigos cortos se requiere la localidad');
        }

        // Geocodificar la localidad para obtener coordenadas base
        final locations = await locationFromAddress(existingLocality);
        if (locations.isEmpty) {
          throw Exception(
              'No se pudo encontrar la localidad: $existingLocality');
        }

        lat = locations.first.latitude;
        lng = locations.first.longitude;

        // Obtener el código completo de las coordenadas base
        final baseFullCode = psCODE(lat, lng);

        // Combinar código base con código corto
        String baseCode = baseFullCode.substring(0, 4);
        codePart = '$baseCode$codePart';

        // Ahora decodificamos el código completo
        final codeArea = PlusCode(codePart).decode();
        lat = codeArea.southWest.latitude;
        lng = codeArea.southWest.longitude;
      }

      // Obtener la localidad mediante reverse geocoding
      String locality = existingLocality;
      if (locality.isEmpty) {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          locality = _buildLocalityString(placemark);
        }
      }

      // Extraer la parte local del código
      String localCode = codePart.length > 4 ? codePart.substring(4) : codePart;

      return '$localCode $locality'.trim();
    } catch (e) {
      throw Exception('Error en conversión: $e');
    }
  }

  // Convertir "Código Local + Localidad" a código completo
  static Future<String> toFullCode(String shortFormat) async {
    try {
      List<String> parts = shortFormat.split(' ');

      if (parts.length < 2) {
        throw Exception(
            'Formato incorrecto. Debe ser: "V6RQ+WJ7 Umán, Yucatán" o "W756+W4 Hunxectamán, Yuc."');
      }

      String localCode = parts[0]; // "W756+W4" o "V6RQ+WJ7"
      String locality = parts.sublist(1).join(' '); // "Hunxectamán, Yuc."

      // Geocodificar la localidad para obtener coordenadas base
      final locations = await locationFromAddress(locality);

      if (locations.isEmpty) {
        throw Exception('No se pudo encontrar la localidad: $locality');
      }

      final location = locations.first;

      // Convertir coordenadas a Plus Code para obtener el código base
      final baseFullCode = psCODE(location.latitude, location.longitude);

      // Extraer el código base (primeros 4 caracteres)
      String baseCode = baseFullCode.substring(0, 4);

      // Combinar código base con código local
      String fullCode = '$baseCode$localCode';

      // Validar el código resultante
      if (PlusCode(fullCode).isValid) {
        // Intentar ajustar si el código local es muy corto
        fullCode = _adjustPlusCodeLength(fullCode);
      }

      if (!PlusCode(fullCode).isValid) {
        throw Exception('Plus Code resultante no válido: $fullCode');
      }

      return fullCode;
    } catch (e) {
      throw Exception('Error en conversión: $e');
    }
  }

  // Construir string de localidad a partir del placemark
  static String _buildLocalityString(Placemark placemark) {
    List<String> parts = [];

    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    } else if (placemark.subAdministrativeArea?.isNotEmpty == true) {
      parts.add(placemark.subAdministrativeArea!);
    }

    if (placemark.administrativeArea?.isNotEmpty == true &&
        placemark.administrativeArea != placemark.locality) {
      parts.add(placemark.administrativeArea!);
    }

    if (placemark.country?.isNotEmpty == true) {
      parts.add(placemark.country!);
    }

    return parts.join(', ');
  }

  // Ajustar la longitud del Plus Code si es necesario
  static String _adjustPlusCodeLength(String code) {
    if (code.length < 10) {
      // Agregar ceros para alcanzar longitud mínima
      String base = code.split('+').first;
      String plusPart = code.contains('+') ? code.split('+').last : '';

      while (base.length < 8) {
        base += '0';
      }

      if (plusPart.isEmpty) {
        return '$base+';
      } else {
        return '$base+$plusPart';
      }
    }
    return code;
  }

  static Future<String> convert(String input,
      {bool toShortFormat = true}) async {
    try {
      if (toShortFormat) {
        // Convertir a formato corto (Código Local + Localidad)
        return await _convertToShortFormat(input);
      } else {
        // Convertir a formato completo
        return await _convertToFullCode(input);
      }
    } catch (e) {
      throw Exception('Error en conversión: $e - Input: $input');
    }
  }

  static Future<String> _convertToShortFormat(String input) async {
    // Limpiar y separar
    String cleaned = input.trim();
    List<String> parts = cleaned.split(' ');

    if (parts.isEmpty) {
      throw Exception('Entrada vacía');
    }

    String codePart = parts[0];
    String existingLocality =
        parts.length > 1 ? parts.sublist(1).join(' ') : '';

    // Verificar tipo de código
    bool isFullCode = codePart.length >= 10 &&
        codePart.contains('+') &&
        PlusCode(codePart).isValid;

    if (isFullCode) {
      // Es código completo
      return await toShortFormat(
          codePart + (existingLocality.isNotEmpty ? ' $existingLocality' : ''));
    } else {
      // Es código corto, necesita localidad
      if (existingLocality.isEmpty) {
        throw Exception(
            'Los códigos cortos requieren especificar la localidad');
      }
      return '$codePart $existingLocality';
    }
  }

  static Future<String> _convertToFullCode(String input) async {
    // Para convertir a formato completo, siempre necesitamos localidad
    String cleaned = input.trim();
    List<String> parts = cleaned.split(' ');

    if (parts.length < 2) {
      // Intentar inferir si es un código completo
      String codePart = parts[0];
      if (PlusCode(codePart).isValid && codePart.length >= 10) {
        return codePart; // Ya es código completo
      }
      throw Exception('Se requiere formato: "Código Localidad"');
    }

    return await toFullCode(cleaned);
  }

  static LatLng truncPlusCode(String code) {
    var decode = PlusCode(code).decode();
    var coordenadas = LatLng(
        double.parse(decode.southWest.latitude.toStringAsFixed(6)),
        double.parse(decode.southWest.longitude.toStringAsFixed(6)));
    return coordenadas;
  }

  static String psCODE(double latitud, double longitud) {
    final pscode =
        PlusCode.encode(LatLng(latitud, longitud), codeLength: 11).toString();
    return pscode;
  }
}
