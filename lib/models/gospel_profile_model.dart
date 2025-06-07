import 'package:objectbox/objectbox.dart';

@Entity()
class GospelProfile {
  @Id()
  int id = 0;
  String? firstName;
  String? lastName;
  String? address;
  @Property(type: PropertyType.date)
  DateTime? naturalBirthday;
  String? phone;
  String? email;
  @Property(type: PropertyType.date)
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'naturalBirthday': naturalBirthday?.toIso8601String(),
      'phone': phone,
      'email': email,
      'spiritualBirthday': spiritualBirthday?.toIso8601String(),
    };
  }
}