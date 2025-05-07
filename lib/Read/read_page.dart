import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReadPage extends StatefulWidget {
  const ReadPage({super.key});

  @override
  _ReadPageState createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  String? selectedBook;
  int? selectedChapter;
  List<dynamic> books = [];
  List<dynamic> bibleData = [];
  String chapterText = "";
  bool isLoading = true;
  late Box userPrefsBox;

  @override
  void initState() {
    super.initState();
    _loadSavedSelection();
  }

  Future<void> _loadSavedSelection() async {
    userPrefsBox = await Hive.openBox('userPreferences');
    setState(() {
      selectedBook = userPrefsBox.get('lastSelectedBook') ?? "Genesis";
      selectedChapter = userPrefsBox.get('lastSelectedChapter') ?? 1;
    });
    loadData();
  }

  Future<void> _saveSelection() async {
    if (selectedBook != null) {
      await userPrefsBox.put('lastSelectedBook', selectedBook!);
    }
    if (selectedChapter != null) {
      await userPrefsBox.put('lastSelectedChapter', selectedChapter!);
    }
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      String bookChapterData = await DefaultAssetBundle.of(context)
          .loadString('lib/bible_data/book.chapters.json');
      books = jsonDecode(bookChapterData);

      String kjvData = await DefaultAssetBundle.of(context)
          .loadString('lib/bible_data/kjv.json');
      bibleData = jsonDecode(kjvData);

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
        chapterText = "Error loading data: $e";
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadChapter() async {
    if (selectedBook == null || selectedChapter == null) {
      setState(() {
        chapterText = "Please select a book and chapter.";
      });
      return;
    }

    setState(() => isLoading = true);
    try {
      String bookName = selectedBook!;
      int chapterNumber = selectedChapter!;

      var book = bibleData.firstWhere(
        (b) => b['book'] == bookName,
        orElse: () => null,
      );

      if (book == null) {
        setState(() {
          chapterText = "Book not found.";
          isLoading = false;
        });
        return;
      }

      var chapter = book['chapters'][chapterNumber - 1];
      List<dynamic> verses = chapter['verses'];
      chapterText = verses
          .map((verse) =>
              "${verse['verse']} ${verse['text'].toString().trim()}")
          .join(' ');
    } catch (e) {
      setState(() {
        chapterText = "Error loading chapter: $e";
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth < 360 ? 14 : 16;

    if (isLoading && books.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Bible Reader'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Bible Reader'),
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
                        size: fontSize + 4,
                      ),
                      items: books.map((book) {
                        return DropdownMenuItem<String>(
                          value: book['book'],
                          child: Text(
                            book['book'],
                            style: TextStyle(
                              fontSize: fontSize,
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
                        size: fontSize + 4,
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
                                    fontSize: fontSize,
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

            // Chapter Content with increased padding
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Increased horizontal padding
                        child: Text(
                          chapterText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                height: 1.5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.justify,
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