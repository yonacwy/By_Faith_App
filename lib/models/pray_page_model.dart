import 'package:objectbox/objectbox.dart';

@Entity()
class PrayPageModel {
  @Id()
  int id = 0;
  @Unique(onConflict: ConflictStrategy.replace)
  String prayerId;
  String richTextJson; // Store Quill Delta as JSON
  String status;
  @Property(type: PropertyType.date)
  DateTime timestamp;

  PrayPageModel({
    this.id = 0,
    String? prayerId,
    required this.richTextJson,
    required this.status,
    required this.timestamp,
  }) : prayerId = prayerId ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prayerId': prayerId,
      'richTextJson': richTextJson,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PrayPageModel.fromJson(Map<String, dynamic> json) {
    return PrayPageModel(
      id: json['id'] as int,
      prayerId: json['prayerId'] as String,
      richTextJson: json['richTextJson'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prayerId': prayerId,
      'richTextJson': richTextJson,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}