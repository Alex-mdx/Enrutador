import 'package:flutter/widgets.dart';

import 'navigation_key.dart';

class Navigation {
  static GlobalKey<NavigatorState> navigatorKey = NavigationKey.navigatorKey;

  static Future<dynamic> pushNamed({required String route, Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(route, arguments: arguments);
  }

  static Future<dynamic> pushRoute(Route route) {
    return navigatorKey.currentState!.push(route);
  }

  static Future<dynamic> pushNamedAndRemoveUntil({
    required String routeName,
    RoutePredicate? predicate,
    Object? arguments,
  }) {
    return navigatorKey.currentState != null
        ? navigatorKey.currentState!.pushNamedAndRemoveUntil(
            routeName, predicate ?? (route) => route.isFirst,
            arguments: arguments)
        : Future.value();
  }

  static Future<dynamic> pushReplacementNamed(
      {required String routeName, Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  static void pop([bool result = false]) {
    return navigatorKey.currentState!.pop(result);
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    return navigatorKey.currentState!.popUntil(predicate);
  }

  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  static void popTwice() {
    navigatorKey.currentState!.pop();
    return navigatorKey.currentState!.pop();
  }

  static void unFocus() {
    FocusScope.of(navigatorKey.currentState!.context).unfocus();
  }
}
