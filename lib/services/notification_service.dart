// ignore_for_file: constant_identifier_names, library_prefixes

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as TZ;
import 'package:timezone/data/latest.dart' as LT;

class NotificationService {
  bool isInitialized = false;
  static const int _NOTIFICATION_ID = 1;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    LT.initializeTimeZones();
    return _notificationService;
  }

  NotificationService._internal();
  static final NotificationService _notificationService =
      NotificationService._internal();

  Future<void> initNotification() async {
    //Android initialization
    const AndroidInitializationSettings androidinitializationSettings =
        AndroidInitializationSettings("@mipmap/launcher_icon");
    //IOS initialization
    DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: _onDidRecievedLocalNotification);
    InitializationSettings settings = InitializationSettings(
        android: androidinitializationSettings, iOS: iosInitializationSettings);
    isInitialized = await notificationsPlugin.initialize(settings,
            onDidReceiveBackgroundNotificationResponse:
                _onDidRecievedLocalNotificationOnBackgorund) ??
        false;
  }

  Future<void> _scheduleNotification(String title, String payload,
      {int id = _NOTIFICATION_ID}) async {
    final DateTime currentTime = TZ.TZDateTime.now(TZ.local);
    final nextMonday = TZ.TZDateTime(TZ.local, currentTime.year,
        currentTime.month, currentTime.day + (7 - currentTime.weekday), 20);
    await notificationsPlugin.zonedSchedule(
        id,
        title,
        "Please update this week weight",
        nextMonday,
        _getNotificationDetails(title, payload),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  NotificationDetails _getNotificationDetails(String title, String payload) {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(title, payload,
            priority: Priority.high, importance: Importance.max);
    DarwinNotificationDetails isoNotificationDetails =
        DarwinNotificationDetails(
            subtitle: payload, interruptionLevel: InterruptionLevel.critical);
    return NotificationDetails(
        android: androidNotificationDetails, iOS: isoNotificationDetails);
  }

  Future<void> scheduleNotification(String title, String payload) async {
    List<PendingNotificationRequest> pendingNotificationRequest =
        await notificationsPlugin.pendingNotificationRequests();
    //Chech weather the notification was in the request or not
    bool notificationFlag = true;
    for (PendingNotificationRequest request in pendingNotificationRequest) {
      if (request.id == _NOTIFICATION_ID) {
        printInfo(info: "Notification was already in queue");
        notificationFlag = false;
        break;
      }
    }
    if (notificationFlag && isInitialized) {
      await _scheduleNotification(title, payload);
    }
  }

  static void _onDidRecievedLocalNotificationOnBackgorund(
      NotificationResponse response) {
    if (response.id != null && response.id == _NOTIFICATION_ID) {
      // Have to handle the notification
    }
  }

  void _onDidRecievedLocalNotification(
      int? id, String? title, String? body, String? payload) {}
}
