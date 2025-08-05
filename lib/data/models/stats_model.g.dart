// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatsModelAdapter extends TypeAdapter<StatsModel> {
  @override
  final int typeId = 2;

  @override
  StatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatsModel(
      userId: fields[0] as String,
      health: fields[1] as double,
      income: fields[2] as double,
      sport: fields[3] as double,
      love: fields[4] as double,
      social: fields[5] as double,
      education: fields[6] as double,
      career: fields[7] as double,
      hobby: fields[8] as double,
      spirituality: fields[9] as double,
      entertainment: fields[10] as double,
      lastUpdated: fields[11] as DateTime,
      history: (fields[12] as List?)?.cast<StatsHistory>(),
      lifeBalance: fields[13] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, StatsModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.health)
      ..writeByte(2)
      ..write(obj.income)
      ..writeByte(3)
      ..write(obj.sport)
      ..writeByte(4)
      ..write(obj.love)
      ..writeByte(5)
      ..write(obj.social)
      ..writeByte(6)
      ..write(obj.education)
      ..writeByte(7)
      ..write(obj.career)
      ..writeByte(8)
      ..write(obj.hobby)
      ..writeByte(9)
      ..write(obj.spirituality)
      ..writeByte(10)
      ..write(obj.entertainment)
      ..writeByte(11)
      ..write(obj.lastUpdated)
      ..writeByte(12)
      ..write(obj.history)
      ..writeByte(13)
      ..write(obj.lifeBalance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatsHistoryAdapter extends TypeAdapter<StatsHistory> {
  @override
  final int typeId = 5;

  @override
  StatsHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatsHistory(
      date: fields[0] as DateTime,
      stats: (fields[1] as Map).cast<String, double>(),
      lifeBalance: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, StatsHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.stats)
      ..writeByte(2)
      ..write(obj.lifeBalance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
