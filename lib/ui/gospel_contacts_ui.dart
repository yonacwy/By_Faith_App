import 'dart:io';
import 'package:flutter/material.dart';
import 'package:by_faith_app/models/gospel_contacts_model.dart';
import 'package:by_faith_app/objectbox.dart';
import 'package:by_faith_app/objectbox.g.dart'; // Import objectbox.g.dart for Box types
import 'package:file_picker/file_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';

class GospelContactsModelsPage extends StatelessWidget {
  final ObjectBox objectbox;

  const GospelContactsModelsPage({Key? key, required this.objectbox}) : super(key: key);

  void _navigateToAddGospelContactsModel(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditGospelContactsModelPage(
          objectbox: objectbox,
          onGospelContactsModelAdded: (contact) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('GospelContactsModel ${contact.name} added')),
            );
          },
        ),
      ),
    );
  }

  
    void _navigateToEditGospelContactsModel(BuildContext context, GospelContactsModel contact) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditGospelContactsModelPage(
            objectbox: objectbox,
            contact: contact,
            onGospelContactsModelUpdated: (updatedGospelContactsModel) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('GospelContactsModel ${updatedGospelContactsModel.name} updated')),
              );
            },
            onDeleteGospelContactsModel: _deleteGospelContactsModel,
          ),
        ),
      );
    }
  
  void _deleteGospelContactsModel(BuildContext context, GospelContactsModel contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete GospelContactsModel'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              objectbox.gospelContactsModelBox.remove(contact.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('GospelContactsModel ${contact.name} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GospelContactsModels'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddGospelContactsModel(context),
            tooltip: 'Add GospelContactsModel',
          ),
        ],
      ),
      body: StreamBuilder<List<GospelContactsModel>>(
        stream: objectbox.gospelContactsModelBox.query().watch(triggerImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final contacts = snapshot.data!;
          if (contacts.isEmpty) {
            return const Center(child: Text('No contacts added yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: InkWell(
                  onTap: () => _navigateToEditGospelContactsModel(context, contact),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        contact.picturePath != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(File(contact.picturePath!)),
                                radius: 25,
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.person),
                                radius: 25,
                              ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            contact.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddEditGospelContactsModelPage extends StatefulWidget {
  final ObjectBox objectbox;
  final GospelContactsModel? contact;
  final Function(GospelContactsModel)? onGospelContactsModelAdded;
  final Function(BuildContext, GospelContactsModel)? onDeleteGospelContactsModel;
  final double? latitude;
  final double? longitude;

  const AddEditGospelContactsModelPage({
    Key? key,
    required this.objectbox,
    this.contact,
    this.onGospelContactsModelAdded,
    this.onDeleteGospelContactsModel,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  _AddEditGospelContactsModelPageState createState() => _AddEditGospelContactsModelPageState();
}

class _AddEditGospelContactsModelPageState extends State<AddEditGospelContactsModelPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final quill.QuillController _notesController = quill.QuillController.basic();
  String? _picturePath;
  bool _isEditing = false;
  bool _isReadOnly = false; // New state variable

  @override
  void initState() {
    super.initState();
    _isEditing = widget.contact != null;
    if (_isEditing) {
      _firstNameController.text = widget.contact!.firstName;
      _lastNameController.text = widget.contact!.lastName;
      _addressController.text = widget.contact!.address;
      _birthdayController.text = widget.contact!.birthday != null
          ? DateFormat.yMMMd().format(widget.contact!.birthday!)
          : '';
      _phoneController.text = widget.contact!.phone ?? '';
      _emailController.text = widget.contact!.email ?? '';
      _latitudeController.text = widget.contact!.latitude.toString();
      _longitudeController.text = widget.contact!.longitude.toString();
      _picturePath = widget.contact!.picturePath;
      if (widget.contact!.notes != null) {
        _notesController.document = quill.Document.fromJson(jsonDecode(widget.contact!.notes!));
      }
      _isReadOnly = true; // Initially read-only for existing contacts
    } else {
      _latitudeController.text = widget.latitude?.toString() ?? '';
      _longitudeController.text = widget.longitude?.toString() ?? '';
      _addressController.text = '';
      _isReadOnly = false; // Not read-only for new contacts
    }
    _notesController.readOnly = _isReadOnly; // Set initial read-only state for notes
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _picturePath = result.files.single.path;
      });
    }
  }

  Future<void> _pickBirthday() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthdayController.text = DateFormat.yMMMd().format(pickedDate);
      });
    }
  }

  Future<void> _saveGospelContactsModel() async {
    if (_formKey.currentState!.validate()) {
      try {
        final contact = GospelContactsModel(
          id: _isEditing ? widget.contact!.id : null,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          address: _addressController.text,
          birthday: _birthdayController.text.isNotEmpty
              ? DateFormat.yMMMd().parse(_birthdayController.text)
              : null,
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          picturePath: _picturePath,
          notes: _notesController.document.toDelta().toJson(),
        );

        contact.id = widget.contact?.id ?? 0;
        widget.objectbox.gospelContactsModelBox.put(contact);

        if (_isEditing) {
          widget.onGospelContactsModelUpdated?.call(contact);
        } else {
          widget.onGospelContactsModelAdded?.call(contact);
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'GospelContactsModel updated' : 'GospelContactsModel added')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving contact: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? (_isReadOnly ? 'GospelContactsModel Details' : 'Edit GospelContactsModel')
              : 'Add GospelContactsModel',
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: _isEditing
            ? (_isReadOnly
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        setState(() {
                          _isReadOnly = false;
                          _notesController.readOnly = false;
                        });
                      },
                      tooltip: 'Edit GospelContactsModel',
                    ),
                  ]
                : [
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.green),
                      onPressed: _saveGospelContactsModel,
                      tooltip: 'Save Changes',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        if (widget.contact != null) {
                          widget.onDeleteGospelContactsModel?.call(context, widget.contact!);
                        }
                      },
                      tooltip: 'Delete GospelContactsModel',
                    ),
                  ])
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Picture
                Row(
                  children: [
                    _picturePath != null
                        ? CircleAvatar(
                            backgroundImage: FileImage(File(_picturePath!)),
                            radius: 40,
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person, size: 40),
                            radius: 40,
                          ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isReadOnly ? null : _pickImage,
                      child: const Text('Pick Picture'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Personal Information
                const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _firstNameController,
                  readOnly: _isReadOnly,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  readOnly: _isReadOnly,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  readOnly: _isReadOnly,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _birthdayController,
                  readOnly: true, // Always read-only, uses date picker
                  onTap: _isReadOnly ? null : _pickBirthday,
                  decoration: const InputDecoration(
                    labelText: 'Birthday (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  readOnly: _isReadOnly,
                  decoration: const InputDecoration(
                    labelText: 'Phone (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  readOnly: _isReadOnly,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Map Information
                const Text('Map Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _latitudeController,
                  readOnly: _isReadOnly,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a latitude';
                    }
                    try {
                      double.parse(value);
                      return null;
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudeController,
                  readOnly: _isReadOnly,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a longitude';
                    }
                    try {
                      double.parse(value);
                      return null;
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Notes
                const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      quill.QuillSimpleToolbar(
                        controller: _notesController,
                        config: const quill.QuillSimpleToolbarConfig(
                          multiRowsDisplay: false,
                          showAlignmentButtons: false,
                          showBackgroundColorButton: false,
                          showColorButton: false,
                          showListCheck: false,
                          showDividers: true,
                        ),
                      ),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(8),
                        child: quill.QuillEditor(
                          controller: _notesController,
                          scrollController: ScrollController(),
                          focusNode: FocusNode(),
                          config: quill.QuillEditorConfig(
                            autoFocus: false,
                            expands: false,
                            padding: const EdgeInsets.all(0),
                            placeholder: 'Enter notes here...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Removed the bottom save button as it's now in the AppBar
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: !_isEditing
          ? FloatingActionButton.extended(
              onPressed: _saveGospelContactsModel,
              label: const Text('Save GospelContactsModel'),
              icon: const Icon(Icons.save),
            )
          : null,
    );
  }
}