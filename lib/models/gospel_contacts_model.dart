import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillController;

@Entity()
class GospelContactsModel {
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
 
  GospelContactsModel({
    this.id = 0,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'birthday': birthday?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'picturePath': picturePath,
      'notes': notes,
    };
  }

  factory GospelContactsModel.fromMap(Map<String, dynamic> map) {
    return GospelContactsModel(
      id: map['id'] as int,
      contactId: map['contactId'] as int,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      address: map['address'] as String,
      birthday: map['birthday'] != null ? DateTime.parse(map['birthday'] as String) : null,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      picturePath: map['picturePath'] as String?,
      notes: map['notes'] as String?,
    );
  }
}

@Entity()
class GospelContactsPreference {
  @Id()
  int id = 0;
  String? lastContact;

  GospelContactsPreference({
    this.lastContact,
  });
}