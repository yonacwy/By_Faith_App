import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:drift/drift.dart' hide Column;
import 'package:by_faith_app/database/database.dart';
import 'package:uuid/uuid.dart';
import 'study_page_ui.dart';
import 'package:by_faith_app/database/database_provider.dart'; // Import DatabaseProvider

class StudyNotesPageUi extends StatefulWidget {
  const StudyNotesPageUi({Key? key}) : super(key: key);

  @override
  _StudyNotesPageUiState createState() => _StudyNotesPageUiState();
}

class _StudyNotesPageUiState extends State<StudyNotesPageUi> {
  late final AppDatabase _database;
  List<BibleNoteEntry> bibleNotes = [];
  List<PersonalNoteEntry> personalNotes = [];
  List<StudyNoteEntry> studyNotes = [];
  String _expandedCategory = 'Study Notes';

  @override
  void initState() {
    super.initState();
    _database = DatabaseProvider.instance; // Use the singleton instance
    _loadNotes();
  }

  void _loadNotes() {
    _database.watchAllBibleNotes().listen((notes) {
      setState(() {
        bibleNotes = notes;
      });
    });
    _database.watchAllPersonalNotes().listen((notes) {
      setState(() {
        personalNotes = notes;
      });
    });
    _database.watchAllStudyNotes().listen((notes) {
      setState(() {
        studyNotes = notes;
      });
    });
  }

  Future<void> _deleteNote(dynamic noteEntry, String category) async {
    switch (category) {
      case 'Bible Notes':
        if (noteEntry is BibleNoteEntry) {
          await _database.deleteBibleNote(noteEntry.verse);
        }
        break;
      case 'Personal Notes':
        if (noteEntry is PersonalNoteEntry) {
          await _database.deletePersonalNote(noteEntry.id);
        }
        break;
      case 'Study Notes':
        if (noteEntry is StudyNoteEntry) {
          await _database.deleteStudyNote(noteEntry.id);
        }
        break;
    }
    await _updateLastNotePreference(category, null);
  }

