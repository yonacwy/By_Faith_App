import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../objectbox.dart';
import '../objectbox.g.dart';
import '../models/read_data_model.dart';
import 'study_page_ui.dart';

class StudyNotesPageUi extends StatefulWidget {
  const StudyNotesPageUi({Key? key}) : super(key: key);

  @override
  _StudyNotesPageUiState createState() => _StudyNotesPageUiState();
}

class _StudyNotesPageUiState extends State<StudyNotesPageUi> {
  late ObjectBox objectbox;
  late Box<BibleNote> bibleNotesBox;
  late Box<PersonalNote> personalNotesBox;
  late Box<StudyNote> studyNotesBox;
  late Box<UserPreference> userPreferenceBox;

  List<BibleNote> bibleNotes = [];
  List<PersonalNote> personalNotes = [];
  List<StudyNote> studyNotes = [];
  String _expandedCategory = 'Study Notes';

  @override
  void initState() {
    super.initState();
    _initNotesBoxes();
  }

  Future<void> _initNotesBoxes() async {
    objectbox = await ObjectBox.create();
    bibleNotesBox = objectbox.store.box<BibleNote>();
    personalNotesBox = objectbox.store.box<PersonalNote>();
    studyNotesBox = objectbox.store.box<StudyNote>();
    userPreferenceBox = objectbox.store.box<UserPreference>();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      bibleNotes = bibleNotesBox.getAll();
      personalNotes = personalNotesBox.getAll();
      studyNotes = studyNotesBox.getAll();
    });
  }

  void _deleteNote(int index, String category) {
    switch (category) {
      case 'Bible Notes':
        bibleNotesBox.remove(bibleNotes[index].id);
        break;
      case 'Personal Notes':
        personalNotesBox.remove(personalNotes[index].id);
        break;
      case 'Study Notes':
        studyNotesBox.remove(studyNotes[index].id);
        break;
    }
    UserPreference prefs = userPreferenceBox.get(1) ?? UserPreference();
    switch (category) {
      case 'Bible Notes':
        prefs.lastBibleNote = null;
        break;
      case 'Personal Notes':
        prefs.lastPersonalNote = null;
        break;
      case 'Study Notes':
        prefs.lastStudyNote = null;
        break;
    }
    userPreferenceBox.put(prefs);
    _loadNotes();
  }

  void _editNote(int index, quill.Document document, String category, {dynamic noteObject}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(
          initialDocument: document,
          onSave: (noteJson, selectedCategory) {
            if (noteJson.isNotEmpty) {
              if (category == 'Bible Notes' && noteObject is BibleNote) {
                noteObject.note = noteJson;
                bibleNotesBox.put(noteObject);
              } else if (category == 'Personal Notes' && noteObject is PersonalNote) {
                noteObject.note = noteJson;
                personalNotesBox.put(noteObject);
              } else if (category == 'Study Notes' && noteObject is StudyNote) {
                noteObject.note = noteJson;
                studyNotesBox.put(noteObject);
              }
              _loadNotes();
            } else {
              print('Attempted to save an empty note in $category');
            }
          },
          category: category,
          availableCategories: const ['Bible Notes', 'Personal Notes', 'Study Notes'],
        ),
      ),
    );
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
                    onSave: (noteJson, category) {
                      final newNote;
                      switch (category) {
                        case 'Bible Notes':
                          final decodedBibleNote = jsonDecode(noteJson);
                          newNote = BibleNote(
                            verse: decodedBibleNote['verse'],
                            verseText: decodedBibleNote['verseText'],
                            note: decodedBibleNote['note'],
                            timestamp: DateTime.now(),
                          );
                          bibleNotesBox.put(newNote);
                          break;
                        case 'Personal Notes':
                          newNote = PersonalNote(
                            note: noteJson,
                            timestamp: DateTime.now(),
                          );
                          personalNotesBox.put(newNote);
                          break;
                        case 'Study Notes':
                          newNote = StudyNote(
                            note: noteJson,
                            timestamp: DateTime.now(),
                          );
                          studyNotesBox.put(newNote);
                          break;
                        default:
                          return;
                      }

                      String lastNoteText = '';
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

                      UserPreference prefs = userPreferenceBox.get(1) ?? UserPreference();
                      switch (category) {
                        case 'Bible Notes':
                          prefs.lastBibleNote = lastNoteText;
                          break;
                        case 'Personal Notes':
                          prefs.lastPersonalNote = lastNoteText;
                          break;
                        case 'Study Notes':
                          prefs.lastStudyNote = lastNoteText;
                          break;
                      }
                      userPreferenceBox.put(prefs);
                      _loadNotes();
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

  Widget _buildExpansionTile<T>(BuildContext context, String category, List<T> notes, {bool isBibleNotes = false}) {
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
              final noteObject = entry.value;
              String noteJson;
              String verse = '';
              String verseText = '';

              if (isBibleNotes && noteObject is BibleNote) {
                noteJson = noteObject.note;
                verse = noteObject.verse;
                verseText = noteObject.verseText;
              } else if (noteObject is PersonalNote) {
                noteJson = noteObject.note;
              } else if (noteObject is StudyNote) {
                noteJson = noteObject.note;
              } else {
                return const SizedBox.shrink(); // Should not happen
              }

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
                      if (isBibleNotes)
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
                              onPressed: () => _editNote(index, document, category, noteObject: noteObject),
                              tooltip: 'Edit Note',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () => _deleteNote(index, category),
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
                              if (isBibleNotes) ...[
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
                        onPressed: () => _deleteNote(index, category),
                        tooltip: 'Delete Corrupted Note',
                      ),
                    ],
                  ),
                );
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