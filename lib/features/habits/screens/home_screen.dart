import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/empty_state.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_card.dart';
import '../widgets/progress_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitControllerProvider);
    final controller = ref.read(habitControllerProvider.notifier);
    final completed = state.habits.where(state.isCompletedToday).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/habits/new'),
        icon: const Icon(Icons.add),
        label: const Text('Habit'),
      ),
      body: SafeArea(
        child: state.habits.isEmpty
            ? const EmptyState(
                icon: Icons.add_task,
                title: 'Create your first habit',
                message:
                    'Start small. Track one thing today and build from there.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: state.habits.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ProgressHeader(
                      progress: state.todayProgress,
                      completed: completed,
                      total: state.habits.length,
                    );
                  }

                  final habit = state.habits[index - 1];
                  return HabitCard(
                    habit: habit,
                    isCompleted: state.isCompletedToday(habit),
                    streak: state.currentStreak(habit.id),
                    onToggle: () => controller.toggleToday(habit.id),
                    onArchive: () => controller.archiveHabit(habit.id),
                  );
                },
              ),
      ),
    );
  }
}
