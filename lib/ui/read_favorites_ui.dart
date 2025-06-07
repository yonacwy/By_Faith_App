import 'package:flutter/material.dart';
import 'package:by_faith_app/objectbox.dart';
import '../models/read_data_model.dart'; // Import your data model
import 'read_page_ui.dart'; // Import ReadPageUi
import 'package:flutter/material.dart';

class ReadFavoritesUi extends StatefulWidget {
  const ReadFavoritesUi({super.key});

  @override
  State<ReadFavoritesUi> createState() => _ReadFavoritesUiState();
}

class _ReadFavoritesUiState extends State<ReadFavoritesUi> {
  // late Box<Favorite> favoritesBox; // Not needed with ObjectBox

  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteFavorite(Favorite favorite) async {
    objectbox.favoriteBox.remove(favorite.id);
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
      body: StreamBuilder<List<Favorite>>(
       stream: objectbox.favoriteBox.query().watch(triggerImmediately: true).map((query) => query.find()),
       builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
         }
         if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                    '${favorite.verseData.book} ${favorite.verseData.chapter}:${favorite.verseData.verse}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: Text(
                    favorite.verseData.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                          initialBook: favorite.verseData.book,
                          initialChapter: favorite.verseData.chapter,
                          initialVerse: favorite.verseData.verse,
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