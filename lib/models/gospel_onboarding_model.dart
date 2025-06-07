import 'package:objectbox/objectbox.dart';

@Entity()
class GospelOnboardingModel {
  int id;
  bool onboardingComplete;
  String? homeSelectedFont;
  double? homeSelectedFontSize;
  String? lastSelectedBook;
  String? lastSelectedChapter;
  String? lastSelectedStudyBook;
  String? lastSelectedStudyChapter;
  String? lastBookmark;
  String? lastFavorite;
  String? lastBibleNote;
  String? lastPersonalNote;
  String? lastStudyNote;
  String? lastSearch;
  String? lastContact;
  String? currentMap;
  int? readChaptersCount;
  int? bookmarkCount;
  int? favoriteCount;
  int? studiedChaptersCount;
  int? bibleNoteCount;
  int? personalNoteCount;
  int? studyNoteCount;
  int? searchCount;

  GospelOnboardingModel({
    this.id = 0,
    required this.onboardingComplete,
    this.homeSelectedFont,
    this.homeSelectedFontSize,
    this.lastSelectedBook,
    this.lastSelectedChapter,
    this.lastSelectedStudyBook,
    this.lastSelectedStudyChapter,
    this.lastBookmark,
    this.lastFavorite,
    this.lastBibleNote,
    this.lastPersonalNote,
    this.lastStudyNote,
    this.lastSearch,
    this.lastContact,
    this.currentMap,
    this.readChaptersCount,
    this.bookmarkCount,
    this.favoriteCount,
    this.studiedChaptersCount,
    this.bibleNoteCount,
    this.personalNoteCount,
    this.studyNoteCount,
    this.searchCount,
  });
}