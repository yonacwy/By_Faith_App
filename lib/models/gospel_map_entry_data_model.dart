import 'package:latlong2/latlong.dart' as latlong2;

class Bounds {
  final latlong2.LatLng southwest;
  final latlong2.LatLng northeast;

  Bounds({required this.southwest, required this.northeast});

  factory Bounds.fromJson(Map<String, dynamic> json) {
    return Bounds(
      southwest: latlong2.LatLng(json['southwest']['latitude'], json['southwest']['longitude']),
      northeast: latlong2.LatLng(json['northeast']['latitude'], json['northeast']['longitude']),
    );
  }
}

class GospelMapEntryData {
  final String name;
  final String primaryUrl;
  final String fallbackUrl;
  final double latitude;
  final double longitude;
  final int zoomLevel;
  final Bounds bounds; // Added bounds field

  GospelMapEntryData({
    required this.name,
    required this.primaryUrl,
    required this.fallbackUrl,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
    required this.bounds,
  });

  factory GospelMapEntryData.fromJson(Map<String, dynamic> json, Map<String, dynamic> coordinateMap) {
    final coords = coordinateMap[json['name']] ?? {};
    return GospelMapEntryData(
      name: json['name'],
      primaryUrl: json['primaryUrl'],
      fallbackUrl: json['fallbackUrl'] ?? '',
      latitude: (coords['latitude'] ?? 0.0).toDouble(),
      longitude: (coords['longitude'] ?? 0.0).toDouble(),
      zoomLevel: (coords['zoomLevel'] ?? 2).toInt(),
      bounds: Bounds.fromJson(coords['bounds'] ?? {
        'southwest': {'latitude': -85.0, 'longitude': -180.0},
        'northeast': {'latitude': 85.0, 'longitude': 180.0},
      }),
    );
  }
}