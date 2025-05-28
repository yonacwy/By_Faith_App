import 'package:by_faith_app/models/gospel_map_sub_directory_model.dart';

class Directory {
  final String name;
  final List<SubDirectory> subDirectories;

  Directory({
    required this.name,
    required this.subDirectories,
  });

  factory Directory.fromJson(Map<String, dynamic> json, Map<String, Map<String, dynamic>> coordinateMap) {
    return Directory(
      name: json['name'],
      subDirectories: (json['subDirectories'] as List<dynamic>?)
              ?.map((subDirJson) => SubDirectory.fromJson(subDirJson as Map<String, dynamic>, coordinateMap))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subDirectories': subDirectories.map((s) => s.toJson()).toList(),
    };
  }
}