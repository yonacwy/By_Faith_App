import 'package:objectbox/objectbox.dart';

@Entity()
class VerseData {
  @Id()
  int id = 0;
  String book;
  int chapter;
  int verse;
  String text;

  VerseData({required this.book, required this.chapter, required this.verse, required this.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseData &&
          runtimeType == other.runtimeType &&
          book == other.book &&
          chapter == other.chapter &&
          verse == other.verse;

  @override
  int get hashCode => book.hashCode ^ chapter.hashCode ^ verse.hashCode;
}

@Entity()
class Bookmark {
  @Id()
  int id = 0;
  String book;
  int chapter;
  int verse;
  String text;
  @Property(type: PropertyType.date)
  DateTime timestamp;

  Bookmark({required this.book, required this.chapter, required this.verse, required this.text, required this.timestamp});
}

@Entity()
class Favorite {
  @Id()
  int id = 0;
  String book;
  int chapter;
  int verse;
  String text;
  @Property(type: PropertyType.date)
  DateTime timestamp;

  Favorite({required this.book, required this.chapter, required this.verse, required this.text, required this.timestamp});
}

@Entity()
class BibleNote {
  @Id()
  int id = 0;
  String verse;
  String verseText;
  String note; // JSON string from Quill
  @Property(type: PropertyType.date)
  DateTime timestamp;

  BibleNote({
    required this.verse,
    required this.verseText,
    required this.note,
    required this.timestamp,
  });
}

@Entity()
class PersonalNote {
  @Id()
  int id = 0;
  String note; // JSON string from Quill
  @Property(type: PropertyType.date)
  DateTime timestamp;

  PersonalNote({
    required this.note,
    required this.timestamp,
  });
}

@Entity()
class StudyNote {
  @Id()
  int id = 0;
  String note; // JSON string from Quill
  @Property(type: PropertyType.date)
  DateTime timestamp;

  StudyNote({
    required this.note,
    required this.timestamp,
  });
}

@Entity()
class UserPreference {
  @Id()
  int id = 0;
  String? lastSelectedBook;
  int? lastSelectedChapter;
  String? selectedFont;
  double? selectedFontSize;
  bool? isAutoScrollingEnabled;
  String? autoScrollMode;
  String? lastBookmark;
  String? lastFavorite;
  String? lastBibleNote;
  String? lastPersonalNote;
  String? lastStudyNote;
  String? lastSearch;


  UserPreference({
    this.id = 0,
    this.lastSelectedBook,
    this.lastSelectedChapter,
    this.selectedFont,
    this.selectedFontSize,
    this.isAutoScrollingEnabled,
    this.autoScrollMode,
    this.lastBookmark,
    this.lastFavorite,
    this.lastBibleNote,
    this.lastPersonalNote,
    this.lastStudyNote,
    this.lastSearch,
  });
}