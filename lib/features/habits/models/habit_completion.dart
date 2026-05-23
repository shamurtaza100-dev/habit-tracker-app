import 'package:hive/hive.dart';

class HabitCompletion {
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedDate,
  });

  final String id;
  final String habitId;
  final DateTime completedDate;
}

class HabitCompletionAdapter extends TypeAdapter<HabitCompletion> {
  static const typeId = 2;

  @override
  int get typeId => HabitCompletionAdapter.typeId;

  @override
  HabitCompletion read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final count = reader.readByte();

    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return HabitCompletion(
      id: fields[0] as String,
      habitId: fields[1] as String,
      completedDate: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HabitCompletion obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.completedDate);
  }
}