  Future<void> _editNote(dynamic noteEntry, quill.Document document, String category, {Map<String, dynamic>? bibleNoteData}) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(
          initialDocument: document,
          onSave: (noteJson, selectedCategory) async {
            if (noteJson.isNotEmpty) {
              if (selectedCategory == 'Bible Notes' && noteEntry is BibleNoteEntry) {
                final updatedData = BibleNotesCompanion(
                  verse: Value(noteEntry.verse),
                  verseText: Value(noteEntry.verseText),
                  note: Value(noteJson),
                );
                await _database.updateBibleNote(updatedData);
              } else if (selectedCategory == 'Personal Notes' && noteEntry is PersonalNoteEntry) {
                final updatedData = PersonalNotesCompanion(
                  id: Value(noteEntry.id),
                  note: Value(noteJson),
                );
                await _database.updatePersonalNote(updatedData);
              } else if (selectedCategory == 'Study Notes' && noteEntry is StudyNoteEntry) {
                final updatedData = StudyNotesCompanion(
                  id: Value(noteEntry.id),
                  note: Value(noteJson),
                );
                await _database.updateStudyNote(updatedData);
              }
              await _updateLastNotePreference(selectedCategory, noteJson);
            } else {
              print('Attempted to save an empty note in $selectedCategory');
            }
          },
          category: category,
          availableCategories: const ['Bible Notes', 'Personal Notes', 'Study Notes'],
        ),
      ),
    );
  }

  Future<void> _updateLastNotePreference(String category, String? noteJson) async {
    String? lastNoteText;
    if (noteJson != null) {
      try {
        if (category == 'Bible Notes') {
          final decodedBibleNote = jsonDecode(noteJson);
          if (decodedBibleNote is Map<String, dynamic> &&
              decodedBibleNote.containsKey('note')) {
            final bibleNoteDeltaJson = decodedBibleNote['note'] as String;
            lastNoteText = quill.Document.fromJson(jsonDecode(bibleNoteDeltaJson))
                .toPlainText()
                .trim();
          }
        } else {
          lastNoteText = quill.Document.fromJson(jsonDecode(noteJson))
              .toPlainText()
              .trim();
        }
      } catch (e) {
        print('Error decoding note for dashboard: $e');
      }
    }

    switch (category) {
      case 'Bible Notes':
        await _database.updateLastBibleNote(lastNoteText);
        break;
      case 'Personal Notes':
        await _database.updateLastPersonalNote(lastNoteText);
        break;
      case 'Study Notes':
        await _database.updateLastStudyNote(lastNoteText);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Notes'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () async {
              final savedCategory = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNotePage(
                    onSave: (noteJson, category) async {
                      if (noteJson.isNotEmpty) {
                        final uuid = const Uuid().v4();
                        switch (category) {
                          case 'Bible Notes':
                            final decoded = jsonDecode(noteJson);
                            if (decoded is Map<String, dynamic> &&
                                decoded.containsKey('verse') &&
                                decoded.containsKey('verseText') &&
                                decoded.containsKey('note')) {
                              await _database.insertBibleNote(BibleNotesCompanion(
                                verse: Value(decoded['verse']),
                                verseText: Value(decoded['verseText']),
                                note: Value(decoded['note']),
                              ));
                            }
                            break;
                          case 'Personal Notes':
                            await _database.insertPersonalNote(PersonalNotesCompanion(
                              id: Value(uuid),
                              note: Value(noteJson),
                            ));
                            break;
                          case 'Study Notes':
                            await _database.insertStudyNote(StudyNotesCompanion(
                              id: Value(uuid),
                              note: Value(noteJson),
                            ));
                            break;
                        }
                        await _updateLastNotePreference(category, noteJson);
                      } else {
                        print('Attempted to save an empty note in $category');
                      }
                    },
                    category: 'Study Notes',
                    availableCategories: const ['Bible Notes', 'Personal Notes', 'Study Notes'],
                  ),
                ),
              );
              if (savedCategory != null && savedCategory is String) {
                setState(() {
                  _expandedCategory = savedCategory;
                });
              }
            },
            tooltip: 'Add Note',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _buildExpansionTile(context, 'Bible Notes', bibleNotes, isBibleNotes: true),
            _buildExpansionTile(context, 'Personal Notes', personalNotes),
            _buildExpansionTile(context, 'Study Notes', studyNotes),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, String category, List notes, {bool isBibleNotes = false}) {
    return ExpansionTile(
      title: Text(
        category,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
      ),
      initiallyExpanded: category == _expandedCategory,
      children: notes.isEmpty
          ? [
              ListTile(
                title: Text(
                  'No notes available.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ]
          : notes.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final noteEntry = entry.value;
              if (isBibleNotes) {
                final verse = noteEntry.verse as String;
                final verseText = noteEntry.verseText as String;
                final noteJson = noteEntry.note as String;

                try {
                  final document = quill.Document.fromJson(jsonDecode(noteJson));
                  final noteController = quill.QuillController(
                    document: document,
                    selection: const TextSelection.collapsed(offset: 0),
                  );
                  noteController.readOnly = true;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, verse);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  verse,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  verseText.replaceAll(RegExp(r'\{\(?[HG]\d+\)\}?'), ''),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: IgnorePointer(
                                  child: quill.QuillEditor(
                                    controller: noteController,
                                    scrollController: ScrollController(),
                                    focusNode: FocusNode(canRequestFocus: false),
                                    config: const quill.QuillEditorConfig(
                                      padding: EdgeInsets.all(8.0),
                                      enableInteractiveSelection: false,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () => _editNote(noteEntry, document, category, bibleNoteData: noteEntry.toJson()),
                                tooltip: 'Edit Note',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () => _deleteNote(noteEntry, category),
                                tooltip: 'Delete Note',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    color: Theme.of(context).colorScheme.error,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  verse,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  verseText,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Corrupted note',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deleteNote(noteEntry, category),
                          tooltip: 'Delete Corrupted Note',
                        ),
                      ],
                    ),
                  );
                }
              } else {
                final noteJson = noteEntry.note as String;
                try {
                  final document = quill.Document.fromJson(jsonDecode(noteJson));
                  final noteController = quill.QuillController(
                    document: document,
                    selection: const TextSelection.collapsed(offset: 0),
                  );
                  noteController.readOnly = true;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: IgnorePointer(
                              child: quill.QuillEditor(
                                controller: noteController,
                                scrollController: ScrollController(),
                                focusNode: FocusNode(canRequestFocus: false),
                                config: const quill.QuillEditorConfig(
                                  padding: EdgeInsets.all(8.0),
                                  enableInteractiveSelection: false,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () => _editNote(noteEntry, document, category),
                            tooltip: 'Edit Note',
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => _deleteNote(noteEntry, category),
                            tooltip: 'Delete Note',
                          ),
                        ],
                      ),
                    ),
                  );
                } catch (e) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    color: Theme.of(context).colorScheme.error,
                    child: ListTile(
                      title: const Text('Corrupted note'),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _deleteNote(noteEntry, category),
                        tooltip: 'Delete Corrupted Note',
                      ),
                    ),
                  );
                }
              }
            }).toList(),
    );
  }
}

class AddNotePage extends StatefulWidget {
  final quill.Document? initialDocument;
  final Function(String, String) onSave;
  final String category;
  final List<String> availableCategories;

  const AddNotePage({
    Key? key,
    this.initialDocument,
    required this.onSave,
    required this.category,
    required this.availableCategories,
  }) : super(key: key);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late quill.QuillController _quillController;
  late String _selectedCategory;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController(
      document: widget.initialDocument ?? quill.Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _selectedCategory = widget.category;
  }

  void _saveNote() {
    final delta = _quillController.document.toDelta();
    final plainText = _quillController.plainTextEditingValue.text;
    if (delta.isNotEmpty && plainText.trim().isNotEmpty) {
      final noteJson = jsonEncode(delta.toJson());
      widget.onSave(noteJson, _selectedCategory);
      Navigator.pop(context, _selectedCategory);
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Add Note'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: widget.availableCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: Theme.of(context).colorScheme.background,
                child: quill.QuillSimpleToolbar(
                  controller: _quillController,
                  config: const quill.QuillSimpleToolbarConfig(
                    multiRowsDisplay: false,
                    showAlignmentButtons: false,
                    showBackgroundColorButton: false,
                    showColorButton: false,
                    showListCheck: false,
                    showDividers: true,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(8.0),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                  color: Theme.of(context).colorScheme.background,
                ),
                child: quill.QuillEditor(
                  controller: _quillController,
                  scrollController: ScrollController(),
                  focusNode: FocusNode(),
                  config: const quill.QuillEditorConfig(
                    padding: EdgeInsets.all(8.0),
                    placeholder: 'Enter your note...',
                    autoFocus: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Submit note',
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}