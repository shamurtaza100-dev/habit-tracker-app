import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/habit.dart';
import '../providers/habit_providers.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  HabitFrequency _frequency = HabitFrequency.daily;
  TimeOfDay? _reminderTime;
  int _selectedColor = const Color(0xFF4F46E5).value;
  String _selectedIcon = 'star';

  static const _colors = [
    Color(0xFF4F46E5),
    Color(0xFF16A34A),
    Color(0xFFF97316),
    Color(0xFFDB2777),
    Color(0xFF0891B2),
  ];

  static const _icons = {
    'star': Icons.star,
    'fitness': Icons.fitness_center,
    'book': Icons.menu_book,
    'water': Icons.water_drop,
    'sleep': Icons.bedtime,
    'mind': Icons.self_improvement,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Habit name',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a habit name';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 18),
            SegmentedButton<HabitFrequency>(
              segments: HabitFrequency.values
                  .map(
                    (frequency) => ButtonSegment(
                      value: frequency,
                      label: Text(frequency.label),
                    ),
                  )
                  .toList(),
              selected: {_frequency},
              onSelectionChanged: (selection) {
                setState(() => _frequency = selection.first);
              },
            ),
            const SizedBox(height: 18),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Reminder'),
              subtitle: Text(
                _reminderTime == null
                    ? 'No reminder'
                    : _reminderTime!.format(context),
              ),
              trailing: TextButton(
                onPressed: _pickReminder,
                child: const Text('Set'),
              ),
            ),
            const SizedBox(height: 10),
            Text('Icon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _icons.entries.map((entry) {
                final selected = entry.key == _selectedIcon;
                return IconButton.filledTonal(
                  isSelected: selected,
                  onPressed: () => setState(() => _selectedIcon = entry.key),
                  icon: Icon(entry.value),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Text('Color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: _colors.map((color) {
                final selected = color.value == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color.value),
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: selected
                            ? colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Habit'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReminder() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(habitControllerProvider.notifier).addHabit(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          frequency: _frequency,
          reminderTime: _reminderTime,
          color: _selectedColor,
          icon: _selectedIcon,
        );

    if (mounted) {
      context.pop();
    }
  }
}
