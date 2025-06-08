import 'package:objectbox/objectbox.dart';

@Entity()
class ReadFavoritesModel {
  @Id()
  int id = 0;
  String book;
  int chapter;
  int verse;
  String text;
  String? lastFavorite;
  int favoriteCount;

  ReadFavoritesModel({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    this.lastFavorite,
    required this.favoriteCount,
  });
}