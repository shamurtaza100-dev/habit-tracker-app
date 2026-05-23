import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/date_utils.dart';
import '../../habits/providers/habit_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitControllerProvider);
    final totalCompletions = state.completions.length;
    final bestStreak = state.habits.fold<int>(
      0,
      (best, habit) {
        final streak = state.longestStreak(habit.id);
        return streak > best ? streak : best;
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Completions',
                  value: '$totalCompletions',
                  icon: Icons.done_all,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Best streak',
                  value: '$bestStreak',
                  icon: Icons.local_fire_department,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last 30 days',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 220,
                    child: BarChart(_chartData(context, state)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _chartData(BuildContext context, HabitState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now().dateOnly;
    final days = List.generate(
      30,
      (index) => today.subtract(Duration(days: 29 - index)),
    );

    return BarChartData(
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= days.length || index % 7 != 0) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(DateFormat.MMMd().format(days[index])),
              );
            },
          ),
        ),
      ),
      barGroups: [
        for (var index = 0; index < days.length; index++)
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: state.completions
                    .where(
                      (completion) =>
                          isSameDate(completion.completedDate, days[index]),
                    )
                    .length
                    .toDouble(),
                width: 7,
                borderRadius: BorderRadius.circular(999),
                color: colorScheme.primary,
              ),
            ],
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
