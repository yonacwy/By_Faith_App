import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database.dart'; // Import your Drift database
import '../models/read_data_model.dart'; // Import your data model
import 'read_page_ui.dart'; // Import ReadPageUi

class ReadFavoritesUi extends StatefulWidget {
  const ReadFavoritesUi({super.key});

  @override
  State<ReadFavoritesUi> createState() => _ReadFavoritesUiState();
}

class _ReadFavoritesUiState extends State<ReadFavoritesUi> {
  late AppDatabase _database;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _database = Provider.of<AppDatabase>(context);
  }

  Future<void> _deleteFavorite(FavoriteEntry favorite) async {
    await _database.deleteFavorite(favorite);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite removed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<FavoriteEntry>>(
        stream: _database.watchAllFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No favorites yet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }
          final favorites = snapshot.data!;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: ListTile(
                  title: Text(
                    '${favorite.verseBook} ${favorite.verseChapter}:${favorite.verseVerse}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: FutureBuilder<VerseDataEntry?>(
                    future: _database.getVerseData(favorite.verseBook, favorite.verseChapter, favorite.verseVerse),
                    builder: (context, verseSnapshot) {
                      if (verseSnapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading verse text...');
                      } else if (verseSnapshot.hasError) {
                        return Text('Error loading verse: ${verseSnapshot.error}');
                      } else if (!verseSnapshot.hasData || verseSnapshot.data == null) {
                        return const Text('Verse text not found.');
                      }
                      final verseData = verseSnapshot.data!;
                      return Text(
                        verseData.verseTextContent,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    onPressed: () => _deleteFavorite(favorite),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReadPageUi(
                          initialBook: favorite.verseBook,
                          initialChapter: favorite.verseChapter,
                          initialVerse: favorite.verseVerse,
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