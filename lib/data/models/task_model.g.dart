// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 1;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      type: fields[3] as TaskType,
      priority: fields[4] as TaskPriority,
      affectedStat: fields[5] as String,
      expReward: fields[6] as int,
      coinReward: fields[7] as int,
      isCompleted: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      lastCompletedAt: fields[10] as DateTime?,
      completionCount: fields[11] as int,
      weekDays: (fields[12] as List?)?.cast<int>(),
      reminderTime: fields[13] as String?,
      notificationsEnabled: fields[14] as bool,
      deadline: fields[15] as DateTime?,
      tags: (fields[16] as List?)?.cast<String>(),
      notes: fields[17] as String?,
      streak: fields[18] as int,
      icon: fields[19] as String?,
      color: fields[20] as String?,
      isActive: fields[21] as bool,
      difficulty: fields[22] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.affectedStat)
      ..writeByte(6)
      ..write(obj.expReward)
      ..writeByte(7)
      ..write(obj.coinReward)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.lastCompletedAt)
      ..writeByte(11)
      ..write(obj.completionCount)
      ..writeByte(12)
      ..write(obj.weekDays)
      ..writeByte(13)
      ..write(obj.reminderTime)
      ..writeByte(14)
      ..write(obj.notificationsEnabled)
      ..writeByte(15)
      ..write(obj.deadline)
      ..writeByte(16)
      ..write(obj.tags)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.streak)
      ..writeByte(19)
      ..write(obj.icon)
      ..writeByte(20)
      ..write(obj.color)
      ..writeByte(21)
      ..write(obj.isActive)
      ..writeByte(22)
      ..write(obj.difficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskTypeAdapter extends TypeAdapter<TaskType> {
  @override
  final int typeId = 3;

  @override
  TaskType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskType.daily;
      case 1:
        return TaskType.weekly;
      case 2:
        return TaskType.custom;
      case 3:
        return TaskType.habit;
      default:
        return TaskType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, TaskType obj) {
    switch (obj) {
      case TaskType.daily:
        writer.writeByte(0);
        break;
      case TaskType.weekly:
        writer.writeByte(1);
        break;
      case TaskType.custom:
        writer.writeByte(2);
        break;
      case TaskType.habit:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 4;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      default:
        return TaskPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.low:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
