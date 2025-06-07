import 'package:flutter/material.dart';
import '../models/read_data_model.dart'; // Import your data model
import 'read_page_ui.dart'; // Import ReadPageUi
import '../objectbox.dart'; // Import objectbox
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

class ReadBookmarksUi extends StatefulWidget {
  const ReadBookmarksUi({super.key});

  @override
  State<ReadBookmarksUi> createState() => _ReadBookmarksUiState();
}

class _ReadBookmarksUiState extends State<ReadBookmarksUi> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteBookmark(int id) async {
    objectbox.bookmarkBox.remove(id);
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
      body: StreamBuilder<List<Bookmark>>(
        stream: objectbox.bookmarkBox.query().watch(triggerImmediately: true).map((query) => query.find()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No bookmarks yet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }
          final bookmarks = snapshot.data!;
          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
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
                    onPressed: () => _deleteBookmark(bookmark.id),
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