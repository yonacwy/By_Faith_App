import 'package:objectbox/objectbox.dart';

@Entity()
class StudySearchModel {
  @Id()
  int id = 0;
  String? lastSearch;
  int searchCount;

  StudySearchModel({
    this.lastSearch,
    required this.searchCount,
  });
}