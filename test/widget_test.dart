import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/models/habit.dart';

void main() {
  test('habit frequency labels are user friendly', () {
    expect(HabitFrequency.daily.label, 'Daily');
    expect(HabitFrequency.weekly.label, 'Weekly');
  });
}
