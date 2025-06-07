import 'package:drift/drift.dart'; // Import the generated Drift database file
import '../database/database.dart'; // Import the generated Drift database file

class Prayer {
  String id;
  String richTextJson; // Store Quill Delta as JSON
  String status;
  DateTime timestamp;

  Prayer({
    required this.richTextJson,
    required this.status,
    required this.timestamp,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Factory constructor to create a Prayer from a PrayerEntry
  factory Prayer.fromPrayerEntry(PrayerEntry entry) {
    return Prayer(
      id: entry.id,
      richTextJson: entry.richTextJson,
      status: entry.status,
      timestamp: entry.timestamp,
    );
  }

  // Method to convert a Prayer to a PrayersCompanion for insertion/update
  PrayersCompanion toPrayersCompanion() {
    return PrayersCompanion(
      id: Value(id),
      richTextJson: Value(richTextJson),
      status: Value(status),
      timestamp: Value(timestamp),
    );
  }

  // Existing methods (fromJson, toJson) can be kept if still needed elsewhere
  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      id: json['id'],
      richTextJson: json['richTextJson'],
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'richTextJson': richTextJson,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}