import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceivedNotification(
    NotificationResponse notificationResponse,
  ) async {}

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_stat_ic_launcher");
    const DarwinInitializationSettings iOSinizializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iOSinizializationSettings,
        );

    // Initialize timezone
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceivedNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceivedNotification,
    );

    print("NotificationService initialized");
  }

  static Future<void> showNotification(String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_Id",
        "channel_Name",
        importance: Importance.high,
        priority: Priority.high,
        icon: "@mipmap/ic_stat_ic_launcher",
      ),
      iOS: DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleNotification({
    int id = 1,
    required int hour,
    required int minute,
  }) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_Id",
        "channel_Name",
        importance: Importance.high,
        priority: Priority.high,
        icon: "ic_launcher", // GEÄNDERT
      ),
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);
    print("now${now.hour}$hour");

    double time1 = hour + minute / 60.0;
    double time2 = now.hour + now.minute / 60;

    var tomorrow = time2 < time1 ? now.day : now.day + 1;

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      tomorrow,
      hour,
      minute,
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        "Mindfulness Reminder",
        "Nimm dir einen Moment und sei ganz im Hier und Jetzt.",
        scheduledDate,
        platformChannelSpecifics,
        //ios specific
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,

        //android specific in low power mode
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        //notification repeat daily
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print("error notification:$e");
    }

    print('Notification Schduled, $tomorrow, $hour, $minute');
  }

  Future<void> periodicallyShowNotification({int id = 1}) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_Id",
        "channel_Name",
        importance: Importance.high,
        priority: Priority.high,
        icon: "ic_launcher", // GEÄNDERT
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        "Mindfulness Reminder",
        "Nimm dir einen Moment und sei ganz im Hier und Jetzt.",
        RepeatInterval.hourly,
        platformChannelSpecifics,
        //android specific in low power mode
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print("error notification:$e");
    }
  }

  //cancel
  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
