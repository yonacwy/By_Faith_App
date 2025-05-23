import 'package:hive/hive.dart';
import 'gospel_map_sub_directory_model.dart'; // Import the SubDirectory model

part 'gospel_map_directory_model.g.dart';

@HiveType(typeId: 4)
class Directory extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<SubDirectory> subDirectories;

  Directory({
    required this.name,
    required this.subDirectories,
  });

  factory Directory.fromJson(Map<String, dynamic> json, Map<String, Map<String, dynamic>> coordinateMap) => Directory(
        name: json['name'] as String,
        subDirectories: (json['subDirectories'] as List<dynamic>?)
                ?.map((s) => SubDirectory.fromJson(s as Map<String, dynamic>, coordinateMap))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'subDirectories': subDirectories.map((s) => s.toJson()).toList(),
      };
}