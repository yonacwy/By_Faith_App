import 'package:objectbox/objectbox.dart';

@Entity()
class StudyPageModel {
  @Id()
  int id = 0;
  String? lastSelectedStudyBook;
  int? lastSelectedStudyChapter;
  String? selectedStudyFont;
  double? selectedStudyFontSize;
  int studiedChaptersCount;

  StudyPageModel({
    this.lastSelectedStudyBook,
    this.lastSelectedStudyChapter,
    this.selectedStudyFont,
    this.selectedStudyFontSize,
    required this.studiedChaptersCount,
  });
}