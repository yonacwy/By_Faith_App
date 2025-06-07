import 'package:objectbox/objectbox.dart';

@Entity()
class MapInfo {
  @Id()
  int id = 0;
  final String name;
  final String filePath;
  final String downloadUrl;
  final bool isTemporary;
  double latitude;
  double longitude;
  int zoomLevel;

  MapInfo({
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