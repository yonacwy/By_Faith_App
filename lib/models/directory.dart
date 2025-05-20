import 'package:hive/hive.dart';
import 'sub_directory.dart'; // Import the SubDirectory model

part 'directory.g.dart';

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