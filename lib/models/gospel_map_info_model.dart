class MapInfo {
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
}