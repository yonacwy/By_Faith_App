import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:hive_flutter/hive_flutter.dart';
import 'study_page_ui.dart';

class StudyNotesPageUi extends StatefulWidget {
  const StudyNotesPageUi({Key? key}) : super(key: key);

  @override
  _StudyNotesPageUiState createState() => _StudyNotesPageUiState();
}

class _StudyNotesPageUiState extends State<StudyNotesPageUi> {
  late Box bibleNotesBox;
  late Box personalNotesBox;
  late Box studyNotesBox;
  List<Map<String, dynamic>> bibleNotes = [];
  List<String> personalNotes = [];
  List<String> studyNotes = [];
  String _expandedCategory = 'Study Notes'; // State variable to hold the expanded category

  @override
  void initState() {
    super.initState();
    _initNotesBoxes();
  }

  Future<void> _initNotesBoxes() async {
    bibleNotesBox = await Hive.openBox('bibleNotes');
    personalNotesBox = await Hive.openBox('personalNotes');
    studyNotesBox = await Hive.openBox('studyNotes');
    // Also open user preferences box to update lastNote on deletion
    await Hive.openBox('userPreferences');
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      // Filter and decode bible notes, ensuring they are maps
      bibleNotes = bibleNotesBox.values
          .where((value) => value is String)
          .cast<String>()
          .map((value) {
            try {
              final decoded = jsonDecode(value);
              if (decoded is Map<String, dynamic>) {
                // Check if it has the expected keys for a Bible note
                if (decoded.containsKey('verse') && decoded.containsKey('verseText') && decoded.containsKey('note')) {
                  return decoded;
                }
              }
            } catch (e) {
              // Handle potential decoding errors
              print('Error decoding Bible note: $e');
            }
            // Return a default or null for invalid entries, which will be filtered out
            return null;
          })
          .where((note) => note != null) // Filter out null entries
          .cast<Map<String, dynamic>>() // Cast the remaining valid entries
          .toList();

      // Load personal and study notes (expected to be JSON-encoded lists from Quill delta)
      personalNotes = personalNotesBox.values.where((value) => value is String).cast<String>().toList();
      studyNotes = studyNotesBox.values.where((value) => value is String).cast<String>().toList();
    });
  }

  void _deleteNote(int index, String category) {
    switch (category) {
      case 'Bible Notes':
        bibleNotesBox.deleteAt(index);
        break;
      case 'Personal Notes':
        personalNotesBox.deleteAt(index);
        break;
      case 'Study Notes':
        studyNotesBox.deleteAt(index);
        break;
    }
    // Clear the lastNote preference on deletion
    Hive.box('userPreferences').delete('lastNote');
    _loadNotes();
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
                      switch (category) {
                        case 'Bible Notes':
                          bibleNotesBox.add(noteJson);
                          break;
                        case 'Personal Notes':
                          personalNotesBox.add(noteJson);
                          break;
                        case 'Study Notes':
                          studyNotesBox.add(noteJson);
                          break;
                      }
                      // Save the plain text of the note to user preferences for the dashboard
                      String lastNoteText = '';
                      if (category == 'Bible Notes') {
                        try {
                          final decodedBibleNote = jsonDecode(noteJson);
                          if (decodedBibleNote is Map<String, dynamic> && decodedBibleNote.containsKey('note')) {
                            final bibleNoteDeltaJson = decodedBibleNote['note'] as String;
                             lastNoteText = quill.Document.fromJson(jsonDecode(bibleNoteDeltaJson)).toPlainText().trim();
                          }
                        } catch (e) {
                           print('Error decoding Bible note for dashboard: $e');
                        }
                      } else {
                         lastNoteText = quill.Document.fromJson(jsonDecode(noteJson)).toPlainText().trim();
                      }
                      Hive.box('userPreferences').put('lastNote', lastNoteText);
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
      children: notes.isEmpty ? [
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
               final noteData = entry.value;
               if (isBibleNotes) {
                 final verse = noteData['verse'] as String;
                 final verseText = noteData['verseText'] as String;
                 final noteJson = noteData['note'] as String;

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
                         // Verse Section
                         InkWell(
                           onTap: () {
                             // Navigate back to StudyPageUi and pass the verse reference
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
                                   verseText.replaceAll(RegExp(r'\{[HG]\d+\}'), ''), // Remove Strong's numbers
                                   style: Theme.of(context).textTheme.bodySmall,
                                 ),
                               ],
                             ),
                           ),
                         ),
                         // Note Section
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Expanded(
                               child: InkWell(
                                 onTap: () {
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                       builder: (context) => AddNotePage(
                                         initialDocument: document,
                                         onSave: (noteJson, category) {
                                           final updatedData = {
                                             'verse': verse,
                                             'verseText': verseText,
                                             'note': noteJson,
                                           };
                                           bibleNotesBox.putAt(index, jsonEncode(updatedData));
                                           _loadNotes();
                                         },
                                         category: 'Bible Notes',
                                         availableCategories: const ['Bible Notes', 'Personal Notes', 'Study Notes'],
                                       ),
                                     ),
                                   );
                                 },
                                 child: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: quill.QuillEditor(
                                     controller: noteController,
                                     scrollController: ScrollController(),
                                     focusNode: FocusNode(),
                                     config: const quill.QuillEditorConfig(
                                       padding: EdgeInsets.all(8.0),
                                     ),
                                   ),
                                 ),
                               ),
                             ),
                             // Delete Button
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
                           onPressed: () => _deleteNote(index, category),
                           tooltip: 'Delete Corrupted Note',
                           ),
                         ],
                       ),
                     );
                   }
                 } else {
                   // Handle Personal Notes and Study Notes
                   final noteJson = noteData as String;
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
                       child: ListTile(
                         title: quill.QuillEditor(
                           controller: noteController,
                           scrollController: ScrollController(),
                           focusNode: FocusNode(),
                           config: const quill.QuillEditorConfig(
                             padding: EdgeInsets.all(8.0),
                           ),
                         ),
                         trailing: IconButton(
                           icon: Icon(
                             Icons.delete,
                             color: Theme.of(context).colorScheme.error,
                           ),
                           onPressed: () => _deleteNote(index, category),
                           tooltip: 'Delete Note',
                         ),
                         onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => AddNotePage(
                                 initialDocument: document,
                                 onSave: (noteJson, category) {
                                   switch (category) {
                                     case 'Personal Notes':
                                       personalNotesBox.putAt(index, noteJson);
                                       break;
                                     case 'Study Notes':
                                       studyNotesBox.putAt(index, noteJson);
                                       break;
                                   }
                                   _loadNotes();
                                 },
                                 category: category,
                                 availableCategories: const ['Bible Notes', 'Personal Notes', 'Study Notes'],
                               ),
                             ),
                           );
                         },
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
                           onPressed: () => _deleteNote(index, category),
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
      Navigator.pop(context, _selectedCategory); // Pass the selected category back
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
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
        child: Column(
          children: [
            // Category Selector
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
            // Rich Text Editor Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Theme.of(context).colorScheme.background,
              child: quill.QuillSimpleToolbar(
                controller: _quillController,
                config: const quill.QuillSimpleToolbarConfig(
                  multiRowsDisplay: false,
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showListBullets: true,
                  showListNumbers: true,
                  showClearFormat: true,
                  showFontFamily: false,
                  showFontSize: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showAlignmentButtons: false,
                  showHeaderStyle: false,
                  showLink: false,
                  showInlineCode: false,
                  showCodeBlock: false,
                  showQuote: false,
                  showIndent: false,
                  showListCheck: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showDividers: true,
                ),
              ),
            ),
            // Rich Text Editor Input
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(8.0),
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}