import 'package:objectbox/objectbox.dart';

@Entity()
class HomePageModel {
  @Id()
  int id = 0;
  String? lastBibleNote;
  String? lastPersonalNote;
  String? lastStudyNote;
  String? lastSearch;
  String? lastContact;
  int readChaptersCount;
  int bookmarkCount;
  int favoriteCount;
  int bibleNoteCount;
  int personalNoteCount;
  int studyNoteCount;
  int searchCount;
  String? homeSelectedFont;
  double? homeSelectedFontSize;
  bool onboardingComplete;
  int lastPageIndex;
  String lastReadChapter;


  String? lastSelectedStudyBook;
  String? lastSelectedStudyChapter;
  String? currentMap;
  int studiedChaptersCount;

  HomePageModel({
    this.lastBibleNote,
    this.lastPersonalNote,
    this.lastStudyNote,
    this.lastSearch,
    this.lastContact,
    required this.readChaptersCount,
    required this.bookmarkCount,
    required this.favoriteCount,
    required this.bibleNoteCount,
    required this.personalNoteCount,
    required this.studyNoteCount,
    required this.searchCount,
    this.homeSelectedFont,
    this.homeSelectedFontSize,
    required this.onboardingComplete,
    required this.lastPageIndex,
    required this.lastReadChapter,
    this.lastSelectedStudyBook,
    this.lastSelectedStudyChapter,
    this.currentMap,
    required this.studiedChaptersCount,
  });
}