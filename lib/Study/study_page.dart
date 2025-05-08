import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';

class StudyPage extends StatefulWidget {
  final String? initialBook;
  final int? initialChapter;

  const StudyPage({super.key, this.initialBook, this.initialChapter});

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
      selectedBook = widget.initialBook ??
          userPrefsBox.get('lastSelectedStudyBook') ??
          "Genesis";
      selectedChapter = widget.initialChapter ??
          userPrefsBox.get('lastSelectedStudyChapter') ??
          1;
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

  List<Map<String, dynamic>> _parseVerseText(String text, String? bookName) {
    final List<Map<String, dynamic>> parsed = [];
    final RegExp segmentPattern = RegExp(r'([^{}]+)((?:\{[^{}]+\})*)');
    final RegExp validStrongsPattern = RegExp(r'\{[HG]\d+\}');
    final RegExp punctuationPattern = RegExp(r'[.,;:]$');
    final RegExp onlyPunctuationPattern = RegExp(r'^[.,;:]+$');

    int lastIndex = 0;

    for (final match in segmentPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        String intermediateText = text.substring(lastIndex, match.start).trim();
        if (intermediateText.isNotEmpty) {
          final words = intermediateText.split(RegExp(r'\s+'));
          for (final word in words) {
            if (word.isNotEmpty) {
              parsed.add({'word': word, 'strongs': []});
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

      final wordsAndPunctuation = wordPart.split(RegExp(r'\s+'));
      for (int i = 0; i < wordsAndPunctuation.length; i++) {
        String currentSegment = wordsAndPunctuation[i];
        if (currentSegment.isEmpty) continue;

        String currentWord = currentSegment;
        String trailingPunctuation = '';

        final puncMatch = punctuationPattern.firstMatch(currentWord);
        if (puncMatch != null) {
          trailingPunctuation = puncMatch.group(0)!;
          currentWord = currentWord.substring(0, puncMatch.start);
        }

        if (currentWord.isNotEmpty) {
          parsed.add({
            'word': currentWord,
            'strongs': (i == wordsAndPunctuation.length - 1) ? strongs : [],
          });
        }

        if (trailingPunctuation.isNotEmpty) {
          parsed.add({'word': trailingPunctuation, 'strongs': []});
        }
      }
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      String remainingText = text.substring(lastIndex).trim();
      if (remainingText.isNotEmpty) {
        final remainingWords = remainingText.split(RegExp(r'\s+'));
        for (final word in remainingWords) {
          if (word.isNotEmpty) {
            if (onlyPunctuationPattern.hasMatch(word)) {
              parsed.add({'word': word, 'strongs': []});
            } else {
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

  void _openSearchPage() {
    showSearch(
      context: context,
      delegate: BibleSearchDelegate(
        bibleData: bibleData,
      ),
    );
  }

  void _openDictionaryPage(String strongsNumber, String? bookName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _StrongsDictionaryPage(
          strongsNumber: strongsNumber,
          bookName: bookName,
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
              icon: const Icon(Icons.search),
              onPressed: _openSearchPage,
              tooltip: 'Search',
              padding: const EdgeInsets.all(8),
            ),
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
            icon: const Icon(Icons.search),
            onPressed: _openSearchPage,
            tooltip: 'Search',
            padding: const EdgeInsets.all(8),
          ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      itemCount: verses.length,
                      itemBuilder: (context, index) {
                        final verse = verses[index];
                        final parsedWords =
                            _parseVerseText(verse['text'], selectedBook);
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                ...parsedWords.expand((wordData) {
                                  final word = wordData['word'];
                                  final List<String> strongs =
                                      List<String>.from(wordData['strongs']);
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
                                                  .onSurface,
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

                                  spans.add(TextSpan(text: " "));

                                  return spans;
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

class BibleSearchDelegate extends SearchDelegate {
  final List<dynamic> bibleData;

  BibleSearchDelegate({required this.bibleData});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _SearchResultsPage(
            bibleData: bibleData,
            searchQuery: query,
          ),
        ),
      );
    });
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
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
    const String sampleText =
        "In the beginning God created the heaven and the earth.";

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
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    title: const Text('Theme'),
                    trailing: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (value) {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .toggleTheme();
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
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Font Family',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
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
  final String? bookName;
  final Map<String, dynamic> hebrewDictionary;
  final Map<String, dynamic> greekDictionary;

  const _StrongsDictionaryPage({
    required this.strongsNumber,
    this.bookName,
    required this.hebrewDictionary,
    required this.greekDictionary,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? entry = _findEntry();
    final String title =
        entry != null ? "$strongsNumber: ${entry['lemma']}" : "$strongsNumber: Not Found";

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
                      if (strongsNumber.startsWith('H'))
                        _buildInfoCard(
                            context, 'Pronunciation', entry['pronunciation']),
                      if (strongsNumber.startsWith('G'))
                        _buildInfoCard(
                            context, 'Transliteration', entry['translit']),
                      _buildInfoCard(context, 'Definition', entry['definition']),
                      _buildInfoCard(context, 'Derivation', entry['derivation']),
                      if (strongsNumber.startsWith('H') ||
                          strongsNumber.startsWith('G'))
                        _buildInfoCard(
                            context, 'Strongs Definition', entry['strongs_def']),
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
    bool isNewTestament = _isNewTestamentBook(bookName);

    if (isNewTestament || strongsNumber.startsWith('G')) {
      return greekDictionary[strongsNumber];
    } else if (strongsNumber.startsWith('H')) {
      return hebrewDictionary[strongsNumber];
    }
    return null;
  }

  bool _isNewTestamentBook(String? book) {
    if (book == null) return false;
    final newTestamentBooks = [
      "Matthew",
      "Mark",
      "Luke",
      "John",
      "Acts",
      "Romans",
      "1 Corinthians",
      "2 Corinthians",
      "Galatians",
      "Ephesians",
      "Philippians",
      "Colossians",
      "1 Thessalonians",
      "2 Thessalonians",
      "1 Timothy",
      "2 Timothy",
      "Titus",
      "Philemon",
      "Hebrews",
      "James",
      "1 Peter",
      "2 Peter",
      "1 John",
      "2 John",
      "3 John",
      "Jude",
      "Revelation"
    ];
    return newTestamentBooks.contains(book);
  }

  Widget _buildInfoCard(BuildContext context, String title, String? content) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
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

class _SearchResultsPage extends StatefulWidget {
  final List<dynamic> bibleData;
  final String searchQuery;

  const _SearchResultsPage({
    required this.bibleData,
    required this.searchQuery,
  });

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<_SearchResultsPage> {
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  void _performSearch() {
    setState(() => isLoading = true);
    final query = widget.searchQuery.toLowerCase();

    // Collect all matching verses
    final List<Map<String, dynamic>> allResults = widget.bibleData
        .where((verse) => verse['text'].toString().toLowerCase().contains(query))
        .map<Map<String, dynamic>>((verse) => {
              'book': verse['book_name'],
              'chapter': verse['chapter'],
              'verse': verse['verse'],
              'text': verse['text'],
            })
        .toList();

    // Group results by book
    final Map<String, List<Map<String, dynamic>>> groupedResults = {};
    for (var result in allResults) {
      final book = result['book'] as String;
      if (!groupedResults.containsKey(book)) {
        groupedResults[book] = [];
      }
      groupedResults[book]!.add(result);
    }

    // Convert grouped results to a list for display
    searchResults = groupedResults.entries
        .map((entry) => {
              'book': entry.key,
              'verses': entry.value,
            })
        .toList();

    setState(() => isLoading = false);
  }

  String _removeStrongsNumbers(String text) {
    // Remove Strong's numbers in formats like {(H8804)}, {H123}, {G456}, etc.
    return text.replaceAll(RegExp(r'\{\(?[HG]\d+\)?\}'), '');
  }

  List<TextSpan> _buildHighlightedText(
      String text, String query, BuildContext context) {
    final List<TextSpan> spans = [];
    // Remove Strong's numbers before processing
    final cleanedText = _removeStrongsNumbers(text);
    final lowerText = cleanedText.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (start < cleanedText.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(
          text: cleanedText.substring(start),
          style: Theme.of(context).textTheme.bodyMedium,
        ));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: cleanedText.substring(start, index),
          style: Theme.of(context).textTheme.bodyMedium,
        ));
      }

      spans.add(TextSpan(
        text: cleanedText.substring(index, index + query.length),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ));

      start = index + query.length;
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results: "${widget.searchQuery}"'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : searchResults.isEmpty
                ? Center(
                    child: Text(
                      'No results found for "${widget.searchQuery}"',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      final book = result['book'] as String;
                      final verses = result['verses'] as List<Map<String, dynamic>>;

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            book,
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          children: verses.map((verse) {
                            final text = verse['text'].toString();
                            final query = widget.searchQuery.toLowerCase();
                            final spans =
                                _buildHighlightedText(text, query, context);

                            return ListTile(
                              title: Text(
                                '${verse['chapter']}:${verse['verse']}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  children: spans,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudyPage(
                                      initialBook: verse['book'],
                                      initialChapter: verse['chapter'],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}