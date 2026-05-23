import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/hive_service.dart';
import '../../../core/utils/date_utils.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../repository/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(
    habitsBox: HiveService.habitsBox,
    completionsBox: HiveService.completionsBox,
  );
});

final habitControllerProvider =
    StateNotifierProvider<HabitController, HabitState>((ref) {
  return HabitController(ref.watch(habitRepositoryProvider));
});

class HabitState {
  const HabitState({
    required this.habits,
    required this.completions,
  });

  final List<Habit> habits;
  final List<HabitCompletion> completions;

  double get todayProgress {
    if (habits.isEmpty) {
      return 0;
    }

    final completedCount = habits.where(isCompletedToday).length;
    return completedCount / habits.length;
  }

  bool isCompletedToday(Habit habit) {
    final today = DateTime.now().dateOnly;

    return completions.any(
      (completion) =>
          completion.habitId == habit.id &&
          isSameDate(completion.completedDate, today),
    );
  }

  int currentStreak(String habitId) {
    final completionDates = completions
        .where((completion) => completion.habitId == habitId)
        .map((completion) => completion.completedDate.dateOnly)
        .toSet();

    var streak = 0;
    var cursor = DateTime.now().dateOnly;

    while (completionDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int longestStreak(String habitId) {
    final completionDates = completions
        .where((completion) => completion.habitId == habitId)
        .map((completion) => completion.completedDate.dateOnly)
        .toSet()
        .toList()
      ..sort();

    var longest = 0;
    var current = 0;
    DateTime? previous;

    for (final date in completionDates) {
      if (previous == null || date.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }

      longest = current > longest ? current : longest;
      previous = date;
    }

    return longest;
  }
}

class HabitController extends StateNotifier<HabitState> {
  HabitController(this._repository)
      : super(
          HabitState(
            habits: _repository.getHabits(),
            completions: _repository.getCompletions(),
          ),
        );

  final HabitRepository _repository;
  final _uuid = const Uuid();

  Future<void> addHabit({
    required String title,
    required String description,
    required HabitFrequency frequency,
    required TimeOfDay? reminderTime,
    required int color,
    required String icon,
  }) async {
    final habit = Habit(
      id: _uuid.v4(),
      title: title,
      description: description,
      frequency: frequency,
      reminderTime: reminderTime,
      color: color,
      icon: icon,
      createdAt: DateTime.now(),
    );

    await _repository.addHabit(habit);
    _refresh();
  }

  Future<void> archiveHabit(String habitId) async {
    await _repository.archiveHabit(habitId);
    _refresh();
  }

  Future<void> toggleToday(String habitId) async {
    await _repository.toggleToday(habitId);
    _refresh();
  }

  void _refresh() {
    state = HabitState(
      habits: _repository.getHabits(),
      completions: _repository.getCompletions(),
    );
  }
}
