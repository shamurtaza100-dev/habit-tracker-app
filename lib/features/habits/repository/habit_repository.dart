import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/date_utils.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';

class HabitRepository {
  HabitRepository({
    required Box<Habit> habitsBox,
    required Box<HabitCompletion> completionsBox,
  })  : _habitsBox = habitsBox,
        _completionsBox = completionsBox;

  final Box<Habit> _habitsBox;
  final Box<HabitCompletion> _completionsBox;
  final _uuid = const Uuid();

  List<Habit> getHabits({bool includeArchived = false}) {
    final habits = _habitsBox.values
        .where((habit) => includeArchived || !habit.isArchived)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return habits;
  }

  List<HabitCompletion> getCompletions() {
    return _completionsBox.values.toList()
      ..sort((a, b) => b.completedDate.compareTo(a.completedDate));
  }

  Future<void> addHabit(Habit habit) {
    return _habitsBox.put(habit.id, habit);
  }

  Future<void> archiveHabit(String habitId) async {
    final habit = _habitsBox.get(habitId);
    if (habit == null) {
      return;
    }

    await _habitsBox.put(habitId, habit.copyWith(isArchived: true));
  }

  Future<void> toggleToday(String habitId) async {
    final today = DateTime.now().dateOnly;
    final existing = _completionsBox.values.where(
      (completion) =>
          completion.habitId == habitId &&
          isSameDate(completion.completedDate, today),
    );

    if (existing.isNotEmpty) {
      await _completionsBox.delete(existing.first.id);
      return;
    }

    final completion = HabitCompletion(
      id: _uuid.v4(),
      habitId: habitId,
      completedDate: today,
    );

    await _completionsBox.put(completion.id, completion);
  }
}
