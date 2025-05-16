// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gospel_page.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MapInfoAdapter extends TypeAdapter<MapInfo> {
  @override
  final int typeId = 1;

  @override
  MapInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MapInfo(
      name: fields[0] as String,
      filePath: fields[1] as String,
      downloadUrl: fields[2] as String,
      isTemporary: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MapInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.downloadUrl)
      ..writeByte(3)
      ..write(obj.isTemporary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
