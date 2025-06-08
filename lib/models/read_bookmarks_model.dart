import 'package:objectbox/objectbox.dart';

@Entity()
class ReadBookmarksModel {
  @Id()
  int id = 0;
  String book;
  int chapter;
  int verse;
  String text;
  String? lastBookmark;
  int bookmarkCount;

  ReadBookmarksModel({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    this.lastBookmark,
    required this.bookmarkCount,
  });
}