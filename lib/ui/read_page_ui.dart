import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import 'read_settings_ui.dart';
import 'read_bookmarks_ui.dart';
import 'read_favorites_ui.dart';
import '../models/read_data_model.dart';

class ReadPageUi extends StatefulWidget {
  final String? initialBook;
  final int? initialChapter;
  final int? initialVerse;

  ReadPageUi({
    Key? key,
    this.initialBook,
    this.initialChapter,
    this.initialVerse,
  }) : super(key: key);

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
  bool _isAutoScrollingEnabled = false;
  bool _isFullScreen = false;
  String _autoScrollMode = 'Normal'; // New: 'Normal' or 'Continuous'

  late ScrollController _scrollController;
  bool _isAutoScrolling = false;
  double _autoScrollSpeed = 0.5;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadSavedSelection();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedSelection() async {
    userPrefsBox = await Hive.openBox('userPreferences');
    setState(() {
      selectedBook = widget.initialBook ?? userPrefsBox.get('lastSelectedBook') ?? "Genesis";
      selectedChapter = widget.initialChapter ?? userPrefsBox.get('lastSelectedChapter') ?? 1;
      selectedFont = userPrefsBox.get('selectedFont') ?? 'Roboto';
      selectedFontSize = userPrefsBox.get('selectedFontSize') ?? 16.0;
      _isAutoScrollingEnabled = userPrefsBox.get('isAutoScrollingEnabled') ?? false;
      _autoScrollMode = userPrefsBox.get('autoScrollMode') ?? 'Normal';
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
    await userPrefsBox.put('isAutoScrollingEnabled', _isAutoScrollingEnabled);
    await userPrefsBox.put('autoScrollMode', _autoScrollMode);
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
        await loadChapter(initialVerse: widget.initialVerse);
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

  Future<void> loadChapter({int? initialVerse}) async {
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

      chapterText = "";
      List<TextSpan> verseSpans = [];
      for (var verse in verses) {
        String verseNumber = "${verse['verse']}";
        String verseContent = "${verse['text'].toString().trim()}";

        verseSpans.add(
          TextSpan(
            children: [
              TextSpan(
                text: "$verseNumber ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: selectedFontSize,
                  fontFamily: selectedFont,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextSpan(
                text: "$verseContent ",
                style: TextStyle(
                  fontSize: selectedFontSize,
                  fontFamily: selectedFont,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _showVerseOptions(
                  VerseData(
                    book: selectedBook!,
                    chapter: chapterNumber,
                    verse: verse['verse'],
                    text: verseContent,
                  ),
                );
              },
          ),
        );
      }

      chapterText = verses
          .map((verse) => "${verse['verse']} ${verse['text'].toString().trim()}")
          .join(' ');
    } catch (e) {
      setState(() {
        chapterText = "Error loading chapter: $e";
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
      if (initialVerse != null) {
        // Scroll to initial verse if needed
      }
    }
  }

  Future<bool> _loadNextContent() async {
    if (selectedBook == null || selectedChapter == null) return false;

    var currentBook = books.firstWhere(
      (book) => book['book'] == selectedBook,
      orElse: () => null,
    );

    if (currentBook == null) return false;

    int maxChapters = currentBook['chapters'];
    if (selectedChapter! < maxChapters) {
      selectedChapter = selectedChapter! + 1;
      await _saveSelection();
      await loadChapter();
      return true;
    } else {
      int currentBookIndex = books.indexOf(currentBook);
      if (currentBookIndex < books.length - 1) {
        selectedBook = books[currentBookIndex + 1]['book'];
        selectedChapter = 1;
        await _saveSelection();
        await loadChapter();
        return true;
      } else {
        return false;
      }
    }
  }

  void _startAutoScroll() {
    if (_isAutoScrolling || !_isAutoScrollingEnabled) return;

    setState(() {
      _isAutoScrolling = true;
    });

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (!_scrollController.hasClients || !_isAutoScrolling) {
        _stopAutoScroll();
        return;
      }

      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScrollExtent - 10) {
        if (_autoScrollMode == 'Continuous') {
          bool hasMoreContent = await _loadNextContent();
          if (!hasMoreContent) {
            _stopAutoScroll();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reached the end of the Bible.')),
            );
            return;
          }
          await Future.delayed(const Duration(milliseconds: 100));
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        } else {
          _stopAutoScroll();
          return;
        }
      } else {
        _scrollController.animateTo(
          currentScroll + _autoScrollSpeed,
          duration: const Duration(milliseconds: 50),
          curve: Curves.linear,
        );
      }
    });
  }

  void _stopAutoScroll() {
    if (!_isAutoScrolling) return;

    _autoScrollTimer?.cancel();
    setState(() {
      _isAutoScrolling = false;
    });
  }

  void _increaseAutoScrollSpeed() {
    setState(() {
      _autoScrollSpeed = (_autoScrollSpeed + 0.1).clamp(0.1, 5.0);
    });
  }

  void _decreaseAutoScrollSpeed() {
    setState(() {
      _autoScrollSpeed = (_autoScrollSpeed - 0.1).clamp(0.1, 5.0);
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen && _isAutoScrollingEnabled) {
        _startAutoScroll();
      } else {
        _stopAutoScroll();
      }
    });
  }

  void _showVerseOptions(VerseData verseData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.bookmark_add),
                title: const Text('Add to Bookmarks'),
                onTap: () async {
                  Navigator.pop(context);
                  await _addVerseToBookmarks(verseData);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Add to Favorites'),
                onTap: () async {
                  Navigator.pop(context);
                  await _addVerseToFavorites(verseData);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addVerseToBookmarks(VerseData verseData) async {
    final bookmarksBox = await Hive.openBox<Bookmark>('bookmarks');
    final newBookmark = Bookmark(verseData: verseData, timestamp: DateTime.now());

    bool exists = bookmarksBox.values.any((bookmark) =>
        bookmark.verseData.book == verseData.book &&
        bookmark.verseData.chapter == verseData.chapter &&
        bookmark.verseData.verse == verseData.verse);

    if (!exists) {
      await bookmarksBox.add(newBookmark);
      final lastBookmarkValue = '${verseData.book} ${verseData.chapter}:${verseData.verse}';
      await userPrefsBox.put('lastBookmark', lastBookmarkValue);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verse added to Bookmarks!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verse is already in Bookmarks.')),
      );
    }
  }

  Future<void> _addVerseToFavorites(VerseData verseData) async {
    final favoritesBox = await Hive.openBox<Favorite>('favorites');
    final newFavorite = Favorite(verseData: verseData, timestamp: DateTime.now());

    bool exists = favoritesBox.values.any((favorite) =>
        favorite.verseData.book == verseData.book &&
        favorite.verseData.chapter == verseData.chapter &&
        favorite.verseData.verse == verseData.verse);

    if (!exists) {
      await favoritesBox.add(newFavorite);
      await userPrefsBox.put('lastFavorite', '${verseData.book} ${verseData.chapter}:${verseData.verse}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verse added to Favorites!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verse is already in Favorites.')),
      );
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
          onAutoScrollChanged: (isEnabled) {
            setState(() {
              _isAutoScrollingEnabled = isEnabled;
              if (!isEnabled) {
                _stopAutoScroll();
              } else if (_isFullScreen) {
                _startAutoScroll();
              }
              _saveSelection();
            });
          },
          initialAutoScrollState: _isAutoScrollingEnabled,
          onAutoScrollModeChanged: (mode) {
            setState(() {
              _autoScrollMode = mode;
              _saveSelection();
            });
          },
          initialAutoScrollMode: _autoScrollMode,
        ),
      ),
    );
  }

  List<TextSpan> _buildVerseTextSpans() {
    List<TextSpan> spans = [];
    if (selectedBook == null || selectedChapter == null || bibleData.isEmpty) {
      return [
        TextSpan(
          text: chapterText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: selectedFontSize,
                fontFamily: selectedFont,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ];
    }

    var book = bibleData.firstWhere(
      (b) => b['book'] == selectedBook,
      orElse: () => null,
    );

    if (book == null) {
      return [
        TextSpan(
          text: chapterText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: selectedFontSize,
                fontFamily: selectedFont,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ];
    }

    var chapter = book['chapters'][selectedChapter! - 1];
    List<dynamic> verses = chapter['verses'];

    for (var verse in verses) {
      String verseNumber = "${verse['verse']}";
      String verseContent = "${verse['text'].toString().trim()}";

      spans.add(
        TextSpan(
          children: [
            TextSpan(
              text: "$verseNumber ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: selectedFontSize,
                fontFamily: selectedFont,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _showVerseOptions(
                    VerseData(
                      book: selectedBook!,
                      chapter: selectedChapter!,
                      verse: int.parse(verse['verse'].toString()),
                      text: verseContent,
                    ),
                  );
                },
            ),
            TextSpan(
              text: "$verseContent ",
              style: TextStyle(
                fontSize: selectedFontSize,
                fontFamily: selectedFont,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dropdownFontSize = screenWidth < 360 ? 14 : 16;

    if (isLoading && books.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
        leading: IconButton(
          icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
          onPressed: _toggleFullScreen,
          tooltip: _isFullScreen ? 'Exit Full Screen' : 'Enter Full Screen',
        ),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReadBookmarksUi()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReadFavoritesUi()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _openSettingsPage();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isFullScreen)
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
                if (!_isFullScreen)
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
                          controller: _scrollController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                children: _buildVerseTextSpans(),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
            if (_isFullScreen)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.onSurface),
                          onPressed: _decreaseAutoScrollSpeed,
                          tooltip: 'Decrease Scroll Speed',
                        ),
                        IconButton(
                          icon: Icon(
                            _isAutoScrolling ? Icons.pause : Icons.play_arrow,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            if (_isAutoScrolling) {
                              _stopAutoScroll();
                            } else {
                              _startAutoScroll();
                            }
                          },
                          tooltip: _isAutoScrolling ? 'Pause Auto Scroll' : 'Start Auto Scroll',
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.onSurface),
                          onPressed: _increaseAutoScrollSpeed,
                          tooltip: 'Increase Scroll Speed',
                        ),
                      ],
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