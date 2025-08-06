import 'package:intl/intl.dart';
import 'dart:math' as math;

class Textos {
  static String normalizar(String text) {
    text = text.replaceAll(
        RegExp(r'[^\x00-\x7F]+'), ''); // Elimina caracteres no ASCII
    text = text.replaceAll(
        RegExp(r'[^\w\s]'), ''); // Elimina símbolos no alfanuméricos
    // Reemplaza los acentos y caracteres especiales
    text = text.replaceAll(RegExp(r'[áàäâã]'), 'a');
    text = text.replaceAll(RegExp(r'[éèëê]'), 'e');
    text = text.replaceAll(RegExp(r'[íìïî]'), 'i');
    text = text.replaceAll(RegExp(r'[óòöôõ]'), 'o');
    text = text.replaceAll(RegExp(r'[úùüû]'), 'u');
    text = text.replaceAll(RegExp(r'[ç]'), 'c');
    text = text.replaceAll(RegExp(r'[ñ]'), 'n');

    return text;
  }

  ///Moneda:El monto de su tipo de moneda a convertir
  ///
  ///digito: cuantos digitos desea que tenga por ejemplo: con el numero 10.12345678 -> 0 (10) | 1 (10.1) | 2 (10.12) | 3 (10.123)
  ///Por defecto mosstrara 2 digitos: 10.12
  static String moneda({required double moneda, double? digito}) {
    String tipo = "##";
    if (digito != null) {
      tipo = "";
      for (var i = 0; i < digito; i++) {
        tipo += "#";
      }
    }

    String formateado = NumberFormat('#,###.$tipo').format(moneda);
    return formateado;
  }

  static String fechaYMDHMS({required DateTime fecha}) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(fecha);
  }

  static String fechaYMD({required DateTime fecha}) {
    return DateFormat('yyyy-MM-dd').format(fecha);
  }

  static String fechaHMS({required DateTime fecha}) {
    String formatoFechaHora = DateFormat('HH:mm:ss').format(fecha);
    return formatoFechaHora;
  }

  static String fechaHM({required DateTime fecha}) {
    String formatoFechaHora = DateFormat('HH:mm').format(fecha);
    return formatoFechaHora;
  }

  static int getNumeroSemana(DateTime date) {
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    int dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    int weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();

    // Ajuste para las primeras semanas del año
    if (weekNumber < 1) {
      return getNumeroSemana(DateTime(date.year - 1, 12, 31));
    }
    return weekNumber;
  }

  static bool contieneLetras(String texto) {
    final regex = RegExp(r'[a-zA-Z]');
    return !regex.hasMatch(texto);
  }

  static String randomWord(int? number) {
    final random = math.Random();
    const caracteres =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    String cadenaAleatoria = '';
    for (int i = 0; i < (number ?? 10); i++) {
      int indice = random.nextInt(caracteres.length);
      cadenaAleatoria += caracteres[indice];
    }
    return cadenaAleatoria;
  }
}
