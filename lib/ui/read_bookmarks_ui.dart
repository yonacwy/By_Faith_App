import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database.dart'; // Import your AppDatabase
import '../models/read_data_model.dart'; // Import your data model
import 'read_page_ui.dart'; // Import ReadPageUi

class ReadBookmarksUi extends StatefulWidget {
  const ReadBookmarksUi({super.key});

  @override
  State<ReadBookmarksUi> createState() => _ReadBookmarksUiState();
}

class _ReadBookmarksUiState extends State<ReadBookmarksUi> {
  late AppDatabase database;

  @override
  void initState() {
    super.initState();
    database = Provider.of<AppDatabase>(context, listen: false);
  }


  Future<void> _deleteBookmark(BookmarkEntry bookmark) async {
    await database.deleteBookmark(bookmark);
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
      body: StreamBuilder<List<BookmarkEntry>>(
        stream: database.watchAllBookmarks(),
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
                    '${bookmark.verseBook} ${bookmark.verseChapter}:${bookmark.verseVerse}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: FutureBuilder<VerseDataEntry?>(
                    future: database.getVerseData(bookmark.verseBook, bookmark.verseChapter, bookmark.verseVerse),
                    builder: (context, verseSnapshot) {
                      if (verseSnapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading verse...');
                      }
                      if (verseSnapshot.hasData && verseSnapshot.data != null) {
                        return Text(
                          verseSnapshot.data!.verseTextContent,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      return const Text('Verse not found');
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    onPressed: () => _deleteBookmark(bookmark),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReadPageUi(
                          initialBook: bookmark.verseBook,
                          initialChapter: bookmark.verseChapter,
                          initialVerse: bookmark.verseVerse,
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