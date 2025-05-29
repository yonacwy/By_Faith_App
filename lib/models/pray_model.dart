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
}