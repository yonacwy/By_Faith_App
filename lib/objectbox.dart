import 'package:objectbox/objectbox.dart';
import 'package:by_faith_app/objectbox.g.dart'; 
import 'package:path_provider/path_provider.dart';
import 'package:by_faith_app/models/gospel_contacts_model.dart';
import 'package:by_faith_app/models/gospel_map_selection_model.dart';
import 'package:by_faith_app/models/gospel_offline_maps_model.dart';
import 'package:by_faith_app/models/gospel_onboarding_model.dart';
import 'package:by_faith_app/models/gospel_page_model.dart';
import 'package:by_faith_app/models/gospel_profile_model.dart';
import 'package:by_faith_app/models/home_app_info_model.dart';
import 'package:by_faith_app/models/home_app_support_model.dart';
import 'package:by_faith_app/models/home_page_model.dart';
import 'package:by_faith_app/models/home_settings_model.dart';
import 'package:by_faith_app/models/pray_page_model.dart';
import 'package:by_faith_app/models/pray_search_model.dart';
import 'package:by_faith_app/models/pray_settings_model.dart';
import 'package:by_faith_app/models/pray_share_model.dart';
import 'package:by_faith_app/models/read_page_model.dart';
import 'package:by_faith_app/models/read_settings_model.dart';
import 'package:by_faith_app/models/study_dictionary_model.dart';
import 'package:by_faith_app/models/study_notes_model.dart';
import 'package:by_faith_app/models/study_page_model.dart';
import 'package:by_faith_app/models/study_search_model.dart';
import 'package:by_faith_app/models/study_settings_model.dart';

late ObjectBox objectbox;

class ObjectBox {
  /// Create an instance of ObjectBox to use throughout the app.
  ObjectBox._create(Store store) {
    this.store = store;
    gospelContactsModelBox = Box<Contact>(store);
    gospelMapSelectionModelBox = Box<GospelMapSelectionModel>(store);
    gospelOfflineMapsModelBox = Box<MapInfo>(store);
    gospelOnboardingModelBox = Box<GospelOnboardingModel>(store);
    gospelPageModelBox = Box<GospelPageModel>(store);
    gospelProfileModelBox = Box<GospelProfile>(store);
    homeAppInfoModelBox = Box<HomeAppInfoModel>(store);
    homeAppSupportModelBox = Box<HomeAppSupportModel>(store);
    homePageModelBox = Box<HomePageModel>(store);
    homeSettingsModelBox = Box<HomeSettingsModel>(store);
    prayPageModelBox = Box<Prayer>(store);
    praySearchModelBox = Box<PraySearchModel>(store);
    praySettingsModelBox = Box<PraySettingsModel>(store);
    prayShareModelBox = Box<PrayShareModel>(store);
    readBookmarksModelBox = Box<Bookmark>(store);
    readFavoritesModelBox = Box<Favorite>(store);
    readPageModelBox = Box<ReadPageModel>(store);
    readSettingsModelBox = Box<ReadSettingsModel>(store);
    studyDictionaryModelBox = Box<StudyDictionaryModel>(store);
    studyNotesModelBox = Box<StudyNotesModel>(store);
    studyPageModelBox = Box<StudyPageModel>(store);
    studySearchModelBox = Box<StudySearchModel>(store);
    studySettingsModelBox = Box<StudySettingsModel>(store);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: docsDir.path);
    return ObjectBox._create(store);
  }

  late final Store store;
  late final Box<Contact> gospelContactsModelBox;
  late final Box<GospelMapSelectionModel> gospelMapSelectionModelBox;
  late final Box<MapInfo> gospelOfflineMapsModelBox;
  late final Box<GospelOnboardingModel> gospelOnboardingModelBox;
  late final Box<GospelPageModel> gospelPageModelBox;
  late final Box<GospelProfile> gospelProfileModelBox;
  late final Box<HomeAppInfoModel> homeAppInfoModelBox;
  late final Box<HomeAppSupportModel> homeAppSupportModelBox;
  late final Box<HomePageModel> homePageModelBox;
  late final Box<HomeSettingsModel> homeSettingsModelBox;
  late final Box<Prayer> prayPageModelBox;
  late final Box<PraySearchModel> praySearchModelBox;
  late final Box<PraySettingsModel> praySettingsModelBox;
  late final Box<PrayShareModel> prayShareModelBox;
  late final Box<Bookmark> readBookmarksModelBox;
  late final Box<Favorite> readFavoritesModelBox;
  late final Box<ReadPageModel> readPageModelBox;
  late final Box<ReadSettingsModel> readSettingsModelBox;
  late final Box<StudyDictionaryModel> studyDictionaryModelBox;
  late final Box<StudyNotesModel> studyNotesModelBox;
  late final Box<StudyPageModel> studyPageModelBox;
  late final Box<StudySearchModel> studySearchModelBox;
  late final Box<StudySettingsModel> studySettingsModelBox;
}