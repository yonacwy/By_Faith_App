import 'package:hive/hive.dart';

part 'read_data_model.g.dart';

@HiveType(typeId: 6)
class VerseData extends HiveObject {
  @HiveField(0)
  String book;

  @HiveField(1)
  int chapter;

  @HiveField(2)
  int verse;

  @HiveField(3)
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

@HiveType(typeId: 1)
class Bookmark extends HiveObject {
  @HiveField(0)
  VerseData verseData;

  @HiveField(1)
  DateTime timestamp;

  Bookmark({required this.verseData, required this.timestamp});
}

@HiveType(typeId: 2)
class Favorite extends HiveObject {
  @HiveField(0)
  VerseData verseData;

  @HiveField(1)
  DateTime timestamp;

  Favorite({required this.verseData, required this.timestamp});
}