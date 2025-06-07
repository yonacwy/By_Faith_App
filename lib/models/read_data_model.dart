class VerseData {
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

class Bookmark {
  VerseData verseData;
  DateTime timestamp;

  Bookmark({required this.verseData, required this.timestamp});
}

class Favorite {
  VerseData verseData;
  DateTime timestamp;

  Favorite({required this.verseData, required this.timestamp});
}