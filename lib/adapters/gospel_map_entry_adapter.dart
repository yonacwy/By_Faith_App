import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:by_faith_app/models/gospel_map_entry_data_model.dart';

class GospelMapEntryDataAdapter extends TypeAdapter<GospelMapEntryData> {
  @override
  final int typeId = 3; // Adjust typeId as needed

  @override
  GospelMapEntryData read(BinaryReader reader) {
    return GospelMapEntryData(
      name: reader.readString(),
      primaryUrl: reader.readString(),
      fallbackUrl: reader.readString(),
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
      zoomLevel: reader.readInt(),
      bounds: Bounds(
        southwest: latlong2.LatLng(reader.readDouble(), reader.readDouble()),
        northeast: latlong2.LatLng(reader.readDouble(), reader.readDouble()),
      ),
    );
  }

  @override
  void write(BinaryWriter writer, GospelMapEntryData obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.primaryUrl);
    writer.writeString(obj.fallbackUrl);
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
    writer.writeInt(obj.zoomLevel);
    writer.writeDouble(obj.bounds.southwest.latitude);
    writer.writeDouble(obj.bounds.southwest.longitude);
    writer.writeDouble(obj.bounds.northeast.latitude);
    writer.writeDouble(obj.bounds.northeast.longitude);
  }
}