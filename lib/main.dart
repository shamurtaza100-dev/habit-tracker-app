import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await NotificationService.instance.init();
  await NotificationService.instance.scheduleHabitReminders(
    HiveService.habitsBox.values.where((habit) => !habit.isArchived),
  );

  runApp(
    const ProviderScope(
      child: HabitTrackerApp(),
    ),
  );
}
