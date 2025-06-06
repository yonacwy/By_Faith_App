import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../models/pray_model.dart';
import '../providers/theme_notifier.dart';
import 'dart:convert';
import 'pray_settings_ui.dart';
import 'pray_search_ui.dart';
import 'pray_share_ui.dart';

class PrayPageUi extends StatefulWidget {
  PrayPageUi({Key? key}) : super(key: key);

  @override
  _PrayPageUiState createState() => _PrayPageUiState();
}

class _PrayPageUiState extends State<PrayPageUi> with TickerProviderStateMixin {
  late Box<Prayer> _prayerBox;
  final GlobalKey<AnimatedListState> _newListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _answeredListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _unansweredListKey = GlobalKey<AnimatedListState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _prayerBox = Hive.box<Prayer>('prayers');
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updatePrayerStatus(Prayer prayer, String newStatus, int index) {
    final oldStatus = prayer.status;
    if (oldStatus == newStatus) return;

    setState(() {
      prayer.status = newStatus;
      prayer.save();
    });

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

    final newListKey = newStatus == 'new'
        ? _newListKey
        : newStatus == 'answered'
            ? _answeredListKey
            : _unansweredListKey;
    final prayersInNewStatus = _prayerBox.values.where((p) => p.status == newStatus).toList();
    prayersInNewStatus.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final insertionIndex = prayersInNewStatus.indexWhere((p) => p.id == prayer.id);
    newListKey.currentState?.insertItem(
      insertionIndex >= 0 ? insertionIndex : 0,
      duration: const Duration(milliseconds: 300),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prayer marked as $newStatus'),
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

    final deletedPrayerData = Prayer(
      richTextJson: prayer.richTextJson,
      status: prayer.status,
      timestamp: prayer.timestamp,
      id: prayer.id,
    );

    listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: _buildPrayerCard(deletedPrayerData, status, index),
      ),
      duration: const Duration(milliseconds: 300),
    );

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

  void _openNewPrayerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _NewPrayerPage(
          onSave: (newPrayer) {
            _prayerBox.add(newPrayer);
            _newListKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Prayer added'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PraySettingsUi(),
      ),
    );
  }

  void _openSharePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrayShareUi(),
      ),
    );
  }

  Future<void> _refreshPrayers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
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
          _deletePrayer(prayer, index, status);
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
            _updatePrayerStatus(prayer, newStatus, index);
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

  Widget _buildPrayerList(String status, GlobalKey<AnimatedListState> listKey) {
    return ValueListenableBuilder(
      valueListenable: _prayerBox.listenable(),
      builder: (context, Box<Prayer> box, _) {
        var prayers = box.values
            .where((prayer) {
              final document = quill.Document.fromJson(jsonDecode(prayer.richTextJson));
              return prayer.status == status;
            })
            .toList();
        prayers.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (status == 'new') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Semantics(
                  label: 'Add new prayer',
                  child: ElevatedButton.icon(
                    onPressed: _openNewPrayerPage,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Prayer'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: prayers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No new prayers',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      )
                    : AnimatedList(
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
                      ),
              ),
            ],
          );
        } else {
          return prayers.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No ${status == 'answered' ? 'answered' : 'unanswered'} prayers',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              : AnimatedList(
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
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth < 320 ? 12 : screenWidth < 360 ? 14 : 16;
    final bool isWideScreen = screenWidth > 600;
    final double tabPadding = screenWidth < 320 ? 4 : screenWidth < 360 ? 6 : 8;
    final double tabBarPadding = screenWidth < 320 ? 2 : 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayers'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                tooltip: 'Menu',
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft, // Align tabs to the left
            child: Container(
              constraints: BoxConstraints(maxWidth: screenWidth),
              child: TabBar(
                controller: _tabController,
                isScrollable: !isWideScreen,
                tabAlignment: !isWideScreen ? TabAlignment.start : TabAlignment.fill, // Align tabs to start when scrollable, fill otherwise
                tabs: const [
                  Tab(text: 'New'),
                  Tab(text: 'Answered'),
                  Tab(text: 'Unanswered'),
                ],
                labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                unselectedLabelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                    ),
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                labelPadding: EdgeInsets.symmetric(horizontal: tabPadding),
                padding: EdgeInsets.symmetric(horizontal: tabBarPadding),
              ),
            ),
          ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Prayers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PraySearchUi(
                      searchController: TextEditingController(),
                      initialSearchQuery: '',
                      newListKey: _newListKey,
                      answeredListKey: _answeredListKey,
                      unansweredListKey: _unansweredListKey,
                      updatePrayerStatus: _updatePrayerStatus,
                      deletePrayer: _deletePrayer,
                      editPrayer: _editPrayer,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Prayers'),
              onTap: () {
                Navigator.pop(context);
                _openSharePage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _openSettingsPage();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPrayers,
          color: Theme.of(context).colorScheme.primary,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPrayerList('new', _newListKey),
              _buildPrayerList('answered', _answeredListKey),
              _buildPrayerList('unanswered', _unansweredListKey),
            ],
          ),
        ),
      ),
    );
  }
}

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
        content: Text('Prayer updated'),
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
                quill.QuillSimpleToolbar(
                  controller: _quillController,
                  config: const quill.QuillSimpleToolbarConfig(
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
                    config: quill.QuillEditorConfig(
                      autoFocus: true,
                      expands: false,
                      padding: const EdgeInsets.all(8),
                      minHeight: MediaQuery.of(context).size.height * 0.5,
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

class _NewPrayerPage extends StatefulWidget {
  final Function(Prayer) onSave;

  const _NewPrayerPage({required this.onSave});

  @override
  _NewPrayerPageState createState() => _NewPrayerPageState();
}

class _NewPrayerPageState extends State<_NewPrayerPage> {
  late quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
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
    final newPrayer = Prayer(
      richTextJson: jsonEncode(_quillController.document.toDelta().toJson()),
      status: 'new',
      timestamp: DateTime.now(),
    );
    widget.onSave(newPrayer);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prayer'),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                quill.QuillSimpleToolbar(
                  controller: _quillController,
                  config: const quill.QuillSimpleToolbarConfig(

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
                  padding: const EdgeInsets.all(8),
                  child: quill.QuillEditor(
                    controller: _quillController,
                    scrollController: ScrollController(),
                    focusNode: FocusNode()..requestFocus(),
                    config: quill.QuillEditorConfig(
                      autoFocus: true,
                      expands: false,
                      padding: const EdgeInsets.all(0),
                      minHeight: MediaQuery.of(context).size.height * 0.5,
                      placeholder: 'Enter your prayer...',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Submit new prayer',
                  child: ElevatedButton(
                    onPressed: _savePrayer,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Submit'),
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