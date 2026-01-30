import 'package:flutter/material.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class NumberFun {
  static String formatNumber(String number) {
    Iterable<PhoneNumber> country;
    country = PhoneNumber.findPotentialPhoneNumbers(number);
    debugPrint("${country.toList().map((e) => e).toList()}");
    return country.firstOrNull?.formatNsn() ?? "0";
  }

  static String formatNumberWithLada(String number) {
    Iterable<PhoneNumber> country;
    country = PhoneNumber.findPotentialPhoneNumbers(number);
    debugPrint("${country.toList().map((e) => e).toList()}");
    String? lada = country.firstOrNull?.countryCode;
    debugPrint(lada);
    return "$lada${country.firstOrNull?.formatNsn() ?? "0"}";
  }

  static String formatNumberWithLadaAndParentheses(String number) {
    Iterable<PhoneNumber> country;
    country = PhoneNumber.findPotentialPhoneNumbers(number);
    debugPrint("${country.toList().map((e) => e).toList()}");
    String? lada = country.firstOrNull?.countryCode;
    debugPrint(lada);
    return "($lada) ${country.firstOrNull?.formatNsn() ?? "0"}";
  }

  static String? onlyLada(String? number) {
    if (number == null) return null;
    Iterable<PhoneNumber> country;
    country = PhoneNumber.findPotentialPhoneNumbers(number);
    debugPrint("${country.toList().map((e) => e).toList()}");
    String? lada = country.firstOrNull?.countryCode;
    return lada;
  }
}