import 'package:geocoding/geocoding.dart';
import 'package:open_location_code/open_location_code.dart';

class PlusCodeFun {
  static final Geocoding geocoding = Geocoding();
  static bool _isFullPlusCode(String code) {
    String codePart = code.split(' ').first;
    if (PlusCode(codePart).isValid) {
      return codePart.length >= 10;
    }

    return false;
  }

  static Future<String> toShortFormat(String input) async {
    try {
      List<String> parts = input.split(' ');
      String codePart = parts[0];
      String existingLocality =
          parts.length > 1 ? parts.sublist(1).join(' ') : '';
      double lat, lng;

      if (_isFullPlusCode(codePart)) {
        final codeArea = PlusCode(codePart).decode().center;
        lat = codeArea.latitude;
        lng = codeArea.longitude;
      } else {
        if (existingLocality.isEmpty) {
          throw Exception('Para códigos cortos se requiere la localidad');
        }
        final locations = await geocoding.locationFromAddress(existingLocality);
        if (locations.isEmpty) {
          throw Exception(
              'No se pudo encontrar la localidad: $existingLocality');
        }

        lat = locations.first.latitude;
        lng = locations.first.longitude;
        final baseFullCode = psCODE(lat, lng);

        String baseCode = baseFullCode.substring(0, 4);
        codePart = '$baseCode$codePart';
        final codeArea = PlusCode(codePart).decode().center;
        lat = codeArea.latitude;
        lng = codeArea.longitude;
      }
      String locality = existingLocality;
      if (locality.isEmpty) {
        final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          locality = _buildLocalityString(placemark);
        }
      }
      String localCode = codePart.length > 4 ? codePart.substring(4) : codePart;

      return '$localCode $locality'.trim();
    } catch (e) {
      throw Exception('Error en conversión: $e');
    }
  }

  static Future<String> toFullCode(String shortFormat) async {
    try {
      List<String> parts = shortFormat.split(' ');

      if (parts.length < 2) {
        throw Exception(
            'Formato incorrecto. Debe ser: "V6RQ+WJ7 Umán, Yucatán" o "W756+W4 Hunxectamán, Yuc."');
      }

      String localCode = parts[0]; // "W756+W4" o "V6RQ+WJ7"
      String locality = parts.sublist(1).join(' '); // "Hunxectamán, Yuc."
      final locations = await geocoding.locationFromAddress(locality);

      if (locations.isEmpty) {
        throw Exception('No se pudo encontrar la localidad: $locality');
      }

      final location = locations.first;
      final baseFullCode = psCODE(location.latitude, location.longitude);
      String baseCode = baseFullCode.substring(0, 4);
      String fullCode = '$baseCode$localCode';
      if (PlusCode(fullCode).isValid) {
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

    return parts.join(', ');
  }

  static String _adjustPlusCodeLength(String code) {
    if (code.length < 10) {
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
        return await _convertToShortFormat(input);
      } else {
        return await _convertToFullCode(input);
      }
    } catch (e) {
      throw Exception('Error en conversión: $e - Input: $input');
    }
  }

  static Future<String> _convertToShortFormat(String input) async {
    String cleaned = input.trim();
    List<String> parts = cleaned.split(' ');

    if (parts.isEmpty) {
      throw Exception('Entrada vacía');
    }

    String codePart = parts[0];
    String existingLocality =
        parts.length > 1 ? parts.sublist(1).join(' ') : '';
    bool isFullCode = codePart.length >= 10 &&
        codePart.contains('+') &&
        PlusCode(codePart).isValid;

    if (isFullCode) {
      return await toShortFormat(
          codePart + (existingLocality.isNotEmpty ? ' $existingLocality' : ''));
    } else {
      if (existingLocality.isEmpty) {
        throw Exception(
            'Los códigos cortos requieren especificar la localidad');
      }
      return '$codePart $existingLocality';
    }
  }

  static Future<String> _convertToFullCode(String input) async {
    String cleaned = input.trim();
    List<String> parts = cleaned.split(' ');

    if (parts.length < 2) {
      String codePart = parts[0];
      if (PlusCode(codePart).isValid && codePart.length >= 10) {
        return codePart;
      }
      throw Exception('Se requiere formato: "Código Localidad"');
    }

    return await toFullCode(cleaned);
  }

  static LatLng truncPlusCode(String code) {
    var decode = PlusCode(code).decode().center;
    var coordenadas = LatLng(double.parse(decode.latitude.toStringAsFixed(7)),
        double.parse(decode.longitude.toStringAsFixed(7)));
    return coordenadas;
  }

  static String psCODE(double latitud, double longitud) {
    final pscode =
        PlusCode.encode(LatLng(latitud, longitud), codeLength: 11).toString();
    return pscode;
  }
}
