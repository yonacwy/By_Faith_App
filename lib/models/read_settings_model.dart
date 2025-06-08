import 'package:objectbox/objectbox.dart';

@Entity()
class ReadSettingsModel {
  @Id()
  int id = 0;
  bool isAutoScrollingEnabled;
  String autoScrollMode;

  ReadSettingsModel({
    required this.isAutoScrollingEnabled,
    required this.autoScrollMode,
  });
}