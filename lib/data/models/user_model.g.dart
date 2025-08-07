// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarPath: fields[2] as String?,
      avatarUrl: fields[3] as String?,
      level: fields[4] as int,
      currentExp: fields[5] as int,
      expToNextLevel: fields[6] as int,
      totalTasksCompleted: fields[7] as int,
      currentStreak: fields[8] as int,
      maxStreak: fields[9] as int,
      createdAt: fields[10] as DateTime,
      lastLoginAt: fields[11] as DateTime?,
      coins: fields[12] as int,
      gems: fields[13] as int,
      achievements: (fields[14] as List?)?.cast<String>(),
      notificationsEnabled: fields[15] as bool,
      dailyReminderTime: fields[16] as String?,
      theme: fields[17] as String,
      language: fields[18] as String,
      avatarBytes: (fields[19] as List?)?.cast<int>(),
      gender: fields[20] as String,
      rpmAvatarUrl: fields[21] as String?,
      rpmAvatarId: fields[22] as String?,
      useRpmAvatar: fields[23] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarPath)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.currentExp)
      ..writeByte(6)
      ..write(obj.expToNextLevel)
      ..writeByte(7)
      ..write(obj.totalTasksCompleted)
      ..writeByte(8)
      ..write(obj.currentStreak)
      ..writeByte(9)
      ..write(obj.maxStreak)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.lastLoginAt)
      ..writeByte(12)
      ..write(obj.coins)
      ..writeByte(13)
      ..write(obj.gems)
      ..writeByte(14)
      ..write(obj.achievements)
      ..writeByte(15)
      ..write(obj.notificationsEnabled)
      ..writeByte(16)
      ..write(obj.dailyReminderTime)
      ..writeByte(17)
      ..write(obj.theme)
      ..writeByte(18)
      ..write(obj.language)
      ..writeByte(19)
      ..write(obj.avatarBytes)
      ..writeByte(20)
      ..write(obj.gender)
      ..writeByte(21)
      ..write(obj.rpmAvatarUrl)
      ..writeByte(22)
      ..write(obj.rpmAvatarId)
      ..writeByte(23)
      ..write(obj.useRpmAvatar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
