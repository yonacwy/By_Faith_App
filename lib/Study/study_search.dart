import 'package:flutter/material.dart';
import 'study_page.dart';

class BibleSearchDelegate extends SearchDelegate {
  final List<dynamic> bibleData;
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  BibleSearchDelegate({required this.bibleData});

  String _removeStrongsNumbers(String text) {
    return text.replaceAll(RegExp(r'\{\(?[HG]\d+\)?\}'), '');
  }

  List<TextSpan> _buildHighlightedText(
      String text, String query, BuildContext context) {
    final List<TextSpan> spans = [];
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

  bool _isNewTestamentBook(String book) {
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

  void _performSearch(String query) {
    isLoading = true;
    searchResults.clear();
    final lowerQuery = query.toLowerCase();

    final List<Map<String, dynamic>> allResults = bibleData
        .where((verse) =>
            verse['text'].toString().toLowerCase().contains(lowerQuery))
        .map<Map<String, dynamic>>((verse) => {
              'book': verse['book_name'],
              'chapter': verse['chapter'],
              'verse': verse['verse'],
              'text': verse['text'],
            })
        .toList();

    final Map<String, List<Map<String, dynamic>>> oldTestamentResults = {};
    final Map<String, List<Map<String, dynamic>>> newTestamentResults = {};

    for (var result in allResults) {
      final book = result['book'] as String;
      if (_isNewTestamentBook(book)) {
        if (!newTestamentResults.containsKey(book)) {
          newTestamentResults[book] = [];
        }
        newTestamentResults[book]!.add(result);
      } else {
        if (!oldTestamentResults.containsKey(book)) {
          oldTestamentResults[book] = [];
        }
        oldTestamentResults[book]!.add(result);
      }
    }

    searchResults = [
      if (oldTestamentResults.isNotEmpty)
        {
          'testament': 'Old Testament',
          'count': oldTestamentResults.values.fold<int>(
              0, (sum, verses) => sum + verses.length),
          'books': oldTestamentResults.entries
              .map((entry) => {
                    'book': entry.key,
                    'verses': entry.value,
                    'count': entry.value.length,
                  })
              .toList(),
        },
      if (newTestamentResults.isNotEmpty)
        {
          'testament': 'New Testament',
          'count': newTestamentResults.values.fold<int>(
              0, (sum, verses) => sum + verses.length),
          'books': newTestamentResults.entries
              .map((entry) => {
                    'book': entry.key,
                    'verses': entry.value,
                    'count': entry.value.length,
                  })
              .toList(),
        },
    ];

    isLoading = false;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          searchResults.clear();
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
    if (query.isNotEmpty && query != searchResults.toString()) {
      _performSearch(query);
    }

    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
              ? Center(
                  child: Text(
                    'No results found for "$query"',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final testament = searchResults[index];
                    final String testamentName = testament['testament'] as String;
                    final int testamentCount = testament['count'] as int;
                    final List<dynamic> books = testament['books'] as List;

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
                          '$testamentName ($testamentCount)',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        children: books.map((bookEntry) {
                          final String book = bookEntry['book'] as String;
                          final List<Map<String, dynamic>> verses =
                              bookEntry['verses'] as List<Map<String, dynamic>>;
                          final int bookCount = bookEntry['count'] as int;

                          return ExpansionTile(
                            title: Text(
                              '$book ($bookCount)',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            children: verses.map((verse) {
                              final text = verse['text'].toString();
                              final queryLower = query.toLowerCase();
                              final spans = _buildHighlightedText(
                                  text, queryLower, context);

                              return ListTile(
                                title: Text(
                                  '${verse['chapter']}:${verse['verse']}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: RichText(
                                  text: TextSpan(
                                    children: spans,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  // Ensure book and chapter are valid before navigating
                                  final String? bookName = verse['book'];
                                  final int? chapter = verse['chapter'];
                                  if (bookName != null && chapter != null) {
                                    try {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => StudyPage(
                                            initialBook: bookName,
                                            initialChapter: chapter,
                                          ),
                                        ),
                                      ).then((_) {
                                        // Close the search delegate after navigation
                                        close(context, null);
                                      });
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error navigating to $bookName $chapter: $e'),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Invalid book or chapter data'),
                                      ),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}