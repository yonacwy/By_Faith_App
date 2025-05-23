import 'package:hive/hive.dart';
import '../ui/gospel_page_ui.dart';
import '../models/gospel_map_directory_model.dart';
import '../models/gospel_map_sub_directory_model.dart';
import '../models/gospel_map_entry_data_model.dart';

class GospelMapSubDirectoryAdapter extends TypeAdapter<SubDirectory> {
  @override
  final int typeId = 3;

  @override
  SubDirectory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubDirectory(
      name: fields[0] as String,
      maps: (fields[1] as List).cast<GospelMapEntryData>(),
      subDirectories: (fields[2] as List).cast<SubDirectory>(),
    );
  }

  @override
  void write(BinaryWriter writer, SubDirectory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.maps)
      ..writeByte(2)
      ..write(obj.subDirectories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GospelMapSubDirectoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}