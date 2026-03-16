import 'package:flutter/material.dart';
import 'package:mindfulness_reminder/screens/home_page.dart';
import 'package:mindfulness_reminder/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

const int helloAlarmID = 0;

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await AndroidAlarmManager.initialize();

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
