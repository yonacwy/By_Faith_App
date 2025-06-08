import 'package:objectbox/objectbox.dart';

@Entity()
class StudySettingsModel {
  @Id()
  int id = 0;
  String? selectedStudyFont;
  double? selectedStudyFontSize;

  StudySettingsModel({
    this.selectedStudyFont,
    this.selectedStudyFontSize,
  });
}