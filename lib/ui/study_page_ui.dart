import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'study_search_ui.dart';
import 'study_settings_ui.dart';
import 'study_dictionary_ui.dart';
import 'study_notes_ui.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill; // Added for Quill notes

class StudyPageUi extends StatefulWidget {
  final String? initialBook;
  final int? initialChapter;

  StudyPageUi({Key? key, this.initialBook, this.initialChapter}) : super(key: key);

  @override
  _StudyPageUiState createState() => _StudyPageUiState();
}

class _StudyPageUiState extends State<StudyPageUi> {
  String? selectedBook;
  int? selectedChapter;
  List<dynamic> books = [];
  List<dynamic> bibleData = [];
  Map<String, dynamic> hebrewDictionary = {};
  Map<String, dynamic> greekDictionary = {};
  List<Map<String, dynamic>> verses = [];
  bool isLoading = true;
  late Box<dynamic> userPrefsBox;
  String selectedFont = 'Arial';
  double selectedFontSize = 16.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadSavedSelection();
  }

  Future<void> _loadSavedSelection() async {
    userPrefsBox = await Hive.openBox('userPreferences'); // Changed from 'userPrefs'
    setState(() {
      selectedBook = widget.initialBook ??
          userPrefsBox.get('lastSelectedStudyBook') ??
          "Genesis";
      selectedChapter = widget.initialChapter ??
          userPrefsBox.get('lastSelectedStudyChapter') ??
          1;
      selectedFont = userPrefsBox.get('selectedStudyFont') ?? 'Arial';
      selectedFontSize = userPrefsBox.get('selectedStudyFontSize') ?? 16.0;
    });
    await loadData();
  }

  Future<void> _saveSelection() async {
    if (selectedBook != null) {
      await userPrefsBox.put('lastSelectedStudyBook', selectedBook!);
      //print('[_saveSelection] lastSelectedStudyBook saved: $selectedBook'); // Debug print
    }
    if (selectedChapter != null) {
      await userPrefsBox.put('lastSelectedStudyChapter', selectedChapter);
      //print('[_saveSelection] lastSelectedStudyChapter saved: $selectedChapter'); // Debug print
    }
    await userPrefsBox.put('selectedStudyFont', selectedFont);
    await userPrefsBox.put('selectedStudyFontSize', selectedFontSize);
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      String bookChapterData = await DefaultAssetBundle.of(context)
          .loadString('lib/bible_data/book.chapters.json');
      books = jsonDecode(bookChapterData);

      String kjvData = await DefaultAssetBundle.of(context)
          .loadString('lib/bible_data/kjv-strongs-numbers.json');
      bibleData = jsonDecode(kjvData);

      String hebrewDictData = await DefaultAssetBundle.of(context)
          .loadString('lib/bible_data/strongs-hebrew-dictionary.json');
      hebrewDictionary = jsonDecode(hebrewDictData);

      String greekDictData = await DefaultAssetBundle.of(context)
          .loadString('lib/bible_data/strongs-greek-dictionary.json');
      greekDictionary = jsonDecode(greekDictData);

      if (books.isNotEmpty) {
        bool isValidBook = books.any((book) => book['book'] == selectedBook);
        if (!isValidBook) {
          selectedBook = "Genesis";
          selectedChapter = 1;
          await _saveSelection();
        } else {
          int maxChapters = books
              .firstWhere((book) => book['book'] == selectedBook)['chapters'];
          if (selectedChapter! > maxChapters) {
            selectedChapter = 1;
            await _saveSelection();
          }
        }
        await loadChapter();
      } else {
        setState(() {
          verses = [
            {'verse': 0, 'text': "No books available."}
          ];
        });
      }
    } catch (e) {
      setState(() {
        verses = [
          {'verse': 0, 'text': "Error loading data: $e"}
        ];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadChapter() async {
    if (selectedBook == null || selectedChapter == null) {
      setState(() {
        verses = [
          {'verse': 0, 'text': "Please select a book and chapter."}
        ];
      });
      return;
    }

    setState(() => isLoading = true);
    try {
      String bookName = selectedBook!;
      int chapterNumber = selectedChapter!;

      verses = bibleData
          .where((verse) =>
              verse['book_name'] == bookName && verse['chapter'] == chapterNumber)
          .map<Map<String, dynamic>>((verse) => ({
        'verse': verse['verse'],
        'text': verse['text'],
      })).toList();

      if (verses.isEmpty) {
        verses = [
          {'verse': 0, 'text': "No verses found for $bookName $chapterNumber."}
        ];
      }
    } catch (e) {
      setState(() {
        verses = [
          {'verse': 0, 'text': "Error loading chapter: $e"}
        ];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _parseVerseText(String text, String? bookName) {
    final List<Map<String, dynamic>> parsed = [];
    final RegExp segmentPattern = RegExp(r'([^{}]+)((?:\{[^{}]+\})*)');
    final RegExp validStrongsPattern = RegExp(r'\{[HG]\d+\}');
    final RegExp onlyPunctuationPattern = RegExp(r'^[.,;:!?]+$');

    int lastIndex = 0;

    for (final match in segmentPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        String intermediateText = text.substring(lastIndex, match.start).trim();
        if (intermediateText.isNotEmpty) {
          final words = intermediateText.split(RegExp(r'\s+'));
          for (final word in words) {
            if (word.isNotEmpty) {
              parsed.add({
                'word': word,
                'strongs': [],
                'isPunctuation': onlyPunctuationPattern.hasMatch(word),
              });
            }
          }
        }
      }

      String wordPart = match.group(1)!.trim();
      String curlyBlocks = match.group(2) ?? '';

      List<String> strongs = [];
      final firstValidStrongsMatch = validStrongsPattern.firstMatch(curlyBlocks);
      if (firstValidStrongsMatch != null) {
        strongs.add(
            firstValidStrongsMatch.group(0)!.replaceAll(RegExp(r'[\{\}]'), ''));
      }

      if (wordPart.isEmpty) {
        lastIndex = match.end;
        continue;
      }

      final wordsAndPunctuation = wordPart.split(RegExp(r'\s+'));
      for (int i = 0; i < wordsAndPunctuation.length; i++) {
        String currentSegment = wordsAndPunctuation[i];
        if (currentSegment.isEmpty) continue;

        parsed.add({
          'word': currentSegment,
          'strongs': (i == wordsAndPunctuation.length - 1) ? strongs : [],
          'isPunctuation': onlyPunctuationPattern.hasMatch(currentSegment),
        });
      }
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      String remainingText = text.substring(lastIndex).trim();
      if (remainingText.isNotEmpty) {
        final remainingWords = remainingText.split(RegExp(r'\s+'));
        for (final word in remainingWords) {
          if (word.isNotEmpty) {
            parsed.add({
              'word': word,
              'strongs': [],
              'isPunctuation': onlyPunctuationPattern.hasMatch(word),
            });
          }
        }
      }
    }

    return parsed;
  }

  void _openSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudySettingsPageUi(
          onFontChanged: (font, size) {
            setState(() {
              selectedFont = font;
              selectedFontSize = size;
              _saveSelection();
            });
          },
          initialFont: selectedFont,
          initialFontSize: selectedFontSize,
        ),
      ),
    ).then((_) => _scaffoldKey.currentState?.closeEndDrawer());
  }

  void _openSearchPage() {
    showSearch(
      context: context,
      delegate: BibleSearchDelegate(
        bibleData: bibleData,
      ),
    ).then((_) => _scaffoldKey.currentState?.closeEndDrawer());
  }

  void _openNotesPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudyNotesPageUi(),
      ),
    );
    _scaffoldKey.currentState?.closeEndDrawer();

    if (result != null && result is String) {
      // Parse the verse reference (e.g., "Genesis 1:1")
      final parts = result.split(' ');
      if (parts.length >= 2) {
        final book = parts.sublist(0, parts.length - 1).join(' ');
        final chapterVerse = parts.last.split(':');
        if (chapterVerse.length == 2) {
          final chapter = int.tryParse(chapterVerse[0]);
          if (chapter != null) {
            setState(() {
              selectedBook = book;
              selectedChapter = chapter;
            });
            await loadChapter();
            await _saveSelection();
          }
        }
      }
    }
  }

  void _openDictionaryPage(strongsNumber, String? bookName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StrongsDictionaryPageUi(
          strongsNumber: strongsNumber,
          bookName: bookName,
          hebrewDictionary: hebrewDictionary,
          greekDictionary: greekDictionary,
        ),
      ),
    );
  }

  void _addVerseToBibleNotes(int verseNumber, String verseText) async {
    final bibleNotesBox = await Hive.openBox('bibleNotes');
    // Remove Strong's numbers from verseText before saving
    final cleanedVerseText = verseText.replaceAll(RegExp(r'\{[HG]\d+\}'), '').trim();
    final noteJson = jsonEncode(quill.Document.fromDelta(
      quill.Document().toDelta(), // Empty note to start
    ).toDelta().toJson());
    final verseData = {
      'verse': '$selectedBook $selectedChapter:$verseNumber',
      'verseText': cleanedVerseText,
      'note': noteJson,
    };
    await bibleNotesBox.add(jsonEncode(verseData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verse added to Bible Notes')),
    );
    // Update lastBibleNote in userPreferences
    final userPrefsBox = await Hive.openBox('userPreferences');
    userPrefsBox.put('lastBibleNote', '$selectedBook $selectedChapter:$verseNumber');
    // Navigate to the StudyNotesPageUi after adding the note
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudyNotesPageUi(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dropdownFontSize = screenWidth < 360 ? 14 : 16;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Bible Study'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            tooltip: 'Menu',
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Notes'),
              onTap: _openNotesPage,
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              onTap: _openSearchPage,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: _openSettingsPage,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedBook,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.onBackground,
                        size: dropdownFontSize + 4,
                      ),
                      items: books.isEmpty
                          ? [
                               const DropdownMenuItem<String>(
                                 value: "Loading",
                                 child: Text("Loading..."),
                               )
                             ]
                          : books.map((book) => DropdownMenuItem<String>(
                                 value: book['book'],
                                 child: Text(
                                   book['book'],
                                   style: TextStyle(
                                     fontSize: dropdownFontSize,
                                     color:
                                         Theme.of(context).colorScheme.onBackground,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                               )).toList(),
                      onChanged: books.isEmpty
                          ? null
                          : (value) {
                               setState(() {
                                 selectedBook = value;
                                 selectedChapter = 1;
                                 loadChapter();
                                 _saveSelection();
                               });
                             },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<int>(
                      value: selectedChapter,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.onBackground,
                        size: dropdownFontSize + 4,
                      ),
                      items: (selectedBook != null && books.isNotEmpty)
                          ? List<int>.generate(
                              books.firstWhere(
                                  (book) => book['book'] == selectedBook,
                                  orElse: () => {'chapters': 1})['chapters'],
                              (index) => index + 1,
                            ).map((chapter) => DropdownMenuItem<int>(
                                value: chapter,
                                child: Text(
                                  '$chapter',
                                  style: TextStyle(
                                    fontSize: dropdownFontSize,
                                    color:
                                        Theme.of(context).colorScheme.onBackground,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )).toList()
                          : [
                              const DropdownMenuItem<int>(
                                value: 1,
                                child: Text("1"),
                              )
                            ],
                      onChanged: books.isEmpty
                          ? null
                          : (value) {
                               setState(() {
                                 selectedChapter = value;
                                 loadChapter();
                                 _saveSelection();
                               });
                             },
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: SelectableText.rich(
                        TextSpan(
                          children: verses.expand((verse) {
                            final parsedWords =
                                _parseVerseText(verse['text'], selectedBook);
                            return <InlineSpan>[
                              TextSpan(
                                text: "${verse['verse']}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: selectedFontSize,
                                      fontFamily: selectedFont,
                                      height: 1.5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary, // Highlight verse number
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _addVerseToBibleNotes(
                                        verse['verse'], verse['text']);
                                  },
                              ),
                              const TextSpan(text: " "), // Add a space without underline
                              ...parsedWords.asMap().entries.expand((entry) {
                                final index = entry.key;
                                final wordData = entry.value;
                                final word = wordData['word'];
                                final List<String> strongs =
                                    List<String>.from(wordData['strongs']);
                                final bool isPunctuation =
                                    wordData['isPunctuation'] ?? false;
                                final List<TextSpan> spans = [];

                                spans.add(TextSpan(
                                  text: word,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: selectedFontSize,
                                        fontFamily: selectedFont,
                                        height: 1.5,
                                        color: strongs.isNotEmpty
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                        decoration: strongs.isNotEmpty
                                            ? TextDecoration.underline
                                            : null,
                                      ),
                                  recognizer: strongs.isNotEmpty
                                      ? (TapGestureRecognizer()
                                        ..onTap = () => _openDictionaryPage(
                                            strongs.first, selectedBook))
                                      : null,
                                ));

                                // Add a space if it's not the last word
                                // and the next word is not punctuation.
                                if (index < parsedWords.length - 1) {
                                  final nextWordData = parsedWords[index + 1];
                                  final bool nextIsPunctuation = nextWordData['isPunctuation'] ?? false;
                                  if (!nextIsPunctuation) {
                                    spans.add(const TextSpan(text: " "));
                                  }
                                }

                                return spans;
                              }),
                              const TextSpan(text: "\n\n"),
                            ];
                          }).toList(),
                        ),
                        textAlign: TextAlign.justify,
                        contextMenuBuilder: (context, editableTextState) {
                          final List<ContextMenuButtonItem> buttonItems =
                              editableTextState.contextMenuButtonItems
                                  .where((item) =>
                                      item.type != ContextMenuButtonType.copy)
                                  .toList();
                          return AdaptiveTextSelectionToolbar.buttonItems(
                            anchors: editableTextState.contextMenuAnchors,
                            buttonItems: [
                              ContextMenuButtonItem(
                                onPressed: () {
                                  final selection = editableTextState
                                      .textEditingValue.selection;
                                  if (!selection.isValid) return;
                                  final text = editableTextState
                                      .textEditingValue.text
                                      .substring(
                                          selection.start, selection.end);
                                  Clipboard.setData(ClipboardData(text: text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Text copied to clipboard')),
                                  );
                                },
                                label: 'Copy',
                              ),
                              ContextMenuButtonItem(
                                onPressed: () {
                                  final text =
                                      editableTextState.textEditingValue.text;
                                  editableTextState.userUpdateTextEditingValue(
                                    editableTextState.textEditingValue.copyWith(
                                      selection: TextSelection(
                                          baseOffset: 0,
                                          extentOffset: text.length),
                                    ),
                                    null,
                                  );
                                },
                                label: 'Select All',
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}