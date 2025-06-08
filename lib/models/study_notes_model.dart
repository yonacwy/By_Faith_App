import 'package:objectbox/objectbox.dart';
import 'package:by_faith_app/models/read_page_model.dart'; // Import for BibleNote, PersonalNote, StudyNote

@Entity()
class StudyNotesModel {
  @Id()
  int id = 0;
  String? lastBibleNote;
  String? lastPersonalNote;
  String? lastStudyNote;
  int bibleNoteCount;
  int personalNoteCount;
  int studyNoteCount;

  StudyNotesModel({
    this.lastBibleNote,
    this.lastPersonalNote,
    this.lastStudyNote,
    required this.bibleNoteCount,
    required this.personalNoteCount,
    required this.studyNoteCount,
  });
}