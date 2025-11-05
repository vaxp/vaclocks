import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final Map<int, Timer> _fallbackTimers = {};

  static const AndroidNotificationChannel _timerChannel = AndroidNotificationChannel(
    'timer_channel',
    'Timers',
    description: 'Notifications for running and finished timers',
    importance: Importance.high,
  );

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    final linuxInit = LinuxInitializationSettings(defaultActionName: 'Open');
    final settings = InitializationSettings(android: androidInit, iOS: iosInit, linux: linuxInit);
    await _plugin.initialize(settings);

    // Create Android channel
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_timerChannel);

    // Request permissions on platforms that require it
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    // exact alarm permission API may vary by Android version; handled by requestExactAlarmsPermission above
    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true, badge: true);
    if (kIsWeb) {
      // no-op for web
    }
  }

  Future<void> showInstant({required int id, required String title, required String body}) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(_timerChannel.id, _timerChannel.name,
          channelDescription: _timerChannel.description, importance: Importance.high, priority: Priority.high),
      iOS: const DarwinNotificationDetails(),
      linux: const LinuxNotificationDetails(urgency: LinuxNotificationUrgency.critical),
    );
    await _plugin.show(id, title, body, details);
  }

  Future<void> scheduleAfter({required int id, required Duration delay, required String title, required String body}) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(_timerChannel.id, _timerChannel.name,
          channelDescription: _timerChannel.description, importance: Importance.high, priority: Priority.high),
      iOS: const DarwinNotificationDetails(),
    );
    final when = DateTime.now().add(delay);
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } else {
      // Fallback for platforms without zoned schedule implementation (e.g., Linux, macOS, web)
      _fallbackTimers[id]?.cancel();
      _fallbackTimers[id] = Timer(delay, () => showInstant(id: id, title: title, body: body));
    }
  }

  Future<void> cancel(int id) async {
    _fallbackTimers.remove(id)?.cancel();
    await _plugin.cancel(id);
  }
}

// Needed for zoned scheduling
