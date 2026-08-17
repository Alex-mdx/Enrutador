import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiFun {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> showNotification(
      {
      required String title,
      required String body,
      String? payload}) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
            'high_importance_channel', 'Notificaciones Importantes',
            channelDescription:
                'Este canal se usa para notificaciones importantes.',
            importance: Importance.max,
            priority: Priority.high);

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
        id: 0,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload);
  }

// Función global para enviar una notificación con barra de progreso
  static Future<void> showProgressNotification(
      {int id = 1,
      required String title,
      required String body,
      required int progress,
      required int maxProgress}) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'progress_channel', 'Progreso de Tareas',
        channelDescription:
            'Este canal se usa para mostrar el progreso de descargas u operaciones.',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        onlyAlertOnce: true,
        ongoing: progress < maxProgress);

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails);
  }

// Función global para enviar una notificación de texto largo expandible (Big Text Style)
  static Future<void> showBigTextNotification(
      {int id = 2,
      required String title,
      required String body,
      required String bigText,
      String? payload}) async {
    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(bigText,
            contentTitle: title, summaryText: body);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
            'high_importance_channel', 'Notificaciones Importantes',
            channelDescription:
                'Este canal se usa para notificaciones importantes.',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: bigTextStyleInformation);

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload);
  }
}
