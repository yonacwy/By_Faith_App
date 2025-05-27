import 'package:hive/hive.dart';

part 'gospel_map_info_model.g.dart'; // Required for Hive code generation

@HiveType(typeId: 5) // Assign a unique typeId
class MapInfo extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String filePath;

  @HiveField(2)
  final String downloadUrl;

  @HiveField(3)
  final bool isTemporary;

  @HiveField(4)
  final double latitude;

  @HiveField(5)
  final double longitude;

  @HiveField(6)
  final int zoomLevel;

  MapInfo({
    required this.name,
    required this.filePath,
    required this.downloadUrl,
    this.isTemporary = false,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });
}