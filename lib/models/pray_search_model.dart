import 'package:objectbox/objectbox.dart';

@Entity()
class PraySearchModel {
  @Id()
  int id = 0;
  String? lastSearch;
  int searchCount;

  PraySearchModel({
    this.lastSearch,
    required this.searchCount,
  });
}