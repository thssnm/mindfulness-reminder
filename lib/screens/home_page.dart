import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mindfulness_reminder/services/notification_service.dart';
import 'package:mindfulness_reminder/text/mindfulnessMessages_de.dart';
import 'package:mindfulness_reminder/text/mindfulnessMessages_en.dart';
import 'package:mindfulness_reminder/text/app_strings.dart';
import 'package:mindfulness_reminder/screens/settings_page.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void printHello() async {
  final DateTime now = DateTime.now();
  final prefs = await SharedPreferences.getInstance();
  final startHour = prefs.getInt('start_hour') ?? 8;
  final endHour = prefs.getInt('end_hour') ?? 22;

  if (now.hour >= startHour && now.hour < endHour) {
    NotificationService.showNotification(
      "Mindfulness Reminder",
      AppStrings.notificationBody,
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
  int notificationInterval = 151; // Default

  String get dailyMessage {
    final day = DateTime.now().day;
    final messages =
        AppStrings.isGerman ? mindfulnessMessagesDe : mindfulnessMessagesEn;
    final index = day % messages.length;
    return messages[index];
  }

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  Future<void> _loadNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('notifications_active') ?? false;
    final interval = prefs.getInt('notification_interval') ?? 151;

    setState(() {
      notificationInterval = interval;
    });

    // Wenn Notifications aktiv sind, Alarm neu starten (wichtig für Updates!)
    if (status) {
      await AndroidAlarmManager.cancel(helloAlarmID);
      await AndroidAlarmManager.periodic(
        Duration(minutes: interval),
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
          title: Text(AppStrings.appTitle),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(text)]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppStrings.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );

    // Wenn Settings geändert wurden und Notifications aktiv sind, neu starten
    if (result == true && isNotificationActive) {
      await _loadNotificationStatus();
    }
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
      _showMyDialog(AppStrings.notificationsDeactivated);
    } else {
      // Aktivieren
      PermissionStatus status = await Permission.notification.request();

      if (status.isGranted) {
        // Sofort Test-Notification mit echter Mindfulness-Message
        try {
          final messages = AppStrings.isGerman
              ? mindfulnessMessagesDe
              : mindfulnessMessagesEn;
          final random = Random();
          final testMessage = messages[random.nextInt(messages.length)];

          await NotificationService.showNotification(
            AppStrings.appTitle,
            testMessage,
          );
        } catch (e) {
          // Fehler bei Test-Notification ignorieren
        }

        await AndroidAlarmManager.periodic(
          Duration(minutes: notificationInterval),
          helloAlarmID,
          printHello,
          wakeup: true,
          rescheduleOnReboot: true,
        );

        setState(() {
          isNotificationActive = true;
        });
        await _saveNotificationStatus(true);
        _showMyDialog(AppStrings.notificationsActivatedMessage);
      } else if (status.isDenied) {
        _showMyDialog(AppStrings.pleaseAllowNotifications);
      } else if (status.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppStrings.permissionRequired),
              content: Text(AppStrings.activateNotificationsInSettings),
              actions: <Widget>[
                TextButton(
                  child: Text(AppStrings.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(AppStrings.settings),
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
          // Hauptinhalt
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
                    color: isNotificationActive
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
                        ? AppStrings.notificationsActive
                        : AppStrings.notificationsInactive,
                    style: TextStyle(
                      color: isNotificationActive
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF4B5563),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (isNotificationActive)
                    Text(
                      "${notificationInterval}min",
                      style: const TextStyle(
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
                        color: isNotificationActive
                            ? const Color(0xFF4B5563)
                            : const Color(0xFF6B7280),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isNotificationActive
                          ? AppStrings.deactivateNotifications
                          : AppStrings.activateNotifications,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
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

          // Settings Icon oben rechts
          Positioned(
            top: 48,
            right: 24,
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF6B7280),
                size: 24,
              ),
              onPressed: _openSettings,
            ),
          ),
        ],
      ),
    );
  }
}
