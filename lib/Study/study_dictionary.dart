import 'package:flutter/material.dart';

class StrongsDictionaryPage extends StatelessWidget {
  final String strongsNumber;
  final String? bookName;
  final Map<String, dynamic> hebrewDictionary;
  final Map<String, dynamic> greekDictionary;

  const StrongsDictionaryPage({
    super.key,
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