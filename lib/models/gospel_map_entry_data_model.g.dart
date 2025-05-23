// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gospel_map_entry_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GospelMapEntryDataAdapter extends TypeAdapter<GospelMapEntryData> {
  @override
  final int typeId = 2;

  @override
  GospelMapEntryData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GospelMapEntryData(
      name: fields[0] as String,
      primaryUrl: fields[1] as String,
      fallbackUrl: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      zoomLevel: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GospelMapEntryData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.primaryUrl)
      ..writeByte(2)
      ..write(obj.fallbackUrl)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.zoomLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GospelMapEntryDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
