import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:by_faith_app/models/gospel_map_info_model.dart';
import '../providers/page_notifier.dart';
import '../models/pray_model.dart';
import 'package:by_faith_app/database/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:by_faith_app/ui/gospel_page_ui.dart';
import 'package:by_faith_app/ui/gospel_offline_maps_ui.dart';
import '../providers/theme_notifier.dart';
import 'home_settings_ui.dart';
import 'home_app_support_ui.dart';
import 'home_app_info_ui.dart';
import 'package:fl_chart/fl_chart.dart';

// Enum for page navigation indices
enum AppPages { home, gospel, pray, read, study }

class HomePageUi extends StatefulWidget {
  const HomePageUi({super.key});

  @override
  _HomePageUiState createState() => _HomePageUiState();
}

class _HomePageUiState extends State<HomePageUi> {
  // Use Provider to access the database
  PageNotifier? _pageNotifier;
  int _newPrayersCount = 0;
  int _answeredPrayersCount = 0;
  int _unansweredPrayersCount = 0;
  String _lastRead = 'N/A';
  String _lastBookmark = 'N/A';
  String _lastFavorite = 'N/A';
  String _lastStudied = 'N/A';
  String _lastBibleNote = 'N/A';
  String _lastPersonalNote = 'N/A';
  String _lastStudyNote = 'N/A';
  String _lastSearch = 'N/A';
  String _lastContact = 'N/A';
  String _currentMap = 'N/A';
  int _downloadedMapsCount = 0;
  String _selectedFont = 'Roboto';
  double _selectedFontSize = 16.0;

  bool _isLoading = true; // Initialize as true to show spinner initially
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _pageNotifier = Provider.of<PageNotifier>(context, listen: false);
    _pageNotifier?.addListener(_onPageNotifierChanged);
    _initializeDatabaseAndLoadData(); // Call after pageNotifier setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _pageNotifier?.removeListener(_onPageNotifierChanged);
    super.dispose();
  }

  void _onPageNotifierChanged() {
    if (_pageNotifier?.selectedIndex == AppPages.home.index) {
      _updateDashboardData();
    }
  }

  Future<void> _initializeDatabaseAndLoadData() async {
    try {
      await _updateDashboardData();
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing database or loading data: $e')),
        );
      }
    }
  }

  Future<void> _updateDashboardData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    // Access database via Provider
    final database = Provider.of<AppDatabase>(context, listen: false);

    // Fetch prayer counts
    final prayerCounts = await database.customSelect(
      'SELECT status, COUNT(id) AS count FROM prayers GROUP BY status',
      readsFrom: {database.prayers},
    ).get();

    int newPrayers = 0;
    int answeredPrayers = 0;
    int unansweredPrayers = 0;

    for (final row in prayerCounts) {
      final status = row.read<String>('status');
      final count = row.read<int>('count');
      if (status == 'new') {
        newPrayers = count;
      } else if (status == 'answered') {
        answeredPrayers = count;
      } else if (status == 'unanswered') {
        unansweredPrayers = count;
      }
    }

    final settings = await database.select(database.settings).getSingleOrNull();

    final downloadedMapsCount = await (database.select(database.mapInfoEntries)
          ..where((m) => m.isTemporary.equals(false)))
        .get()
        .then((list) => list.length);

    setState(() {
      _newPrayersCount = newPrayers;
      _answeredPrayersCount = answeredPrayers;
      _unansweredPrayersCount = unansweredPrayers;
      _lastRead = (settings?.lastSelectedBook != null && settings?.lastSelectedChapter != null)
          ? '${settings!.lastSelectedBook} ${settings.lastSelectedChapter}'
          : 'N/A';
      _lastStudied = (settings?.lastSelectedStudyBook != null && settings?.lastSelectedStudyChapter != null)
          ? '${settings!.lastSelectedStudyBook} ${settings.lastSelectedStudyChapter}'
          : 'N/A';
      _lastBookmark = 'N/A'; // TODO: Fetch from Bookmarks table
      _lastFavorite = 'N/A'; // TODO: Fetch from Favorites table
      _lastBibleNote = 'N/A'; // TODO: Fetch from Notes
      _lastPersonalNote = 'N/A'; // TODO: Fetch from Notes
      _lastStudyNote = 'N/A'; // TODO: Fetch from Notes
      _lastSearch = 'N/A'; // TODO: Fetch from Search History
      _lastContact = 'N/A'; // TODO: Fetch from Contacts table
      _currentMap = settings?.lastSelectedMapName ?? 'N/A';
      _downloadedMapsCount = downloadedMapsCount;
      _selectedFont = settings?.selectedStudyFont ?? 'Roboto';
      _selectedFontSize = settings?.selectedStudyFontSize ?? 16.0;
      _isLoading = false;
    });
  }

  double _getAdjustedFontSize(double originalFontSize) {
    // Implement your font size adjustment logic here if needed
    // For now, returning the original font size
    return originalFontSize;
  }

  Widget _buildPrayerChart(double adjustedFontSize) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.blue,
              value: _newPrayersCount.toDouble(),
              title: 'New\n$_newPrayersCount',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: adjustedFontSize * 0.8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.green,
              value: _answeredPrayersCount.toDouble(),
              title: 'Answered\n$_answeredPrayersCount',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: adjustedFontSize * 0.8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.red,
              value: _unansweredPrayersCount.toDouble(),
              title: 'Unanswered\n$_unansweredPrayersCount',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: adjustedFontSize * 0.8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  // ... (rest of the methods remain unchanged: _calculateReadingProgress, _calculateBookmarkProgress, etc.)

  @override
  Widget build(BuildContext context) {
    final adjustedFontSize = _getAdjustedFontSize(_selectedFontSize);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontFamily: _selectedFont,
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
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        // ... (unchanged Drawer code)
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _updateDashboardData(),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 500),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPrayerChart(adjustedFontSize),
                        // ... (unchanged UI code)
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}