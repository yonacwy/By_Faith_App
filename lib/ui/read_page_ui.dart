import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import 'read_settings_ui.dart';

class ReadPageUi extends StatefulWidget {
  ReadPageUi({Key? key}) : super(key: key);

  @override
  _ReadPageUiState createState() => _ReadPageUiState();
}

class _ReadPageUiState extends State<ReadPageUi> {
  String? selectedBook;
  int? selectedChapter;
  List<dynamic> books = [];
  List<dynamic> bibleData = [];
  String chapterText = "";
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
      selectedBook = userPrefsBox.get('lastSelectedBook') ?? "Genesis";
      selectedChapter = userPrefsBox.get('lastSelectedChapter') ?? 1;
      selectedFont = userPrefsBox.get('selectedFont') ?? 'Roboto';
      selectedFontSize = userPrefsBox.get('selectedFontSize') ?? 16.0;
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
    await userPrefsBox.put('selectedFont', selectedFont);
    await userPrefsBox.put('selectedFontSize', selectedFontSize);
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

  void _openSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadSettingsUi(
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dropdownFontSize = screenWidth < 360 ? 14 : 16;

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
        title: const Text('Bible Reader'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [ // Menu icon on the right
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer(); // Open end drawer
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer( // Drawer on the right
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile( // Settings option in drawer
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _openSettingsPage();
              },
            ),
          ],
        ),
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
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Text(
                          chapterText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: selectedFontSize,
                                fontFamily: selectedFont,
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
