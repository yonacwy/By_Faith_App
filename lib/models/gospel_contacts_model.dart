import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillController;

@Entity()
class Contact {
  @Id()
  int id = 0;
  @Unique()
  int contactId;
  final String firstName;
  final String lastName;
  final String address;
  @Property(type: PropertyType.date)
  final DateTime? birthday;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? email;
  final String? picturePath;
  String? notes; // Store Quill Delta JSON
 
  Contact({
    this.contactId = 0, // Default to 0 for new contacts
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