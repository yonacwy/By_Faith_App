import 'package:by_faith_app/models/gospel_map_entry_data_model.dart';

class SubDirectory {
  final String name;
  final List<GospelMapEntryData> maps;
  final List<SubDirectory> subDirectories;

  SubDirectory({
    required this.name,
    required this.maps,
    required this.subDirectories,
  });

  factory SubDirectory.fromJson(Map<String, dynamic> json, Map<String, Map<String, dynamic>> coordinateMap) {
    return SubDirectory(
      name: json['name'],
      maps: (json['maps'] as List<dynamic>?)
              ?.map((mapJson) => GospelMapEntryData.fromJson(mapJson as Map<String, dynamic>, coordinateMap))
              .toList() ??
          [],
      subDirectories: (json['subDirectories'] as List<dynamic>?)
              ?.map((subDirJson) => SubDirectory.fromJson(subDirJson as Map<String, dynamic>, coordinateMap))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'maps': maps.map((m) => {
            'name': m.name,
            'primaryUrl': m.primaryUrl,
            'fallbackUrl': m.fallbackUrl,
          }).toList(),
      'subDirectories': subDirectories.map((s) => s.toJson()).toList(),
    };
  }
}