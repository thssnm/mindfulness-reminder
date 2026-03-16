import 'dart:ui' as ui;

class AppStrings {
  static String get locale =>
      ui.PlatformDispatcher.instance.locale.languageCode;

  static bool get isGerman => locale == 'de';

  // App Titel
  static String get appTitle => "Mindfulness Reminder";

  // Buttons
  static String get activateNotifications =>
      isGerman ? "Benachrichtigungen aktivieren" : "Activate notifications";

  static String get deactivateNotifications =>
      isGerman ? "Benachrichtigungen deaktivieren" : "Deactivate notifications";

  // Status
  static String get notificationsActive =>
      isGerman ? "Benachrichtigungen Aktiv" : "Notifications Active";

  static String get notificationsInactive =>
      isGerman ? "Benachrichtigungen Inaktiv" : "Notifications Inactive";

  // Dialog Texte
  static String get notificationsActivatedTitle =>
      isGerman ? "Benachrichtigungen aktiviert" : "Notifications activated";

  static String get notificationsActivatedMessage => isGerman
      ? "Du erhältst Erinnerungen im gewählten Intervall"
      : "You'll receive reminders at the selected interval";

  static String get notificationsDeactivated =>
      isGerman ? "Benachrichtigungen deaktiviert" : "Notifications deactivated";

  static String get pleaseAllowNotifications => isGerman
      ? "Bitte erlaube Benachrichtigungen in den Einstellungen"
      : "Please allow notifications in settings";

  static String get permissionRequired =>
      isGerman ? "Berechtigung erforderlich" : "Permission required";

  static String get activateNotificationsInSettings => isGerman
      ? "Bitte aktiviere Benachrichtigungen in den App-Einstellungen"
      : "Please activate notifications in app settings";

  static String get cancel => isGerman ? "Abbrechen" : "Cancel";
  static String get settings => isGerman ? "Einstellungen" : "Settings";
  static String get ok => "Ok";

  // Notification
  static String get notificationBody => isGerman
      ? "Nimm dir einen Moment und sei ganz im Hier und Jetzt."
      : "Take a moment and be fully present in the here and now.";

  // Settings Screen
  static String get notificationInterval =>
      isGerman ? "Benachrichtigungs-Intervall" : "Notification Interval";

  static String get activeTimeWindow =>
      isGerman ? "Aktive Zeitfenster" : "Active Time Window";

  static String get startTime => isGerman ? "Start" : "Start";

  static String get endTime => isGerman ? "Ende" : "End";

  static String get everyHour => isGerman ? "Jede Stunde" : "Every hour";

  static String get every90Minutes =>
      isGerman ? "Alle 90 Minuten" : "Every 90 minutes";

  static String get every2Hours =>
      isGerman ? "Alle 2 Stunden" : "Every 2 hours";

  static String get every2AndHalfHours =>
      isGerman ? "Alle 2,5 Stunden" : "Every 2.5 hours";

  static String get every3Hours =>
      isGerman ? "Alle 3 Stunden" : "Every 3 hours";

  static String get settingsNote => isGerman
      ? "Hinweis: Änderungen werden beim nächsten Neustart der Benachrichtigungen aktiv."
      : "Note: Changes will take effect when notifications are restarted.";
}
