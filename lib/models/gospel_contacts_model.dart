import 'package:hive/hive.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillController;

part 'gospel_contacts_model.g.dart';

@HiveType(typeId: 1)
class Contact extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String firstName;
  @HiveField(2)
  final String lastName;
  @HiveField(3)
  final String address;
  @HiveField(4)
  final DateTime? birthday;
  @HiveField(5)
  final double latitude;
  @HiveField(6)
  final double longitude;
  @HiveField(7)
  final String? phone;
  @HiveField(8)
  final String? email;
  @HiveField(9)
  final String? picturePath;
  @HiveField(10)
  final List<dynamic>? notes; // Store Quill Delta JSON

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    this.birthday,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.email,
    this.picturePath,
    this.notes,
  });

  String get name => '$firstName $lastName';
}