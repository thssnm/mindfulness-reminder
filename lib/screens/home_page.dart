import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mindfulness_reminder/services/notification_service.dart';
import 'package:mindfulness_reminder/text/mindfulnessMessages.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isNotificationActive = false;
  final int helloAlarmID = 0;
  bool isLoading = true;

  String get dailyMessage {
    final day = DateTime.now().day;
    final index = day % mindfulnessMessages.length;
    return mindfulnessMessages[index];
  }

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  Future<void> _loadNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('notifications_active') ?? false;

    // Wenn Notifications aktiv sind, Alarm neu starten (wichtig für Updates!)
    if (status) {
      await AndroidAlarmManager.cancel(helloAlarmID);
      await AndroidAlarmManager.periodic(
        const Duration(minutes: 151),
        helloAlarmID,
        printHello,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    }

    setState(() {
      isNotificationActive = status;
      isLoading = false;
    });
  }

  Future<void> _saveNotificationStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_active', status);
  }

  Future<void> _showMyDialog(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mindfulness Reminder'),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(text)]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleNotifications() async {
    if (isNotificationActive) {
      // Deaktivieren
      await AndroidAlarmManager.cancel(helloAlarmID);
      await NotificationService().cancelNotifications();
      setState(() {
        isNotificationActive = false;
      });
      await _saveNotificationStatus(false);
      _showMyDialog("Notifications deaktiviert");
    } else {
      // Aktivieren
      PermissionStatus status = await Permission.notification.request();

      if (status.isGranted) {
        try {
          await NotificationService.showNotification(
            "Notifications aktiviert",
            "Du erhältst ab jetzt Erinnerungen",
          );
        } catch (e) {
          // Fehler bei Notification
        }

        await AndroidAlarmManager.periodic(
          const Duration(minutes: 151),
          helloAlarmID,
          printHello,
          wakeup: true,
          rescheduleOnReboot: true,
        );

        setState(() {
          isNotificationActive = true;
        });
        await _saveNotificationStatus(true);
        _showMyDialog(
          "Notifications aktiviert\n\nDu erhältst Erinnerungen zwischen 8 und 22 Uhr",
        );
      } else if (status.isDenied) {
        _showMyDialog("Bitte erlaube Benachrichtigungen in den Einstellungen");
      } else if (status.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Berechtigung erforderlich'),
              content: const Text(
                'Bitte aktiviere Benachrichtigungen in den App-Einstellungen',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Abbrechen'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Einstellungen'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    openAppSettings();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4A4A4A),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Hauptinhalt zentriert
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Icon(
                    isNotificationActive
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    size: 64,
                    color:
                        isNotificationActive
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF374151),
                  ),

                  const SizedBox(height: 48),

                  // Täglicher Text
                  Text(
                    dailyMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 64),

                  // Status Text
                  Text(
                    isNotificationActive
                        ? "Notifications Aktiv"
                        : "Notifications Inaktiv",
                    style: TextStyle(
                      color:
                          isNotificationActive
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF4B5563),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (isNotificationActive)
                    const Text(
                      "8:00 - 22:00 Uhr",
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                  const SizedBox(height: 48),

                  // Toggle Button
                  TextButton(
                    onPressed: _toggleNotifications,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      side: BorderSide(
                        color:
                            isNotificationActive
                                ? const Color(0xFF4B5563)
                                : const Color(0xFF6B7280),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isNotificationActive
                          ? "Notifications Deaktivieren"
                          : "Notifications Aktivieren",
                      style: TextStyle(
                        color:
                            isNotificationActive
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Test Button unten
          /* Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () {
                  final random = Random();
                  final randomIndex = random.nextInt(
                    mindfulnessMessages.length,
                  );
                  final randomMessage = mindfulnessMessages[randomIndex];

                  NotificationService.showNotification(
                    "Mindfulness Reminder",
                    randomMessage,
                  );
                },
                child: const Text(
                  "Test",
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ), */
        ],
      ),
    );
  }
}
