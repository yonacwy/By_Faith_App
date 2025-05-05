import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../models/prayer.dart';
import '../providers/theme_notifier.dart';
import 'dart:convert';

class PrayPage extends StatefulWidget {
  const PrayPage({super.key});

  @override
  _PrayPageState createState() => _PrayPageState();
}

class _PrayPageState extends State<PrayPage> {
  final TextEditingController _prayerController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late Box<Prayer> _prayerBox;
  String _searchQuery = '';
  bool _isSearching = false;
  String _sortBy = 'date_desc'; // Default sort: newest first
  final GlobalKey<AnimatedListState> _newListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _answeredListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _unansweredListKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _prayerBox = Hive.box<Prayer>('prayers');
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _prayerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addPrayer() {
    if (_prayerController.text.isNotEmpty) {
      // Create a basic Quill Delta with the plain text
      final quillController = quill.QuillController.basic();
      quillController.document.insert(0, _prayerController.text);
      final richTextJson = jsonEncode(quillController.document.toDelta().toJson());

      final newPrayer = Prayer(
        richTextJson: richTextJson,
        status: 'new',
        timestamp: DateTime.now(),
      );
      _prayerBox.add(newPrayer);
      _prayerController.clear();
      FocusScope.of(context).unfocus();

      // Calculate insertion index based on sort order
      int insertionIndex = 0; // Default for 'date_desc' (Newest First)
      if (_sortBy == 'date_asc') {
        // For 'date_asc' (Oldest First), insert at the end
        final currentNewPrayers = _prayerBox.values.where((p) => p.status == 'new').toList();
        insertionIndex = currentNewPrayers.length;
      }

      // Use the calculated index for insertion animation
      _newListKey.currentState?.insertItem(insertionIndex, duration: const Duration(milliseconds: 300));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Prayer added'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updatePrayerStatus(Prayer prayer, String status) {
    setState(() {
      prayer.status = status;
      prayer.save();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prayer marked as $status'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deletePrayer(Prayer prayer, int index, String status) {
    final listKey = status == 'new'
        ? _newListKey
        : status == 'answered'
            ? _answeredListKey
            : _unansweredListKey;

    // Temporarily store prayer data before deleting from box
    final deletedPrayerData = Prayer(
      richTextJson: prayer.richTextJson,
      status: prayer.status,
      timestamp: prayer.timestamp,
      id: prayer.id,
    );

    // Animate removal first
    listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: _buildPrayerCard(deletedPrayerData, status, index),
      ),
      duration: const Duration(milliseconds: 300),
    );

    // Delete from Hive AFTER initiating animation
    Future.delayed(const Duration(milliseconds: 50), () {
      if (prayer.isInBox) {
        prayer.delete();
      }
      setState(() {});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Prayer deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _prayerBox.put(deletedPrayerData.id, deletedPrayerData);
            setState(() {});
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _editPrayer(Prayer prayer, int index) {
    final quillController = quill.QuillController(
      document: quill.Document.fromJson(jsonDecode(prayer.richTextJson)),
      selection: const TextSelection.collapsed(offset: 0),
    );
    quillController.readOnly = false; // Enable editing

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Prayer'),
          content: Container(
            height: 300,
            width: double.maxFinite,
            child: Column(
              children: [
                quill.QuillToolbar.simple(
                  configurations: quill.QuillSimpleToolbarConfigurations(
                    controller: quillController,
                    multiRowsDisplay: false,
                    showAlignmentButtons: false,
                    showBackgroundColorButton: false,
                    showColorButton: false,
                    showListCheck: false,
                    showDividers: true,
                  ),
                ),
                Expanded(
                  child: quill.QuillEditor(
                    controller: quillController,
                    scrollController: ScrollController(),
                    focusNode: FocusNode(),
                    configurations: quill.QuillEditorConfigurations(
                      autoFocus: true,
                      expands: true,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (quillController.document.isEmpty()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Prayer cannot be empty'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                setState(() {
                  prayer.richTextJson = jsonEncode(quillController.document.toDelta().toJson());
                  prayer.save();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Prayer updated'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      },
    ).then((_) => quillController.dispose());
  }

  Future<void> _refreshPrayers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  void _toggleTheme() {
    Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
  }

  Widget _buildPrayerCard(Prayer prayer, String status, int index) {
    final quillController = quill.QuillController(
      document: quill.Document.fromJson(jsonDecode(prayer.richTextJson)),
      selection: const TextSelection.collapsed(offset: 0),
    );
    quillController.readOnly = true; // Disable editing for display

    return Dismissible(
      key: ValueKey(prayer.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deletePrayer(prayer, index, status),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: quill.QuillEditor(
            controller: quillController,
            scrollController: ScrollController(),
            focusNode: FocusNode(),
            configurations: quill.QuillEditorConfigurations(
              showCursor: false,
              padding: const EdgeInsets.all(0),
              maxHeight: 50,
            ),
          ),
          subtitle: Text(
            _formatTimestamp(prayer.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, semanticLabel: 'Edit prayer'),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () => _editPrayer(prayer, index),
                tooltip: 'Edit prayer',
              ),
              if (status == 'new') ...[
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, semanticLabel: 'Mark as answered'),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => _updatePrayerStatus(prayer, 'answered'),
                  tooltip: 'Mark as answered',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, semanticLabel: 'Mark as unanswered'),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () => _updatePrayerStatus(prayer, 'unanswered'),
                  tooltip: 'Mark as unanswered',
                ),
              ],
              if (status != 'new')
                IconButton(
                  icon: const Icon(Icons.refresh, semanticLabel: 'Reset to new'),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () => _updatePrayerStatus(prayer, 'new'),
                  tooltip: 'Reset to new',
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, semanticLabel: 'Delete prayer'),
                color: Theme.of(context).colorScheme.error,
                onPressed: () => _deletePrayer(prayer, index, status),
                tooltip: 'Delete prayer',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM d, yyyy').format(timestamp);
  }

  Widget _buildPrayerList(String status, String title, GlobalKey<AnimatedListState> listKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              if (status == 'new' && _prayerBox.values.any((p) => p.status == status))
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'date_desc', child: Text('Newest First')),
                    DropdownMenuItem(value: 'date_asc', child: Text('Oldest First')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                  style: Theme.of(context).textTheme.bodyMedium,
                  dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _prayerBox.listenable(),
          builder: (context, Box<Prayer> box, _) {
            var prayers = box.values
                .where((prayer) {
                  final document = quill.Document.fromJson(jsonDecode(prayer.richTextJson));
                  return prayer.status == status &&
                      document.toPlainText().toLowerCase().contains(_searchQuery);
                })
                .toList();
            if (_sortBy == 'date_desc') {
              prayers.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            } else {
              prayers.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            }
            if (prayers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _searchQuery.isEmpty ? 'No $title' : 'No matching $title',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              );
            }
            return AnimatedList(
              key: listKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              initialItemCount: prayers.length,
              itemBuilder: (context, index, animation) {
                if (index >= prayers.length) {
                  return Container(child: const Text("Error: Index out of bounds"));
                }
                final prayer = prayers[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: _buildPrayerCard(prayer, status, index),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search prayers...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              )
            : const Text('Prayers'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            tooltip: _isSearching ? 'Close search' : 'Search prayers',
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light ? Icons.dark_mode : Icons.light_mode,
              semanticLabel: Theme.of(context).brightness == Brightness.light
                  ? 'Switch to dark mode'
                  : 'Switch to light mode',
            ),
            onPressed: _toggleTheme,
            tooltip: Theme.of(context).brightness == Brightness.light
                ? 'Switch to dark mode'
                : 'Switch to light mode',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPrayers,
          color: Theme.of(context).colorScheme.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Bottom padding for FAB
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _prayerController,
                            decoration: InputDecoration(
                              labelText: 'Enter your prayer',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  semanticLabel: 'Add prayer',
                                ),
                                onPressed: _addPrayer,
                                tooltip: 'Add prayer',
                              ),
                            ),
                            onSubmitted: (_) => _addPrayer(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPrayerList('new', 'New Prayers', _newListKey),
                      const SizedBox(height: 16),
                      _buildPrayerList('answered', 'Answered Prayers', _answeredListKey),
                      const SizedBox(height: 16),
                      _buildPrayerList('unanswered', 'Unanswered Prayers', _unansweredListKey),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth > 600
              ? FloatingActionButton.extended(
                  onPressed: _addPrayer,
                  label: const Text('Add Prayer'),
                  icon: const Icon(Icons.add),
                  tooltip: 'Add a new prayer',
                )
              : FloatingActionButton(
                  onPressed: _addPrayer,
                  child: const Icon(Icons.add),
                  tooltip: 'Add a new prayer',
                );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}