import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mindfulness_reminder/screens/home_page.dart';
import 'package:mindfulness_reminder/services/notification_service.dart';
import 'package:mindfulness_reminder/text/mindfulnessMessages.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

@pragma('vm:entry-point')
void printHello() {
  final DateTime now = DateTime.now();
  if (now.hour > 8 && now.hour < 22) {
    NotificationService.showNotification(
      "Mindfulness Reminder",
      "Nimm dir einen Moment und sei ganz im Hier und Jetzt.",
    );
  }
}

const int helloAlarmID = 0;

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await AndroidAlarmManager.initialize();

  // WICHTIG: NotificationService HIER initialisieren (aber OHNE Permission Request!)
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mindfulness Reminder',
      home: const HomePage(),
    );
  }
}
