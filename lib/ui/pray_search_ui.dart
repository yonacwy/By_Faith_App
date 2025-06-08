import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:by_faith_app/objectbox.dart';
import 'dart:convert';
import '../models/pray_page_model.dart';
import 'package:objectbox/objectbox.dart';

class PraySearchUi extends StatefulWidget {
  final TextEditingController searchController;
  final String initialSearchQuery;
  final GlobalKey<AnimatedListState> newListKey;
  final GlobalKey<AnimatedListState> answeredListKey;
  final GlobalKey<AnimatedListState> unansweredListKey;
  final Function(PrayPageModel, String, int) updatePrayerStatus;
  final Function(PrayPageModel, int, String) deletePrayer;
  final Function(PrayPageModel, int) editPrayer;

  const PraySearchUi({
    Key? key,
    required this.searchController,
    required this.initialSearchQuery,
    required this.newListKey,
    required this.answeredListKey,
    required this.unansweredListKey,
    required this.updatePrayerStatus,
    required this.deletePrayer,
    required this.editPrayer,
  }) : super(key: key);

  @override
  _PraySearchUiState createState() => _PraySearchUiState();
}

class _PraySearchUiState extends State<PraySearchUi> {
  late String _searchQuery;
  late Box<PrayPageModel> _prayerBox;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery;
    _prayerBox = objectbox.store.box<PrayPageModel>();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = widget.searchController.text.toLowerCase();
    });
  }

  Widget _buildPrayerCard(PrayPageModel prayer, String status, int index) {
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
          widget.deletePrayer(prayer, index, status);
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          final List<String> statusOptions = ['new', 'answered', 'unanswered']
              .where((s) => s != status)
              .toList();
          final newStatus = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Change Status'),
              content: const Text('Mark this prayer as:'),
              actions: statusOptions.map((option) {
                return TextButton(
                  onPressed: () => Navigator.pop(context, option),
                  child: Text(
                    option == 'new'
                        ? 'New'
                        : option == 'answered'
                            ? 'Answered'
                            : 'Unanswered',
                  ),
                );
              }).toList()
                ..add(
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
            ),
          );
          if (newStatus != null) {
            widget.updatePrayerStatus(prayer, newStatus, index);
            return true;
          }
          return false;
        }
        return false;
      },
      background: Container(
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: () => widget.editPrayer(prayer, index),
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
                  config: const quill.QuillEditorConfig(
                    padding: EdgeInsets.all(0),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: widget.searchController,
          decoration: InputDecoration(
            hintText: 'Search prayers...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Builder(
        builder: (context) {
          var prayers = _prayerBox.query().build().find(); // Get all prayers
          prayers = prayers.where((prayer) {
            final document = quill.Document.fromJson(jsonDecode(prayer.richTextJson));
            return document.toPlainText().toLowerCase().contains(_searchQuery);
          }).toList();
          prayers.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return prayers.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _searchQuery.isEmpty ? 'No prayers to display' : 'No matching prayers',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              : ListView.builder(
                  itemCount: prayers.length,
                  itemBuilder: (context, index) {
                    final prayer = prayers[index];
                    return _buildPrayerCard(prayer, prayer.status, index);
                  },
                );
        },
      ),
    );
  }
}