import 'package:flutter/material.dart';
import 'navigation_key.dart';
import 'navigation_services.dart';
import 's_dialog_morph.dart';

typedef OnAcceptPressedCallback = Future Function(BuildContext context);

class Dialogs {
  static GlobalKey<NavigatorState> navigatorKey = NavigationKey.navigatorKey;

  /// Muestra un dialog que de ser aceptado [onAcceptPressed] se ejecutará.
  /// Impidiendo al usuario poder cerrar el dialogo.
  static Future<dynamic> showMorph({
    required String title,
    required String description,
    required String loadingTitle,
    String loadingDescription = 'Espere un momento...',
    required Function onAcceptPressed,
    String errorToastMessage = 'Ocurrió un error',
    String acceptText = 'Aceptar',
    String cancelText = 'Cancelar',
    Color? acceptTextColor,
  }) {
    bool isLocked = true;
    return showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentState!.context,
        builder: (context) {
          return PopScope(
              canPop: isLocked,
              child: MorphDialog(
                  description: description,
                  title: title,
                  loadingDescription: loadingDescription,
                  loadingTitle: loadingTitle,
                  onAcceptPressed: (BuildContext context) async {
                    isLocked = false;
                    await onAcceptPressed(context);
                    isLocked = true;
                    Navigation.pop();
                  },
                  cancelText:
                      Text(cancelText, style: const TextStyle(fontSize: 18)),
                  acceptText: Text(acceptText,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: acceptTextColor))));
        });
  }

  static Future<dynamic> showCustomDialog(Widget dialog) {
    return showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentState!.context,
        builder: (_) {
          return dialog;
        });
  }
}
