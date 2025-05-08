import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  _StudyPageState createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  String? selectedBook;
  int? selectedChapter;
  List<dynamic> books = [];
  List<dynamic> bibleData = [];
  Map<String, dynamic> hebrewDictionary = {};
  Map<String, dynamic> greekDictionary = {};
  List<Map<String, dynamic>> verses = [];
  bool isLoading = true;
  late Box userPrefsBox;
  String selectedFont = 'Roboto';
  double selectedFontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadSavedSelection();
  }

  Future<void> _loadSavedSelection() async {
    userPrefsBox = await Hive.openBox('userPreferences');
    setState(() {
      selectedBook = userPrefsBox.get('lastSelectedStudyBook') ?? "Genesis";
      selectedChapter = userPrefsBox.get('lastSelectedStudyChapter') ?? 1;
      selectedFont = userPrefsBox.get('selectedStudyFont') ?? 'Roboto';
      selectedFontSize = userPrefsBox.get('selectedStudyFontSize') ?? 16.0;
    });
    loadData();
  }

  Future<void> _saveSelection() async {
    if (selectedBook != null) {
      await userPrefsBox.put('lastSelectedStudyBook', selectedBook!);
    }
    if (selectedChapter != null) {
      await userPrefsBox.put('lastSelectedStudyChapter', selectedChapter!);
    }
    await userPrefsBox.put('selectedStudyFont', selectedFont);
    await userPrefsBox.put('selectedStudyFontSize', selectedFontSize);
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      // Load book and chapter metadata
      String bookChapterData = await DefaultAssetBundle.of(context)
          .loadString('lib/bible_data/book.chapters.json');
      books = jsonDecode(bookChapterData);

      // Load Bible data
      String kjvData = await DefaultAssetBundle.of(context)
          .loadString('lib/bible_data/kjv-strongs-numbers.json');
      bibleData = jsonDecode(kjvData);

      // Load dictionaries
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
        setState(() {});
        await loadChapter();
      }
    } catch (e) {
      setState(() {
        verses = [
          {'verse': 0, 'text': "Error loading data: $e"}
        ];
        isLoading = false;
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

      // Filter verses for the selected book and chapter
      verses = bibleData
          .where((verse) =>
              verse['book_name'] == bookName && verse['chapter'] == chapterNumber)
          .map<Map<String, dynamic>>((verse) {
        return {
          'verse': verse['verse'],
          'text': verse['text'],
        };
      }).toList();

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

  // Parse verse text into words and Strong's numbers, ensuring strongs is non-null
  List<Map<String, dynamic>> _parseVerseText(String text) {
    final List<Map<String, dynamic>> parsed = [];
    // Regex to capture a word segment and all following curly blocks
    final RegExp segmentPattern = RegExp(r'([^{}]+)((?:\{[^{}]+\})*)');
    // Regex to find the first valid Strong's number {H...}
    final RegExp validStrongsPattern = RegExp(r'\{H\d+\}');
    // Regex to identify punctuation we want to separate
    final RegExp punctuationPattern = RegExp(r'[.,;:]$');
    // Regex to check if a string is purely punctuation
    final RegExp onlyPunctuationPattern = RegExp(r'^[.,;:]+$');


    int lastIndex = 0; // Keep track of the end of the last processed match

    for (final match in segmentPattern.allMatches(text)) {
       // Add any text between the last match and this one (likely spaces or uncaptured punctuation)
       if (match.start > lastIndex) {
         String intermediateText = text.substring(lastIndex, match.start).trim();
         if (intermediateText.isNotEmpty) {
           final words = intermediateText.split(RegExp(r'\s+'));
           for(final word in words) {
              if (word.isNotEmpty) {
                 parsed.add({'word': word, 'strongs': []});
              }
           }
         }
       }

      String wordPart = match.group(1)!.trim();
      String curlyBlocks = match.group(2) ?? '';

      List<String> strongs = [];
      // Find the first valid Strong's number in the curly blocks
      final firstValidStrongsMatch = validStrongsPattern.firstMatch(curlyBlocks);
      if (firstValidStrongsMatch != null) {
        strongs.add(firstValidStrongsMatch.group(0)!.replaceAll(RegExp(r'[\{\}]'), ''));
      }

      // Split the word part by space to handle multiple words before braces
      final wordsAndPunctuation = wordPart.split(RegExp(r'\s+'));
      for (int i = 0; i < wordsAndPunctuation.length; i++) {
        String currentSegment = wordsAndPunctuation[i];
        if (currentSegment.isEmpty) continue;

        String currentWord = currentSegment;
        String trailingPunctuation = '';

        // Separate trailing punctuation
        final puncMatch = punctuationPattern.firstMatch(currentWord);
         if (puncMatch != null) {
            trailingPunctuation = puncMatch.group(0)!;
            currentWord = currentWord.substring(0, puncMatch.start);
         }


        // Add the word part
        if (currentWord.isNotEmpty) {
          // Associate strongs only with the last word segment before the braces
          parsed.add({
            'word': currentWord,
            'strongs': (i == wordsAndPunctuation.length - 1) ? strongs : [],
          });
        }

        // Add the punctuation part if it exists
        if (trailingPunctuation.isNotEmpty) {
          parsed.add({'word': trailingPunctuation, 'strongs': []});
        }
      }
       lastIndex = match.end; // Update lastIndex to the end of the current segment match
    }

     // Add any remaining text after the last match
     if (lastIndex < text.length) {
       String remainingText = text.substring(lastIndex).trim();
       if (remainingText.isNotEmpty) {
          final remainingWords = remainingText.split(RegExp(r'\s+'));
          for (final word in remainingWords) {
             if (word.isNotEmpty) {
                // Check if the remaining part is just punctuation
                if (onlyPunctuationPattern.hasMatch(word)) {
                   parsed.add({'word': word, 'strongs': []});
                } else {
                   // Treat as a regular word if not just punctuation
                   parsed.add({'word': word, 'strongs': []});
                }
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
        builder: (context) => _StudySettingsPage(
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
    );
  }

  void _openDictionaryPage(String strongsNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _StrongsDictionaryPage(
          strongsNumber: strongsNumber,
          hebrewDictionary: hebrewDictionary,
          greekDictionary: greekDictionary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dropdownFontSize = screenWidth < 360 ? 14 : 16;

    if (isLoading && books.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Bible Study'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _openSettingsPage,
              tooltip: 'Settings',
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Bible Study'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettingsPage,
            tooltip: 'Settings',
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedBook,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: dropdownFontSize + 4,
                      ),
                      items: books.map((book) {
                        return DropdownMenuItem<String>(
                          value: book['book'],
                          child: Text(
                            book['book'],
                            style: TextStyle(
                              fontSize: dropdownFontSize,
                              color: Theme.of(context).colorScheme.onSurface,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
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
                        color: Theme.of(context).colorScheme.onSurface,
                        size: dropdownFontSize + 4,
                      ),
                      items: (selectedBook != null && books.isNotEmpty)
                          ? List<int>.generate(
                              books.firstWhere(
                                  (book) => book['book'] == selectedBook,
                                  orElse: () => {'chapters': 0})['chapters'],
                              (index) => index + 1,
                            ).map((chapter) {
                              return DropdownMenuItem<int>(
                                value: chapter,
                                child: Text(
                                  '$chapter',
                                  style: TextStyle(
                                    fontSize: dropdownFontSize,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList()
                          : [],
                      onChanged: (value) {
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
              color: Theme.of(context).colorScheme.outlineVariant,
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
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: verses.length,
                      itemBuilder: (context, index) {
                        final verse = verses[index];
                        final parsedWords = _parseVerseText(verse['text']);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${verse['verse']} ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: selectedFontSize,
                                        fontFamily: selectedFont,
                                        height: 1.5,
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                ...parsedWords.map((wordData) {
                                  final word = wordData['word'];
                                  final List<String> strongs = List<String>.from(wordData['strongs']);
                                  return TextSpan(
                                    text: "$word ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: selectedFontSize,
                                          fontFamily: selectedFont,
                                          height: 1.5,
                                          color: strongs.isNotEmpty
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSurface,
                                          decoration: strongs.isNotEmpty
                                              ? TextDecoration.underline
                                              : null,
                                        ),
                                    recognizer: strongs.isNotEmpty
                                        ? (TapGestureRecognizer()
                                          ..onTap = () => _openDictionaryPage(strongs.first))
                                        : null,
                                  );
                                }),
                              ],
                            ),
                            textAlign: TextAlign.justify,
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

class _StudySettingsPage extends StatefulWidget {
  final Function(String, double) onFontChanged;
  final String initialFont;
  final double initialFontSize;

  const _StudySettingsPage({
    required this.onFontChanged,
    required this.initialFont,
    required this.initialFontSize,
  });

  @override
  _StudySettingsPageState createState() => _StudySettingsPageState();
}

class _StudySettingsPageState extends State<_StudySettingsPage> {
  late String currentFont;
  late double currentFontSize;

  @override
  void initState() {
    super.initState();
    currentFont = widget.initialFont;
    currentFontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> fontOptions = [
      'Roboto',
      'Times New Roman',
      'Open Sans',
      'Lora',
    ];
    const String sampleText = "In the beginning God created the heaven and the earth.";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    title: const Text('Theme'),
                    trailing: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (value) {
                        Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                      },
                    ),
                    subtitle: Text(
                      Theme.of(context).brightness == Brightness.light
                          ? 'Light Mode'
                          : 'Dark Mode',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Text Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Font Family',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: currentFont,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: fontOptions.map((font) {
                            return DropdownMenuItem<String>(
                              value: font,
                              child: Text(
                                font,
                                style: TextStyle(
                                  fontFamily: font,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => currentFont = value);
                              widget.onFontChanged(currentFont, currentFontSize);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Font Size: ${currentFontSize.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Slider(
                          value: currentFontSize,
                          min: 10.0,
                          max: 30.0,
                          divisions: 20,
                          label: currentFontSize.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() => currentFontSize = value);
                            widget.onFontChanged(currentFont, currentFontSize);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Preview:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sampleText,
                            style: TextStyle(
                              fontFamily: currentFont,
                              fontSize: currentFontSize,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _StrongsDictionaryPage extends StatelessWidget {
  final String strongsNumber;
  final Map<String, dynamic> hebrewDictionary;
  final Map<String, dynamic> greekDictionary;

  const _StrongsDictionaryPage({
    required this.strongsNumber,
    required this.hebrewDictionary,
    required this.greekDictionary,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? entry = _findEntry();
    final String title = entry != null ? "$strongsNumber: ${entry['lemma']}" : "$strongsNumber: Not Found";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: entry != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(context, 'Lemma', entry['lemma']),
                      _buildInfoCard(context, 'Pronunciation', entry['pronunciation']),
                      _buildInfoCard(context, 'Definition', entry['definition']),
                      _buildInfoCard(context, 'Derivation', entry['derivation']),
                      _buildInfoCard(context, 'KJV Usage', entry['kjv_def']),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    'Entry for $strongsNumber not found.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
        ),
      ),
    );
  }

  Map<String, dynamic>? _findEntry() {
    if (strongsNumber.startsWith('H')) {
      return hebrewDictionary[strongsNumber];
    } else if (strongsNumber.startsWith('G')) {
      return greekDictionary[strongsNumber];
    }
    return null;
  }

  Widget _buildInfoCard(BuildContext context, String title, String? content) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink(); // Don't display card if content is empty
    }
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}