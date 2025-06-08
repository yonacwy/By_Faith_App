import 'package:objectbox/objectbox.dart';

@Entity()
class PraySettingsModel {
  @Id()
  int id = 0;
  bool isAutoScrollingEnabled;
  String autoScrollMode;

  PraySettingsModel({
    required this.isAutoScrollingEnabled,
    required this.autoScrollMode,
  });
}