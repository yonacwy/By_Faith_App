import 'package:flutter/material.dart';
import 'package:by_faith_app/database/database.dart';
import 'package:by_faith_app/models/gospel_profile_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:drift/native.dart';

class GospelProfileUi extends StatefulWidget {
  final bool isNewProfile;
  const GospelProfileUi({super.key, this.isNewProfile = false});

  @override
  State<GospelProfileUi> createState() => _GospelProfileUiState();
}

class _GospelProfileUiState extends State<GospelProfileUi> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _naturalBirthday;
  DateTime? _spiritualBirthday;
  bool _isEditing = false; // New state variable to control editing mode

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Get the database instance. This should ideally be managed by a provider.
    // For this example, we'll create a new instance.
    final database = AppDatabase(NativeDatabase.createInBackground(await _getDatabaseFile()));

    // Assuming there's only one profile or you retrieve it by a known key/identifier
    // The GospelProfiles table in database.dart uses email as primary key, but the Hive code used a fixed key 'currentProfile'.
    // Let's assume for now we'll try to load the first profile found, or you might need a specific identifier.
    // If the email is the primary key, you'd need to know the email to retrieve a specific profile.
    // Given the Hive implementation used a single key, let's adapt to fetch a single profile if one exists.
    // A simple approach is to try and get the first entry, assuming there's only one profile entry.
    final profile = await database.select(database.gospelProfiles).getSingleOrNull();

    if (profile != null) {
      _firstNameController.text = profile.firstName ?? '';
      _lastNameController.text = profile.lastName ?? '';
      _addressController.text = profile.address ?? '';
      _phoneController.text = profile.phone ?? '';
      _emailController.text = profile.email ?? '';
      _naturalBirthday = profile.naturalBirthday;
      _spiritualBirthday = profile.spiritualBirthday;
    }
    setState(() {
      // If it's a new profile, start in editing mode
      if (widget.isNewProfile) {
        _isEditing = true;
      }
    }); // Refresh UI with loaded data
  }

  Future<void> _saveProfileChanges() async {
    if (_formKey.currentState!.validate()) {
      // Get the database instance. This should ideally be managed by a provider.
      // For this example, we'll create a new instance.
      final database = AppDatabase(NativeDatabase.createInBackground(await _getDatabaseFile()));

      final profileCompanion = GospelProfilesCompanion(
        firstName: Value(_firstNameController.text),
        lastName: Value(_lastNameController.text),
        address: Value(_addressController.text),
        naturalBirthday: Value(_naturalBirthday),
        phone: Value(_phoneController.text),
        email: Value(_emailController.text),
        spiritualBirthday: Value(_spiritualBirthday),
      );

      // Since email is the primary key, insert will replace if an entry with the same email exists.
      // This mimics the Hive put behavior for a single profile.
      await database.into(database.gospelProfiles).insert(profileCompanion, mode: InsertMode.insertOrReplace);

      if (widget.isNewProfile) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _isEditing = false; // Exit editing mode after saving
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
      }
    }
  }

  Future<void> _deleteProfile() async {
    // Get the database instance. This should ideally be managed by a provider.
    // For this example, we'll create a new instance.
    final database = AppDatabase(NativeDatabase.createInBackground(await _getDatabaseFile()));

    // Assuming there's only one profile or we delete the currently loaded one by email.
    // If we assume a single profile, deleting all entries is an option.
    // If we delete by email, we need the email from the loaded profile.
    // Let's delete all entries for simplicity, assuming only one profile is ever stored this way.
    await database.delete(database.gospelProfiles).go();

    // Clear text controllers and state
    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
    _naturalBirthday = null;
    _spiritualBirthday = null;
    setState(() {
      _isEditing = false; // Exit editing mode
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile deleted successfully!')),
    );
    // Optionally navigate away or show a message
    Navigator.of(context).pushReplacementNamed('/home'); // Or to onboarding if no profile exists
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [
          if (!widget.isNewProfile && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (!widget.isNewProfile && !_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                enabled: _isEditing || widget.isNewProfile, // Enable only in edit mode or for new profile
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                enabled: _isEditing || widget.isNewProfile,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                enabled: _isEditing || widget.isNewProfile,
              ),
              ListTile(
                title: Text('Natural Birthday: ${_naturalBirthday != null ? _naturalBirthday!.toLocal().toString().split(' ')[0] : 'Select Date'}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: (_isEditing || widget.isNewProfile) ? () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _naturalBirthday ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _naturalBirthday) {
                    setState(() {
                      _naturalBirthday = picked;
                    });
                  }
                } : null, // Disable onTap if not editing
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                enabled: _isEditing || widget.isNewProfile,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                enabled: _isEditing || widget.isNewProfile,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Spiritual Birthday: ${_spiritualBirthday != null ? _spiritualBirthday!.toLocal().toString().split(' ')[0] : 'Select Date'}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: (_isEditing || widget.isNewProfile) ? () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _spiritualBirthday ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _spiritualBirthday) {
                    setState(() {
                      _spiritualBirthday = picked;
                    });
                  }
                } : null, // Disable onTap if not editing
              ),
              const SizedBox(height: 20),
              Center(
                child: _isEditing || widget.isNewProfile
                    ? ElevatedButton(
                        onPressed: _saveProfileChanges,
                        child: const Text('Save'),
                      )
                    : Container(), // Hide save button if not editing and not new profile
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to get the database file path
  Future<File> _getDatabaseFile() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDocumentDir.path, 'db.sqlite');
    return File(dbPath);
  }
}