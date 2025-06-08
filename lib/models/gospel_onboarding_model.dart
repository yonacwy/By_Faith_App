import 'package:objectbox/objectbox.dart';

import 'package:objectbox/objectbox.dart';

@Entity()
class GospelOnboardingModel {
  int id;
  bool onboardingComplete;

  GospelOnboardingModel({
    this.id = 0,
    required this.onboardingComplete,
  });
}