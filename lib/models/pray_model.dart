import 'package:hive/hive.dart';

part 'pray_model.g.dart';

@HiveType(typeId: 3)
class Prayer extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String richTextJson; // Store Quill Delta as JSON

  @HiveField(2)
  String status;

  @HiveField(3)
  DateTime timestamp;

  Prayer({
    required this.richTextJson,
    required this.status,
    required this.timestamp,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

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

  static Future<Box<Prayer>> openBox() async {
    return await Hive.openBox<Prayer>('prayers');
  }
}