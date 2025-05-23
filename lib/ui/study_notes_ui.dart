import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:hive_flutter/hive_flutter.dart';

class StudyNotesPageUi extends StatefulWidget {
  const StudyNotesPageUi({Key? key}) : super(key: key);

  @override
  _StudyNotesPageUiState createState() => _StudyNotesPageUiState();
}

class _StudyNotesPageUiState extends State<StudyNotesPageUi> {
  late Box notesBox;
  final quill.QuillController _quillController = quill.QuillController.basic();
  List<String> notes = []; // Stores JSON strings of Quill Delta

  @override
  void initState() {
    super.initState();
    _initNotesBox();
  }

  Future<void> _initNotesBox() async {
    notesBox = await Hive.openBox('studyNotes');
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      notes = notesBox.values.cast<String>().toList();
    });
  }

  void _addNote() {
    final delta = _quillController.document.toDelta();
    final plainText = _quillController.plainTextEditingValue.text;
    if (delta.isNotEmpty && plainText.trim().isNotEmpty) {
      final noteJson = jsonEncode(delta.toJson());
      notesBox.add(noteJson);
      _quillController.clear();
      _loadNotes();
    }
  }

  void _deleteNote(int index) {
    notesBox.deleteAt(index);
    _loadNotes();
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notes'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Rich Text Editor Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Theme.of(context).colorScheme.surfaceContainer,
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(4.0),
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              constraints: const BoxConstraints(
                minHeight: 100,
                maxHeight: 150,
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
            // Add Note Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _addNote,
                  tooltip: 'Add Note',
                ),
              ),
            ),
            // Notes List
            Expanded(
              child: notes.isEmpty
                  ? Center(
                      child: Text(
                        'No notes available.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final noteJson = notes[index];
                        final document = quill.Document.fromJson(jsonDecode(noteJson));
                        final noteController = quill.QuillController(
                          document: document,
                          selection: const TextSelection.collapsed(offset: 0),
                        );
                        noteController.readOnly = true;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          color: Theme.of(context).colorScheme.surfaceContainer,
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
                              onPressed: () => _deleteNote(index),
                              tooltip: 'Delete Note',
                            ),
                            onLongPress: () {
                              _quillController.document = document;
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}