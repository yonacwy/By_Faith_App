// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gospel_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GospelProfileAdapter extends TypeAdapter<GospelProfile> {
  @override
  final int typeId = 3;

  @override
  GospelProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GospelProfile(
      firstName: fields[0] as String?,
      lastName: fields[1] as String?,
      address: fields[2] as String?,
      naturalBirthday: fields[3] as DateTime?,
      phone: fields[4] as String?,
      email: fields[5] as String?,
      spiritualBirthday: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, GospelProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.firstName)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.naturalBirthday)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.spiritualBirthday);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GospelProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
