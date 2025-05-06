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

class _PrayPageState extends State<PrayPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();
  late Box<Prayer> _prayerBox;
  String _searchQuery = '';
  bool _isSearching = false;
  final GlobalKey<AnimatedListState> _newListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _answeredListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _unansweredListKey = GlobalKey<AnimatedListState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _prayerBox = Hive.box<Prayer>('prayers');
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quillController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _addPrayer() {
    if (!_quillController.document.isEmpty()) {
      final richTextJson = jsonEncode(_quillController.document.toDelta().toJson());
      final newPrayer = Prayer(
        richTextJson: richTextJson,
        status: 'new',
        timestamp: DateTime.now(),
      );
      _prayerBox.add(newPrayer);
      _quillController.clear();
      FocusScope.of(context).unfocus();

      // Insert at index 0 (newest first)
      _newListKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Prayer added'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updatePrayerStatus(Prayer prayer, String status, int index) {
    final oldStatus = prayer.status;
    setState(() {
      prayer.status = status;
      prayer.save();
    });

    // Remove from old list
    final oldListKey = oldStatus == 'new'
        ? _newListKey
        : oldStatus == 'answered'
            ? _answeredListKey
            : _unansweredListKey;
    oldListKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: _buildPrayerCard(prayer, oldStatus, index),
      ),
      duration: const Duration(milliseconds: 300),
    );

    // Insert into new list (newest first)
    final newListKey = status == 'new'
        ? _newListKey
        : status == 'answered'
            ? _answeredListKey
            : _unansweredListKey;
    final prayersInNewStatus = _prayerBox.values.where((p) => p.status == status).toList();
    prayersInNewStatus.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final insertionIndex = prayersInNewStatus.indexWhere((p) => p.id == prayer.id);
    newListKey.currentState?.insertItem(insertionIndex, duration: const Duration(milliseconds: 300));

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

    // Temporarily store prayer data
    final deletedPrayerData = Prayer(
      richTextJson: prayer.richTextJson,
      status: prayer.status,
      timestamp: prayer.timestamp,
      id: prayer.id,
    );

    // Animate removal
    listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: _buildPrayerCard(deletedPrayerData, status, index),
      ),
      duration: const Duration(milliseconds: 300),
    );

    // Delete from Hive
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _EditPrayerPage(prayer: prayer, index: index),
      ),
    );
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
    quillController.readOnly = true;

    return Dismissible(
      key: ValueKey(prayer.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete
          _deletePrayer(prayer, index, status);
          return true;
        } else if (direction == DismissDirection.startToEnd && status == 'new') {
          // Change status (answered or unanswered)
          final newStatus = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Change Status'),
              content: const Text('Mark this prayer as:'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'answered'),
                  child: const Text('Answered'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'unanswered'),
                  child: const Text('Unanswered'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
          if (newStatus != null) {
            _updatePrayerStatus(prayer, newStatus, index);
            return true;
          }
          return false;
        }
        return false;
      },
      background: Container(
        color: status == 'new' ? Theme.of(context).colorScheme.primary : Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: status == 'new'
            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary)
            : null,
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: () => _editPrayer(prayer, index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                quill.QuillEditor(
                  controller: quillController,
                  scrollController: ScrollController(),
                  focusNode: FocusNode(),
                  configurations: quill.QuillEditorConfigurations(
                    showCursor: false,
                    padding: const EdgeInsets.all(0),
                    maxHeight: 40,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(prayer.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM d, yyyy').format(timestamp);
  }

  Widget _buildPrayerList(String status, GlobalKey<AnimatedListState> listKey) {
    return ValueListenableBuilder(
      valueListenable: _prayerBox.listenable(),
      builder: (context, Box<Prayer> box, _) {
        var prayers = box.values
            .where((prayer) {
              final document = quill.Document.fromJson(jsonDecode(prayer.richTextJson));
              return prayer.status == status &&
                  document.toPlainText().toLowerCase().contains(_searchQuery);
            })
            .toList();
        prayers.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
        if (prayers.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _searchQuery.isEmpty ? 'No prayers in this category' : 'No matching prayers',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }
        return AnimatedList(
          key: listKey,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
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
            padding: const EdgeInsets.all(8),
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
            padding: const EdgeInsets.all(8),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'New'),
              Tab(text: 'Answered'),
              Tab(text: 'Unanswered'),
            ],
            labelStyle: Theme.of(context).textTheme.titleSmall,
            unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPrayers,
          color: Theme.of(context).colorScheme.primary,
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPrayerList('new', _newListKey),
                    _buildPrayerList('answered', _answeredListKey),
                    _buildPrayerList('unanswered', _unansweredListKey),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        quill.QuillToolbar.simple(
                          configurations: quill.QuillSimpleToolbarConfigurations(
                            controller: _quillController,
                            multiRowsDisplay: false,
                            showAlignmentButtons: false,
                            showBackgroundColorButton: false,
                            showColorButton: false,
                            showListCheck: false,
                            showDividers: false,
                          ),
                        ),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              quill.QuillEditor(
                                controller: _quillController,
                                scrollController: ScrollController(),
                                focusNode: FocusNode(),
                                configurations: quill.QuillEditorConfigurations(
                                  placeholder: 'Enter your prayer...',
                                  padding: const EdgeInsets.fromLTRB(8, 8, 40, 8),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 0,
                                bottom: 0,
                                child: Semantics(
                                  label: 'Add new prayer',
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
                                    onPressed: _addPrayer,
                                    tooltip: 'Add prayer',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New full-screen edit page
class _EditPrayerPage extends StatefulWidget {
  final Prayer prayer;
  final int index;

  const _EditPrayerPage({required this.prayer, required this.index});

  @override
  _EditPrayerPageState createState() => _EditPrayerPageState();
}

class _EditPrayerPageState extends State<_EditPrayerPage> {
  late quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController(
      document: quill.Document.fromJson(jsonDecode(widget.prayer.richTextJson)),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillController.readOnly = false;
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  void _savePrayer() {
    if (_quillController.document.isEmpty()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Prayer cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      widget.prayer.richTextJson = jsonEncode(_quillController.document.toDelta().toJson());
      widget.prayer.save();
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Prayer updated'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Prayer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Cancel',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePrayer,
            tooltip: 'Save',
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                quill.QuillToolbar.simple(
                  configurations: quill.QuillSimpleToolbarConfigurations(
                    controller: _quillController,
                    multiRowsDisplay: false,
                    showAlignmentButtons: false,
                    showBackgroundColorButton: false,
                    showColorButton: false,
                    showListCheck: false,
                    showDividers: true,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: quill.QuillEditor(
                    controller: _quillController,
                    scrollController: ScrollController(),
                    focusNode: FocusNode()..requestFocus(),
                    configurations: quill.QuillEditorConfigurations(
                      autoFocus: true,
                      expands: false,
                      padding: const EdgeInsets.all(8),
                      minHeight: MediaQuery.of(context).size.height * 0.5, // At least half screen height
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}