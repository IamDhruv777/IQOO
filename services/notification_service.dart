import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/memory.dart';

/// Manages local device notifications for deadline reminders.
/// Uses flutter_local_notifications — no backend required.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    // Request notification permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleReminder(Memory memory, DateTime notifyAt) async {
    const androidDetails = AndroidNotificationDetails(
      'memorylens_reminders',
      'MemoryLens Reminders',
      channelDescription: 'Deadline reminders from your captured memories',
      importance: Importance.high,
      priority: Priority.high,
    );

    // If the scheduled time is in the past, trigger it immediately so it doesn't fail silently
    if (notifyAt.isBefore(DateTime.now())) {
      await _plugin.show(
        memory.id.hashCode,
        '⏰ Reminder: ${memory.title}',
        memory.summary,
        const NotificationDetails(android: androidDetails),
      );
      return;
    }

    await _plugin.zonedSchedule(
      memory.id.hashCode,
      '⏰ Reminder: ${memory.title}',
      memory.summary,
      tz.TZDateTime.from(notifyAt, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Schedule an advance notification (1 day before) if possible
    final advanceTime = notifyAt.subtract(const Duration(days: 1));
    if (advanceTime.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        memory.id.hashCode + 1, // different ID
        '🔜 Coming up tomorrow: ${memory.title}',
        'You have a deadline tomorrow for this memory.',
        tz.TZDateTime.from(advanceTime, tz.local),
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelReminder(String memoryId) async {
    await _plugin.cancel(memoryId.hashCode);
    await _plugin.cancel(memoryId.hashCode + 1);
  }
}
