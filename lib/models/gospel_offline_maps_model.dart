import 'package:objectbox/objectbox.dart';

@Entity()
class GospelOfflineMapsModel {
  @Id()
  int id = 0;
  final String name;
  final String filePath;
  final String downloadUrl;
  final bool isTemporary;
  double latitude;
  double longitude;
  int zoomLevel;

  GospelOfflineMapsModel({
    required this.name,
    required this.filePath,
    required this.downloadUrl,
    required this.isTemporary,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'filePath': filePath,
      'downloadUrl': downloadUrl,
      'isTemporary': isTemporary,
      'latitude': latitude,
      'longitude': longitude,
      'zoomLevel': zoomLevel,
    };
  }
}

@Entity()
class GospelOfflineMapsPreference {
  @Id()
  int id = 0;
  String currentMap;

  GospelOfflineMapsPreference({
    required this.currentMap,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currentMap': currentMap,
    };
  }

  factory GospelOfflineMapsPreference.fromMap(Map<String, dynamic> map) {
    return GospelOfflineMapsPreference(
      id: map['id'] as int,
      currentMap: map['currentMap'] as String,
    );
  }
}