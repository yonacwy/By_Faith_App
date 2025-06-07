import 'package:flutter/material.dart';

import 'package:by_faith_app/models/gospel_profile_model.dart';
import 'package:by_faith_app/objectbox.dart';
import 'package:by_faith_app/ui/home_page_ui.dart'; // Assuming this is your main home page

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
    final store = objectbox.store;
    final profileBox = store.box<GospelProfile>();
    var profile = profileBox.get(1); // Assuming ID 1 for the single profile
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
      final store = objectbox.store;
      final profileBox = store.box<GospelProfile>();
      GospelProfile? profile = profileBox.get(1); // Try to get existing profile
      if (profile == null) {
        // Create new profile if it doesn't exist
        profile = GospelProfile(
          id: 1, // Assign ID 1 for the single profile
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          address: _addressController.text,
          naturalBirthday: _naturalBirthday,
          phone: _phoneController.text,
          email: _emailController.text,
          spiritualBirthday: _spiritualBirthday,
        );
      } else {
        // Update existing profile
        profile.firstName = _firstNameController.text;
        profile.lastName = _lastNameController.text;
        profile.address = _addressController.text;
        profile.naturalBirthday = _naturalBirthday;
        profile.phone = _phoneController.text;
        profile.email = _emailController.text;
        profile.spiritualBirthday = _spiritualBirthday;
      }
      profileBox.put(profile);

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
    final store = objectbox.store;
    final profileBox = store.box<GospelProfile>();
    profileBox.remove(1); // Remove the profile with ID 1
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
}