import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    print('[NotificationService] Initialized successfully');
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('[NotificationService] Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool granted = true;

    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission() ?? false;
      await androidPlugin.requestExactAlarmsPermission();
    }

    if (iosPlugin != null) {
      granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
    }

    print('[NotificationService] Permissions granted: $granted');
    return granted;
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    if (!_isInitialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Medication and appointment reminders',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        reminder.description ?? reminder.title,
        contentTitle: reminder.title,
      ),
      actions: const [
        AndroidNotificationAction('taken', 'Taken'),
        AndroidNotificationAction('snooze', 'Snooze'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = tz.TZDateTime.from(reminder.scheduledTime, tz.local);

    if (reminder.repeatDaily) {
      await _notifications.zonedSchedule(
        reminder.id.hashCode,
        reminder.title,
        reminder.description,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      await _notifications.zonedSchedule(
        reminder.id.hashCode,
        reminder.title,
        reminder.description,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    print('[NotificationService] Scheduled reminder: ${reminder.title} at $scheduledDate');
  }

  Future<void> cancelReminder(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
    print('[NotificationService] Cancelled reminder: $reminderId');
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    print('[NotificationService] Cancelled all reminders');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}