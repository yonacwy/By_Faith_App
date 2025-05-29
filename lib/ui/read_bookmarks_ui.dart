import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/read_data_model.dart'; // Import your data model
import 'read_page_ui.dart'; // Import ReadPageUi

class ReadBookmarksUi extends StatefulWidget {
  const ReadBookmarksUi({super.key});

  @override
  State<ReadBookmarksUi> createState() => _ReadBookmarksUiState();
}

class _ReadBookmarksUiState extends State<ReadBookmarksUi> {
  late Box<Bookmark> bookmarksBox;

  @override
  void initState() {
    super.initState();
    _openBookmarksBox();
  }

  Future<void> _openBookmarksBox() async {
    bookmarksBox = await Hive.openBox<Bookmark>('bookmarks');
    setState(() {}); // Refresh UI after box is opened
  }

  Future<void> _deleteBookmark(int index) async {
    await bookmarksBox.deleteAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark removed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Bookmark>('bookmarks').listenable(),
        builder: (context, Box<Bookmark> box, _) {
          if (box.values.isEmpty) {
            return Center(
              child: Text(
                'No bookmarks yet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final bookmark = box.getAt(index)!;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: ListTile(
                  title: Text(
                    '${bookmark.verseData.book} ${bookmark.verseData.chapter}:${bookmark.verseData.verse}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: Text(
                    bookmark.verseData.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    onPressed: () => _deleteBookmark(index),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReadPageUi(
                          initialBook: bookmark.verseData.book,
                          initialChapter: bookmark.verseData.chapter,
                          initialVerse: bookmark.verseData.verse,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}