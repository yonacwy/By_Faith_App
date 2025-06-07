import 'package:objectbox/objectbox.dart';

@Entity()
class UserPreference {
  int id;
  String themeMode;
  double fontSize;
  String lastReadChapter;
  int lastPageIndex;
  String currentMap;

  UserPreference({
    this.id = 0,
    this.themeMode = 'system',
    this.fontSize = 16.0,
    this.lastReadChapter = 'Genesis 1',
    this.lastPageIndex = 0,
    this.currentMap = '',
  });
}