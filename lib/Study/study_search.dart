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

    final Map<String, List<Map<String, dynamic>>> groupedResults = {};
    for (var result in allResults) {
      final book = result['book'] as String;
      if (!groupedResults.containsKey(book)) {
        groupedResults[book] = [];
      }
      groupedResults[book]!.add(result);
    }

    searchResults = groupedResults.entries
        .map((entry) => {
              'book': entry.key,
              'verses': entry.value,
            })
        .toList();

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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        children: verses.map((verse) {
                          final text = verse['text'].toString();
                          final queryLower = query.toLowerCase();
                          final spans =
                              _buildHighlightedText(text, queryLower, context);

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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudyPage(
                                    initialBook: verse['book'],
                                    initialChapter: verse['chapter'],
                                  ),
                                ),
                              );
                              close(context, null);
                            },
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