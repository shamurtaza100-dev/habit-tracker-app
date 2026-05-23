import 'package:hive_flutter/hive_flutter.dart';

import '../../features/habits/models/habit.dart';
import '../../features/habits/models/habit_completion.dart';
import '../constants/app_constants.dart';

class HiveService {
  const HiveService._();

  static late Box<Habit> habitsBox;
  static late Box<HabitCompletion> completionsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(HabitAdapter.typeId)) {
      Hive.registerAdapter(HabitAdapter());
    }
    if (!Hive.isAdapterRegistered(HabitCompletionAdapter.typeId)) {
      Hive.registerAdapter(HabitCompletionAdapter());
    }

    habitsBox = await Hive.openBox<Habit>(AppConstants.habitsBox);
    completionsBox = await Hive.openBox<HabitCompletion>(
      AppConstants.completionsBox,
    );
  }
}
