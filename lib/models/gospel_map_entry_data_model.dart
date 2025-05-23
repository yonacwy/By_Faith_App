import 'package:hive/hive.dart';

part 'gospel_map_entry_data_model.g.dart';

@HiveType(typeId: 2)
class GospelMapEntryData extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String primaryUrl;

  @HiveField(2)
  final String fallbackUrl;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final int zoomLevel;

  GospelMapEntryData({
    required this.name,
    required this.primaryUrl,
    required this.fallbackUrl,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  factory GospelMapEntryData.fromJson(Map<String, dynamic> json, Map<String, Map<String, dynamic>> coordinateMap) {
    final name = json['name'] as String;
    final coords = coordinateMap[name] ?? {'latitude': 0.0, 'longitude': 0.0, 'zoomLevel': 2};
    return GospelMapEntryData(
      name: name,
      primaryUrl: json['primaryUrl'] as String,
      fallbackUrl: json['fallbackUrl'] as String,
      latitude: coords['latitude'] as double,
      longitude: coords['longitude'] as double,
      zoomLevel: coords['zoomLevel'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'primaryUrl': primaryUrl,
        'fallbackUrl': fallbackUrl,
        'latitude': latitude,
        'longitude': longitude,
        'zoomLevel': zoomLevel,
      };
}