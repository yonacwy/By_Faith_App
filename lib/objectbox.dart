import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:by_faith_app/models/gospel_contacts_model.dart';
import 'package:by_faith_app/models/gospel_map_info_model.dart';
import 'package:by_faith_app/models/gospel_profile_model.dart';
import 'package:by_faith_app/models/pray_model.dart';
import 'package:by_faith_app/models/read_data_model.dart';
import 'package:by_faith_app/models/gospel_onboarding_model.dart';

import 'package:by_faith_app/models/user_preference_model.dart';
import 'package:by_faith_app/objectbox.g.dart'; // For openStore() and Box
import 'package:by_faith_app/models/bible_note_model.dart';
import 'package:by_faith_app/models/personal_note_model.dart';
import 'package:by_faith_app/models/study_note_model.dart';

late ObjectBox objectbox;

class ObjectBox {
  /// Create an instance of ObjectBox to use throughout the app.
  ObjectBox._create(Store store) {
    this.store = store;
    contactBox = Box<Contact>(store);
    mapInfoBox = Box<MapInfo>(store);
    gospelProfileBox = Box<GospelProfile>(store);
    prayerBox = Box<Prayer>(store);
    verseDataBox = Box<VerseData>(store);
    bookmarkBox = Box<Bookmark>(store);
    favoriteBox = Box<Favorite>(store);
    gospelOnboardingBox = Box<GospelOnboardingModel>(store);
    bibleNoteBox = Box<BibleNote>(store);
    personalNoteBox = Box<PersonalNote>(store);
    studyNoteBox = Box<StudyNote>(store);
    userPreferenceBox = Box<UserPreference>(store);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: docsDir.path);
    return ObjectBox._create(store);
  }

  late final Store store;
  late final Box<Contact> contactBox;
  late final Box<MapInfo> mapInfoBox;
  late final Box<GospelProfile> gospelProfileBox;
  late final Box<Prayer> prayerBox;
  late final Box<VerseData> verseDataBox;
  late final Box<Bookmark> bookmarkBox;
  late final Box<Favorite> favoriteBox;
  late final Box<GospelOnboardingModel> gospelOnboardingBox;
  late final Box<BibleNote> bibleNoteBox;
  late final Box<PersonalNote> personalNoteBox;
  late final Box<StudyNote> studyNoteBox;
  late final Box<UserPreference> userPreferenceBox;
}