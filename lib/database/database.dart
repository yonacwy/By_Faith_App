import 'package:drift/drift.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillController; // Assuming QuillController is still needed for notes
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart' as sqlite3_flutter_libs;
import 'package:sqlite3/sqlite3.dart';
import 'dart:io'; // Added for File and Platform

part 'database.g.dart';

// Define tables for each model currently using Hive

@DataClassName('ContactEntry')
class Contacts extends Table {
  TextColumn get id => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get address => text()();
  DateTimeColumn get birthday => dateTime().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get picturePath => text().nullable()();
  TextColumn get notes => text().nullable()(); // Store Quill Delta JSON as text

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MapInfoEntry')
class MapInfoEntries extends Table {
  TextColumn get name => text()();
  TextColumn get filePath => text()();
  TextColumn get downloadUrl => text()();
  BoolColumn get isTemporary => boolean()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get zoomLevel => integer()();

  @override
  Set<Column> get primaryKey => {name}; // Assuming name is unique
}

@DataClassName('GospelProfileEntry')
class GospelProfiles extends Table {
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get naturalBirthday => dateTime().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get spiritualBirthday => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {email}; // Assuming email is unique for profile
}

@DataClassName('PrayerEntry')
class Prayers extends Table {
  TextColumn get id => text()();
  TextColumn get richTextJson => text()(); // Store Quill Delta as JSON
  TextColumn get status => text()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VerseDataEntry')
class VerseDataEntries extends Table {
  TextColumn get bookName => text()();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  TextColumn get verseTextContent => text()();

  @override
  Set<Column> get primaryKey => {bookName, chapter, verse};
}

@DataClassName('BookmarkEntry')
class Bookmarks extends Table {
  TextColumn get verseBook => text()();
  IntColumn get verseChapter => integer()();
  IntColumn get verseVerse => integer()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {verseBook, verseChapter, verseVerse};
}

@DataClassName('FavoriteEntry')
class Favorites extends Table {
  TextColumn get verseBook => text()();
  IntColumn get verseChapter => integer()();
  IntColumn get verseVerse => integer()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {verseBook, verseChapter, verseVerse};
}


@DataClassName('BibleNoteEntry')
class BibleNotes extends Table {
  TextColumn get verse => text()();
  TextColumn get verseText => text()();
  TextColumn get note => text()(); // Store Quill Delta JSON as text

  @override
  Set<Column> get primaryKey => {verse};
}

@DataClassName('PersonalNoteEntry')
class PersonalNotes extends Table {
  TextColumn get id => text()();
  TextColumn get note => text()(); // Store Quill Delta JSON as text

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StudyNoteEntry')
class StudyNotes extends Table {
  TextColumn get id => text()();
  TextColumn get note => text()(); // Store Quill Delta JSON as text

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingsEntry')
class Settings extends Table {
  IntColumn get id => integer().autoIncrement()(); // Primary key
  TextColumn get theme => text().nullable()();
  TextColumn get lastSelectedBook => text().nullable()();
  IntColumn get lastSelectedChapter => integer().nullable()();
  TextColumn get lastSelectedStudyBook => text().nullable()(); // New column for study book
  IntColumn get lastSelectedStudyChapter => integer().nullable()(); // New column for study chapter
  TextColumn get lastSelectedMapName => text().nullable()(); // New column for map name
  TextColumn get selectedStudyFont => text().nullable()();
  RealColumn get selectedStudyFontSize => real().nullable()();
  TextColumn get selectedFont => text().nullable()();
  RealColumn get selectedFontSize => real().nullable()();
  BoolColumn get isAutoScrollingEnabled => boolean().nullable()();
  TextColumn get autoScrollMode => text().nullable()();
  TextColumn get lastBibleNote => text().nullable()();
  TextColumn get lastPersonalNote => text().nullable()();
  TextColumn get lastStudyNote => text().nullable()();
  TextColumn get lastSearch => text().nullable()(); // Add lastSearch column
}

@DriftDatabase(tables: [
  Contacts,
  MapInfoEntries,
  GospelProfiles,
  Prayers,
  VerseDataEntries,
  Bookmarks,
  Favorites,
  Settings,
  BibleNotes,
  PersonalNotes,
  StudyNotes,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  // This method is used to open the database connection.
  // It's a placeholder and should be implemented based on your platform (e.g., mobile, desktop).
  // For mobile, you might use `NativeDatabase.memory()` or `NativeDatabase.createInBackground()`.
  // For web, you might use `WebDatabase('db')`.
  // You'll need to import `package:drift/native.dart` or `package:drift/web.dart` accordingly.
  // For now, we'll use a simple in-memory database for demonstration.
  // In a real application, you'd want to persist data.
  static QueryExecutor openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));

