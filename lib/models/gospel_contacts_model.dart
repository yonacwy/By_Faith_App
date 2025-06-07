import 'package:flutter_quill/flutter_quill.dart' show QuillController; // Assuming QuillController is still needed for notes

class Contact {
  final String id;
  final String firstName;
  final String lastName;
  final String address;
  final DateTime? birthday;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? email;
  final String? picturePath;
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