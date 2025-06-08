import 'package:objectbox/objectbox.dart';

@Entity()
class HomeSettingsModel {
  @Id()
  int id = 0;
  String themeMode;

  HomeSettingsModel({
    this.themeMode = 'system',
  });
}