import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum HabitFrequency {
  daily,
  weekly;

  String get label => switch (this) {
        HabitFrequency.daily => 'Daily',
        HabitFrequency.weekly => 'Weekly',
      };
}

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.color,
    required this.icon,
    required this.createdAt,
    this.reminderTime,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final String description;
  final HabitFrequency frequency;
  final TimeOfDay? reminderTime;
  final int color;
  final String icon;
  final DateTime createdAt;
  final bool isArchived;

  Habit copyWith({
    String? title,
    String? description,
    HabitFrequency? frequency,
    TimeOfDay? reminderTime,
    int? color,
    String? icon,
    bool? isArchived,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class HabitAdapter extends TypeAdapter<Habit> {
  static const typeId = 1;

  @override
  int get typeId => HabitAdapter.typeId;

  @override
  Habit read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final count = reader.readByte();

    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }

    final reminderMinutes = fields[4] as int?;

    return Habit(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String? ?? '',
      frequency: HabitFrequency.values[fields[3] as int],
      reminderTime: reminderMinutes == null
          ? null
          : TimeOfDay(
              hour: reminderMinutes ~/ 60,
              minute: reminderMinutes % 60,
            ),
      color: fields[5] as int,
      icon: fields[6] as String,
      createdAt: fields[7] as DateTime,
      isArchived: fields[8] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.frequency.index)
      ..writeByte(4)
      ..write(
        obj.reminderTime == null
            ? null
            : obj.reminderTime!.hour * 60 + obj.reminderTime!.minute,
      )
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.icon)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isArchived);
  }
}
