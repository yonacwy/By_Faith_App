import 'package:objectbox/objectbox.dart';

@Entity()
class Prayer {
  @Id()
  int id = 0;
  @Unique(onConflict: ConflictStrategy.replace)
  String prayerId;
  String richTextJson; // Store Quill Delta as JSON
  String status;
  @Property(type: PropertyType.date)
  DateTime timestamp;

  Prayer({
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
}