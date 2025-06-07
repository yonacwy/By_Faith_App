import 'package:objectbox/objectbox.dart';

@Entity()
class UserPreference {
  int id;
  String themeMode;
  double fontSize;
  String? lastSelectedBook;
  String lastReadChapter;
  String? lastSelectedChapter;
  int lastPageIndex;
  String currentMap;
  String? lastSelectedStudyBook;
  int? lastSelectedStudyChapter;
  String? selectedStudyFont;
  double? selectedStudyFontSize;
  String? lastBookmark;
  String? lastFavorite;
  String? lastBibleNote;
  String? lastPersonalNote;
  String? lastStudyNote;
  String? lastSearch;
  String? lastContact;
  int readChaptersCount;
  int bookmarkCount;
  int favoriteCount;
  int studiedChaptersCount;
  int bibleNoteCount;
  int personalNoteCount;
  int studyNoteCount;
  int searchCount;
  String? homeSelectedFont;
  double? homeSelectedFontSize;
  bool onboardingComplete;


  UserPreference({
    this.id = 0,
    this.themeMode = 'system',
    this.fontSize = 16.0,
    this.lastSelectedBook,
    this.lastReadChapter = 'Genesis 1',
    this.lastSelectedChapter,
    this.lastPageIndex = 0,
    this.currentMap = '',
    this.lastSelectedStudyBook,
    this.lastSelectedStudyChapter,
    this.selectedStudyFont,
    this.selectedStudyFontSize,
    this.lastBookmark,
    this.lastFavorite,
    this.lastBibleNote,
    this.lastPersonalNote,
    this.lastStudyNote,
    this.lastSearch,
    this.lastContact,
    this.readChaptersCount = 0,
    this.bookmarkCount = 0,
    this.favoriteCount = 0,
    this.studiedChaptersCount = 0,
    this.bibleNoteCount = 0,
    this.personalNoteCount = 0,
    this.studyNoteCount = 0,
    this.searchCount = 0,
    this.homeSelectedFont,
    this.homeSelectedFontSize,
    this.onboardingComplete = false,
  });
}