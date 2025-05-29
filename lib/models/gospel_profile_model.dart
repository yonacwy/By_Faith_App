import 'package:hive/hive.dart';

part 'gospel_profile_model.g.dart';

@HiveType(typeId: 3)
class GospelProfile extends HiveObject {
  @HiveField(0)
  String? firstName;

  @HiveField(1)
  String? lastName;

  @HiveField(2)
  String? address;

  @HiveField(3)
  DateTime? naturalBirthday;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  String? email;

  @HiveField(6)
  DateTime? spiritualBirthday;

  GospelProfile({
    this.firstName,
    this.lastName,
    this.address,
    this.naturalBirthday,
    this.phone,
    this.email,
    this.spiritualBirthday,
  });
}