import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/habits/models/habit.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  NotificationService.instance.handleNotificationResponse(response);
}

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  static const snoozeActionId = 'snooze';
  static const _channelId = 'habit_alarm_reminders';
  static const _channelName = 'Habit alarm reminders';
  static const _channelDescription =
      'Alarm-style reminders with snooze actions for habits.';
  static const _snoozeDelay = Duration(minutes: 10);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  var _timeZonesInitialized = false;

  Future<void> init() async {
    _initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await _requestAndroidPermissions();
  }

  Future<void> scheduleHabitReminders(Iterable<Habit> habits) async {
    for (final habit in habits) {
      await scheduleHabitReminder(habit);
    }
  }

  Future<void> scheduleHabitReminder(Habit habit) async {
    if (habit.reminderTime == null || habit.isArchived) {
      await cancelHabitReminder(habit.id);
      return;
    }

    await cancelHabitReminder(habit.id);

    switch (habit.reminderInterval) {
      case HabitReminderInterval.daily:
        await _scheduleDailyReminder(habit);
      case HabitReminderInterval.hourly:
        await _scheduleHourlyReminders(habit);
    }
  }

  Future<void> cancelHabitReminder(String habitId) async {
    final baseId = _notificationBaseId(habitId);

    await _plugin.cancel(baseId);
    await _plugin.cancel(_snoozeNotificationId(habitId));

    for (var hour = 0; hour < 24; hour++) {
      await _plugin.cancel(_hourlyNotificationId(baseId, hour));
    }
  }

  Future<void> handleNotificationResponse(NotificationResponse response) async {
    if (response.actionId != snoozeActionId) {
      return;
    }

    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }

    final data = jsonDecode(payload) as Map<String, dynamic>;
    final habitId = data['habitId'] as String?;
    final title = data['title'] as String?;
    final body = data['body'] as String?;

    if (habitId == null || title == null || body == null) {
      return;
    }

    _initializeTimeZones();
    await _plugin.zonedSchedule(
      _snoozeNotificationId(habitId),
      title,
      body,
      tz.TZDateTime.now(tz.local).add(_snoozeDelay),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> showReminderPreview({
    required String title,
    required String body,
  }) async {
    final details = _notificationDetails();

    await _plugin.show(title.hashCode, title, body, details);
  }

  Future<void> _scheduleDailyReminder(Habit habit) {
    final time = habit.reminderTime!;

    return _plugin.zonedSchedule(
      _notificationBaseId(habit.id),
      _titleFor(habit),
      _bodyFor(habit),
      _nextInstanceOfTime(time),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _payloadFor(habit),
    );
  }

  Future<void> _scheduleHourlyReminders(Habit habit) async {
    final time = habit.reminderTime!;
    final baseId = _notificationBaseId(habit.id);

    for (var hour = 0; hour < 24; hour++) {
      await _plugin.zonedSchedule(
        _hourlyNotificationId(baseId, hour),
        _titleFor(habit),
        _bodyFor(habit),
        _nextInstanceOfTime(TimeOfDay(hour: hour, minute: time.minute)),
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: _payloadFor(habit),
      );
    }
  }

  Future<void> _requestAndroidPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    await android?.requestFullScreenIntentPermission();
  }

  NotificationDetails _notificationDetails() {
    final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        fullScreenIntent: true,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        additionalFlags: Int32List.fromList([4]),
        actions: const [
          AndroidNotificationAction(
            snoozeActionId,
            'Snooze 10 min',
            cancelNotification: true,
          ),
        ],
      ),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  void _initializeTimeZones() {
    if (_timeZonesInitialized) {
      return;
    }

    tz_data.initializeTimeZones();

    final offset = DateTime.now().timeZoneOffset;
    final abbreviation = DateTime.now().timeZoneName;
    final fixedLocalLocation = tz.Location(
      abbreviation,
      const [],
      const [],
      [
        tz.TimeZone(
          offset.inMilliseconds,
          isDst: false,
          abbreviation: abbreviation,
        ),
      ],
    );
    tz.setLocalLocation(fixedLocalLocation);
    _timeZonesInitialized = true;
  }

  int _notificationBaseId(String habitId) {
    var hash = 2166136261;
    for (final unit in habitId.codeUnits) {
      hash ^= unit;
      hash = (hash * 16777619) & 0x7fffffff;
    }

    return 100000 + hash % 700000000;
  }

  int _hourlyNotificationId(int baseId, int hour) => baseId + hour + 1;

  int _snoozeNotificationId(String habitId) =>
      _notificationBaseId(habitId) + 50000;

  String _titleFor(Habit habit) => 'Habit reminder';

  String _bodyFor(Habit habit) => 'Time to complete ${habit.title}.';

  String _payloadFor(Habit habit) {
    return jsonEncode({
      'habitId': habit.id,
      'title': _titleFor(habit),
      'body': _bodyFor(habit),
    });
  }
}