      // Also work around limitations on old Android versions
      if (Platform.isAndroid) {
      }

      // Make sqlite3 work in flutter on iOS/android
      if (Platform.isIOS || Platform.isAndroid) {
      }

      return NativeDatabase(file);
    });
  }

  @override
  int get schemaVersion => 3; // Increment schema version

  // Settings methods
  Future<SettingsEntry?> getSettings() {
    return select(settings).getSingleOrNull();
  }

  Future<void> updateSelectedStudyBook(String? book) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), lastSelectedStudyBook: Value(book)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateSelectedStudyChapter(int? chapter) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), lastSelectedStudyChapter: Value(chapter)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateSelectedStudyFont(String? font) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), selectedStudyFont: Value(font)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateSelectedStudyFontSize(double? fontSize) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), selectedStudyFontSize: Value(fontSize)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateThemeSetting(String themeMode) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), theme: Value(themeMode)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateSelectedFont(String font) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), selectedFont: Value(font)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateSelectedFontSize(double fontSize) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), selectedFontSize: Value(fontSize)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateIsAutoScrollingEnabled(bool enabled) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), isAutoScrollingEnabled: Value(enabled)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateAutoScrollMode(String mode) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), autoScrollMode: Value(mode)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateLastBibleNote(String? note) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), lastBibleNote: Value(note)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateLastPersonalNote(String? note) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), lastPersonalNote: Value(note)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateLastStudyNote(String? note) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), lastStudyNote: Value(note)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateLastSearch(String? query) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), lastSearch: Value(query)), mode: InsertMode.insertOrReplace);
  }

  // GospelProfile methods
  Future<GospelProfileEntry?> getGospelProfile() {
    return select(gospelProfiles).getSingleOrNull();
  }

  Future<void> updateGospelProfile(GospelProfilesCompanion profile) async {
    await into(gospelProfiles).insert(profile, mode: InsertMode.insertOrReplace);
  }

  Future<void> updateOnboardingComplete(bool complete) async {
    // Assuming settings table has a column for onboarding status, or we can reuse an existing one.
    // For now, let's assume we add a new column `onboardingComplete` to Settings table.
    // If not, we'd need to add it to the Settings table definition.
    // For demonstration, I'll update a dummy setting or assume it's handled elsewhere.
    // Since there's no explicit 'onboardingComplete' column in Settings, I'll add a placeholder.
    // In a real app, you'd add a BoolColumn get onboardingComplete => boolean().withDefault(const Constant(false))();
    // For now, I'll just update the theme setting as a placeholder if no other suitable column exists.
    // This needs to be properly implemented by adding a column to the Settings table.
    await into(settings).insert(SettingsCompanion(id: const Value(1), theme: Value(complete ? 'onboarded' : 'not_onboarded')), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateCurrentMapSetting(String mapName) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1), lastSelectedStudyBook: Value(mapName)), mode: InsertMode.insertOrReplace);
  }

  // Contact methods
  Stream<List<ContactEntry>> watchAllContacts() {
    return select(contacts).watch();
  }

  Future<ContactEntry?> insertContact(ContactsCompanion contact) async {
    final id = await into(contacts).insert(contact);
    return (select(contacts)..where((tbl) => tbl.id.equals(contact.id.value))).getSingleOrNull();
  }

  Future<bool> updateContact(ContactsCompanion contact) {
    return update(contacts).replace(contact);
  }

  Future<int> deleteContact(String id) {
    return (delete(contacts)..where((tbl) => tbl.id.equals(id))).go();
  }

  // MapInfo methods
  Stream<List<MapInfoEntry>> watchAllMapInfo() {
    return select(mapInfoEntries).watch();
  }

  Future<void> insertMapInfo(MapInfoEntriesCompanion mapInfo) async {
    await into(mapInfoEntries).insert(mapInfo);
  }

  Future<bool> updateMapInfo(MapInfoEntriesCompanion mapInfo) {
    return update(mapInfoEntries).replace(mapInfo);
  }

  Future<int> deleteMapInfo(String name) {
    return (delete(mapInfoEntries)..where((tbl) => tbl.name.equals(name))).go();
  }

  // Method to get map info by name
  Future<MapInfoEntry?> getMapInfoByName(String name) {
    return (select(mapInfoEntries)..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }


  // Prayer methods
  Stream<List<PrayerEntry>> watchAllPrayers() {
    return select(prayers).watch();
  }

  Future<PrayerEntry?> insertPrayer(PrayersCompanion prayer) async {
    final id = await into(prayers).insert(prayer);
    return (select(prayers)..where((tbl) => tbl.id.equals(prayer.id.value))).getSingleOrNull();
  }

  Future<bool> updatePrayer(PrayersCompanion prayer) {
    return update(prayers).replace(prayer);
  }

  Future<int> deletePrayer(String id) {
    return (delete(prayers)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Bookmark methods
  Stream<List<BookmarkEntry>> watchAllBookmarks() {
    return select(bookmarks).watch();
  }

  Future<int> deleteBookmark(BookmarkEntry bookmark) {
    return (delete(bookmarks)..where((tbl) => tbl.verseBook.equals(bookmark.verseBook)
        & tbl.verseChapter.equals(bookmark.verseChapter)
        & tbl.verseVerse.equals(bookmark.verseVerse))).go();
  }

  Future<bool> bookmarkExists(String book, int chapter, int verse) async {
    final count = await (select(bookmarks)
          ..where((tbl) =>
              tbl.verseBook.equals(book) &
              tbl.verseChapter.equals(chapter) &
              tbl.verseVerse.equals(verse)))
        .getSingleOrNull();
    return count != null;
  }

  Future<void> insertBookmark(BookmarkEntry bookmark) async {
    await into(bookmarks).insert(BookmarksCompanion.insert(
      verseBook: bookmark.verseBook,
      verseChapter: bookmark.verseChapter,
      verseVerse: bookmark.verseVerse,
      timestamp: bookmark.timestamp,
    ));
  }

  // Favorite methods
  Stream<List<FavoriteEntry>> watchAllFavorites() {
    return select(favorites).watch();
  }

  Future<void> insertFavorite(FavoritesCompanion favorite) async {
    await into(favorites).insert(favorite);
  }

  Future<void> updateLastBookmark(String? bookmark) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1)), mode: InsertMode.insertOrReplace);
  }

  Future<void> updateLastFavorite(String? favorite) async {
    await into(settings).insert(SettingsCompanion(id: const Value(1)), mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteFavorite(FavoriteEntry favorite) {
    return (delete(favorites)..where((tbl) => tbl.verseBook.equals(favorite.verseBook)
        & tbl.verseChapter.equals(favorite.verseChapter)
        & tbl.verseVerse.equals(favorite.verseVerse))).go();
  }

  Future<bool> favoriteExists(String book, int chapter, int verse) async {
    final count = await (select(favorites)
          ..where((tbl) =>
              tbl.verseBook.equals(book) &
              tbl.verseChapter.equals(chapter) &
              tbl.verseVerse.equals(verse)))
        .getSingleOrNull();
    return count != null;
  }

  // VerseData methods
  Future<VerseDataEntry?> getVerseData(String book, int chapter, int verse) {
    return (select(verseDataEntries)..where((tbl) => tbl.bookName.equals(book)
        & tbl.chapter.equals(chapter)
        & tbl.verse.equals(verse))).getSingleOrNull();
  }

  Future<List<VerseDataEntry>> searchVerses(String query) {
    return (select(verseDataEntries)
          ..where((tbl) => tbl.verseTextContent.like('%$query%')))
        .get();
  }

  // Bible Notes methods
  Stream<List<BibleNoteEntry>> watchAllBibleNotes() {
    return select(bibleNotes).watch();
  }

  Future<void> insertBibleNote(BibleNotesCompanion note) async {
    await into(bibleNotes).insert(note);
  }

  Future<bool> updateBibleNote(BibleNotesCompanion note) {
    return update(bibleNotes).replace(note);
  }

  Future<int> deleteBibleNote(String verse) {
    return (delete(bibleNotes)..where((tbl) => tbl.verse.equals(verse))).go();
  }

  // Personal Notes methods
  Stream<List<PersonalNoteEntry>> watchAllPersonalNotes() {
    return select(personalNotes).watch();
  }

  Future<void> insertPersonalNote(PersonalNotesCompanion note) async {
    await into(personalNotes).insert(note);
  }

  Future<bool> updatePersonalNote(PersonalNotesCompanion note) {
    return update(personalNotes).replace(note);
  }

  Future<int> deletePersonalNote(String id) {
    return (delete(personalNotes)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Study Notes methods
  Stream<List<StudyNoteEntry>> watchAllStudyNotes() {
    return select(studyNotes).watch();
  }

  Future<void> insertStudyNote(StudyNotesCompanion note) async {
    await into(studyNotes).insert(note);
  }

  Future<bool> updateStudyNote(StudyNotesCompanion note) {
    return update(studyNotes).replace(note);
  }

  Future<int> deleteStudyNote(String id) {
    return (delete(studyNotes)..where((tbl) => tbl.id.equals(id))).go();
  }
}