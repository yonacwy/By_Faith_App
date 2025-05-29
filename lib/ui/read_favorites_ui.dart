import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/read_data_model.dart'; // Import your data model
import 'read_page_ui.dart'; // Import ReadPageUi

class ReadFavoritesUi extends StatefulWidget {
  const ReadFavoritesUi({super.key});

  @override
  State<ReadFavoritesUi> createState() => _ReadFavoritesUiState();
}

class _ReadFavoritesUiState extends State<ReadFavoritesUi> {
  late Box<Favorite> favoritesBox;

  @override
  void initState() {
    super.initState();
    _openFavoritesBox();
  }

  Future<void> _openFavoritesBox() async {
    favoritesBox = await Hive.openBox<Favorite>('favorites');
    setState(() {}); // Refresh UI after box is opened
  }

  Future<void> _deleteFavorite(int index) async {
    await favoritesBox.deleteAt(index);
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
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Favorite>('favorites').listenable(),
        builder: (context, Box<Favorite> box, _) {
          if (box.values.isEmpty) {
            return Center(
              child: Text(
                'No favorites yet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final favorite = box.getAt(index)!;
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
                    onPressed: () => _deleteFavorite(index),
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