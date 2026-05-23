import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    required this.habit,
    required this.isCompleted,
    required this.streak,
    required this.onToggle,
    required this.onArchive,
    super.key,
  });

  final Habit habit;
  final bool isCompleted;
  final int streak;
  final VoidCallback onToggle;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final habitColor = Color(habit.color);

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      background: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.archive_outlined, color: colorScheme.error),
          ),
        ),
      ),
      onDismissed: (_) => onArchive(),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: habitColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_iconFor(habit.icon), color: habitColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    IconButton.filledTonal(
                      onPressed: onToggle,
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                    ),
                    Text(
                      '$streak day',
                      style: textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    final parts = [
      habit.frequency.label,
      if (habit.reminderTime != null)
        DateFormat.jm().format(
          DateTime(
            2024,
            1,
            1,
            habit.reminderTime!.hour,
            habit.reminderTime!.minute,
          ),
        ),
    ];

    return parts.join(' • ');
  }

  IconData _iconFor(String icon) {
    return switch (icon) {
      'fitness' => Icons.fitness_center,
      'book' => Icons.menu_book,
      'water' => Icons.water_drop,
      'sleep' => Icons.bedtime,
      'mind' => Icons.self_improvement,
      _ => Icons.star,
    };
  }
}
