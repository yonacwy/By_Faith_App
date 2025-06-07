import 'package:by_faith_app/models/gospel_map_info_model.dart';
import '../providers/page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:by_faith_app/objectbox.dart';
import 'package:by_faith_app/models/pray_model.dart';
import 'package:by_faith_app/models/gospel_map_info_model.dart';
import 'package:by_faith_app/models/gospel_onboarding_model.dart'; // For user preferences
import '../models/pray_model.dart';
import 'package:by_faith_app/ui/gospel_page_ui.dart';
import 'package:by_faith_app/ui/gospel_offline_maps_ui.dart';
import 'package:provider/provider.dart';
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
  late Box<Prayer> _prayerBox;
  late Box<GospelOnboardingModel> _userPrefsBox; // Using GospelOnboardingModel for user preferences
  late Box<MapInfo> _mapBox;
  PageNotifier? _pageNotifier; // Nullable PageNotifier instance

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

  bool _isInitialized = false;
  bool _isLoading = false; // Added for loading state during data updates
  double _opacity = 0.0; // For fade-in animation

  @override
  void initState() {
    super.initState();
    _openBoxes();
    // Store PageNotifier instance and add listener
    _pageNotifier = Provider.of<PageNotifier>(context, listen: false);
    _pageNotifier?.addListener(_onPageNotifierChanged);
    // Trigger fade-in animation
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

  /// Handles page change events from PageNotifier
  void _onPageNotifierChanged() {
    if (_pageNotifier?.selectedIndex == AppPages.home.index) {
      _updateDashboardData();
    }
  }

  /// Opens ObjectBox boxes
  Future<void> _openBoxes() async {
    try {
      // Remove existing listeners if initialized
      _isInitialized = false;
      setState(() => _isLoading = true);

      final store = objectbox.store;
      _prayerBox = store.box<Prayer>();
      _userPrefsBox = store.box<GospelOnboardingModel>(); // Using GospelOnboardingModel for user preferences
      _mapBox = store.box<MapInfo>();

      setState(() {
        // For user preferences, we'll need to fetch a specific entity or manage a single settings entity
        // For now, we'll assume a single settings entity with ID 1 for simplicity.
        // This might need a dedicated AppSettings model if more preferences are stored.
        GospelOnboardingModel? settings = _userPrefsBox.get(1);
        _selectedFont = settings?.homeSelectedFont ?? 'Roboto';
        _selectedFontSize = settings?.homeSelectedFontSize ?? 16.0;
        _isInitialized = true;
        _isLoading = false;
      });

      _updateDashboardData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening storage: $e')),
        );
      }
    }
  }

  /// Updates dashboard data from ObjectBox boxes with debouncing
  void _updateDashboardData() {
    if (!mounted || !_isInitialized) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _newPrayersCount = _prayerBox.query(Prayer_.status.equals('new')).build().count().toInt();
        _answeredPrayersCount = _prayerBox.query(Prayer_.status.equals('answered')).build().count().toInt();
        _unansweredPrayersCount = _prayerBox.query(Prayer_.status.equals('unanswered')).build().count().toInt();

        // For user preferences, we'll need to fetch a specific entity or manage a single settings entity
        GospelOnboardingModel? settings = _userPrefsBox.get(1);

        _lastRead = (settings?.lastSelectedBook != null && settings?.lastSelectedChapter != null)
            ? '${settings!.lastSelectedBook} ${settings.lastSelectedChapter}'
            : 'N/A';

        _lastStudied = (settings?.lastSelectedStudyBook != null && settings?.lastSelectedStudyChapter != null)
            ? '${settings!.lastSelectedStudyBook} ${settings.lastSelectedStudyChapter}'
            : 'N/A';

        _lastBookmark = settings?.lastBookmark ?? 'N/A';
        _lastFavorite = settings?.lastFavorite ?? 'N/A';
        _lastBibleNote = settings?.lastBibleNote ?? 'N/A';
        _lastPersonalNote = settings?.lastPersonalNote ?? 'N/A';
        _lastStudyNote = settings?.lastStudyNote ?? 'N/A';
        _lastSearch = settings?.lastSearch ?? 'N/A';
        _lastContact = settings?.lastContact ?? 'N/A';
        _currentMap = settings?.currentMap ?? 'N/A';

        _downloadedMapsCount = _mapBox.query(MapInfo_.isTemporary.equals(false)).build().count().toInt();
        _isLoading = false;
      });
    });
  }

  /// Calculates reading progress (example: based on Bible chapters)
  double _calculateReadingProgress() {
    const totalChapters = 1189; // Total Bible chapters
    GospelOnboardingModel? settings = _userPrefsBox.get(1);
    final readChapters = settings?.readChaptersCount ?? 0;
    return readChapters / totalChapters;
  }

  /// Calculates bookmark progress (example: based on bookmarks count)
  double _calculateBookmarkProgress() {
    const maxBookmarks = 100; // Hypothetical max
    GospelOnboardingModel? settings = _userPrefsBox.get(1);
    final bookmarkCount = settings?.bookmarkCount ?? 0;
    return bookmarkCount / maxBookmarks;
  }

  /// Calculates favorite progress (example: based on favorites count)
  double _calculateFavoriteProgress() {
    const maxFavorites = 50; // Hypothetical max
    GospelOnboardingModel? settings = _userPrefsBox.get(1);
    final favoriteCount = settings?.favoriteCount ?? 0;
    return favoriteCount / maxFavorites;
  }

  /// Calculates study progress (example: based on study chapters)
  double _calculateStudyProgress() {
    const totalStudyChapters = 1189; // Same as Bible chapters
    GospelOnboardingModel? settings = _userPrefsBox.get(1);
    final studiedChapters = settings?.studiedChaptersCount ?? 0;
    return studiedChapters / totalStudyChapters;
  }

  /// Calculates note progress (example: based on note count)
  double _calculateNoteProgress(String noteType) {
    const maxNotes = 100; // Hypothetical max
    GospelOnboardingModel? settings = _userPrefsBox.get(1);
    int noteCount = 0;
    if (noteType == 'bibleNote') {
      noteCount = settings?.bibleNoteCount ?? 0;
    } else if (noteType == 'personalNote') {
      noteCount = settings?.personalNoteCount ?? 0;
    } else if (noteType == 'studyNote') {
      noteCount = settings?.studyNoteCount ?? 0;
    }
    return noteCount / maxNotes;
  }

  /// Calculates search progress (example: based on search history)
  double _calculateSearchProgress() {
    const maxSearches = 50; // Hypothetical max
    GospelOnboardingModel? settings = _userPrefsBox.get(1);
    final searchCount = settings?.searchCount ?? 0;
    return searchCount / maxSearches;
  }

  /// Saves font and font size settings
  void _saveSettings(String font, double fontSize) {
    setState(() {
      _selectedFont = font;
      _selectedFontSize = fontSize;
    });
    GospelOnboardingModel? settings = _userPrefsBox.get(1);
    if (settings == null) {
      settings = GospelOnboardingModel(id: 1, onboardingComplete: false); // Assuming onboarding is false initially
    }
    settings.homeSelectedFont = font;
    settings.homeSelectedFontSize = fontSize;
    _userPrefsBox.put(settings);
  }

  /// Opens the settings page
  void _openSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeSettingsUi(
          onFontChanged: _saveSettings,
          initialFont: _selectedFont,
          initialFontSize: _selectedFontSize,
        ),
      ),
    );
  }

  /// Calculates responsive font size based on screen width
  double _getAdjustedFontSize(double baseSize) {
    final scale = MediaQuery.of(context).size.width / 360; // Base width
    return baseSize * scale.clamp(0.8, 1.2);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      _updateDashboardData();
    }
  }

  /// Builds the prayer summary bar chart
  Widget _buildPrayerChart() {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBarHeight = screenWidth * 0.3;
    final totalPrayers = _newPrayersCount + _answeredPrayersCount + _unansweredPrayersCount;
    final maxY = totalPrayers > 0 ? totalPrayers.toDouble() : 10.0;

    return Semantics(
      label: 'Prayer Summary Chart',
      child: InkWell(
        onTap: () {
          Provider.of<PageNotifier>(context, listen: false).setSelectedIndex(AppPages.pray.index);
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pie_chart, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Prayer Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: _selectedFont,
                            fontSize: _getAdjustedFontSize(_selectedFontSize * 0.9),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: maxBarHeight,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Theme.of(context).colorScheme.surfaceContainerHighest,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String label;
                            switch (group.x) {
                              case 0:
                                label = 'New: $_newPrayersCount';
                                break;
                              case 1:
                                label = 'Answered: $_answeredPrayersCount';
                                break;
                              case 2:
                                label = 'Unanswered: $_unansweredPrayersCount';
                                break;
                              default:
                                label = '';
                            }
                            return BarTooltipItem(
                              label,
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontFamily: _selectedFont,
                                    fontSize: _getAdjustedFontSize(_selectedFontSize * 0.8),
                                  ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const style = TextStyle(fontSize: 12);
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('New', style: style);
                                case 1:
                                  return const Text('Answered', style: style);
                                case 2:
                                  return const Text('Unanswered', style: style);
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: _newPrayersCount.toDouble(),
                              color: Theme.of(context).colorScheme.primary,
                              width: screenWidth * 0.2,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: _answeredPrayersCount.toDouble(),
                              color: Theme.of(context).colorScheme.secondary,
                              width: screenWidth * 0.2,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: _unansweredPrayersCount.toDouble(),
                              color: Theme.of(context).colorScheme.tertiary,
                              width: screenWidth * 0.2,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ],
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

  /// Builds a reusable circular progress indicator
  Widget _buildProgressIndicator(String title, String value, double progress, AppPages page) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Semantics(
      label: '$title Progress',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: () {
            Provider.of<PageNotifier>(context, listen: false).setSelectedIndex(page.index);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 4,
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      Text(
                        '${(progress.clamp(0.0, 1.0) * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: _selectedFont,
                              fontSize: _getAdjustedFontSize(_selectedFontSize * 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: _selectedFont,
                              fontSize: _getAdjustedFontSize(_selectedFontSize * 0.9),
                            ),
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: _selectedFont,
                              fontSize: _getAdjustedFontSize(_selectedFontSize * 0.8),
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
    );
  }

  /// Builds the map information card
  Widget _buildMapInfoCard(String title, String value, int downloadedMaps, AppPages page) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progress = (downloadedMaps / 10.0).clamp(0.0, 1.0);

    return Semantics(
      label: 'Map Information',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: () {
            Provider.of<PageNotifier>(context, listen: false).setSelectedIndex(page.index);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      Text(
                        '$downloadedMaps',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: _selectedFont,
                              fontSize: _getAdjustedFontSize(_selectedFontSize * 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: _selectedFont,
                              fontSize: _getAdjustedFontSize(_selectedFontSize * 0.9),
                            ),
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: _selectedFont,
                              fontSize: _getAdjustedFontSize(_selectedFontSize * 0.8),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Downloaded: $downloadedMaps',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: _selectedFont,
                              fontSize: _getAdjustedFontSize(_selectedFontSize * 0.8),
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
    );
  }

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
              leading: const Icon(Icons.info, size: 24),
              title: Text(
                'App Info',
                style: TextStyle(
                  fontFamily: _selectedFont,
                  fontSize: adjustedFontSize * 0.9,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeAppInfoUi()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support, size: 24),
              title: Text(
                'App Support',
                style: TextStyle(
                  fontFamily: _selectedFont,
                  fontSize: adjustedFontSize * 0.9,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeAppSupportUi()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, size: 24),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontFamily: _selectedFont,
                  fontSize: adjustedFontSize * 0.9,
                ),
              ),
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
          onRefresh: _openBoxes,
          child: _isInitialized && !_isLoading
              ? AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 500),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPrayerChart(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.book, color: Theme.of(context).colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Reading Progress',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontFamily: _selectedFont,
                                    fontSize: adjustedFontSize * 0.9,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildProgressIndicator(
                          'Last Read',
                          _lastRead,
                          _calculateReadingProgress(),
                          AppPages.read,
                        ),
                        const SizedBox(height: 8),
                        _buildProgressIndicator(
                          'Last Bookmark',
                          _lastBookmark,
                          _calculateBookmarkProgress(),
                          AppPages.read,
                        ),
                        const SizedBox(height: 8),
                        _buildProgressIndicator(
                          'Last Favorite',
                          _lastFavorite,
                          _calculateFavoriteProgress(),
                          AppPages.read,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.school, color: Theme.of(context).colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Study Progress',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontFamily: _selectedFont,
                                    fontSize: adjustedFontSize * 0.9,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildProgressIndicator(
                          'Last Studied',
                          _lastStudied,
                          _calculateStudyProgress(),
                          AppPages.study,
                        ),
                        const SizedBox(height: 8),
                        _buildProgressIndicator(
                          'Last Bible Note',
                          _lastBibleNote,
                          _calculateNoteProgress('bibleNote'),
                          AppPages.study,
                        ),
                        const SizedBox(height: 8),
                        _buildProgressIndicator(
                          'Last Personal Note',
                          _lastPersonalNote,
                          _calculateNoteProgress('personalNote'),
                          AppPages.study,
                        ),
                        const SizedBox(height: 8),
                        _buildProgressIndicator(
                          'Last Study Note',
                          _lastStudyNote,
                          _calculateNoteProgress('studyNote'),
                          AppPages.study,
                        ),
                        const SizedBox(height: 8),
                        _buildProgressIndicator(
                          'Last Search',
                          _lastSearch,
                          _calculateSearchProgress(),
                          AppPages.study,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.map, color: Theme.of(context).colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Map Information',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontFamily: _selectedFont,
                                    fontSize: adjustedFontSize * 0.9,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildMapInfoCard(
                          'Current Map',
                          _currentMap,
                          _downloadedMapsCount,
                          AppPages.gospel,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.contacts, color: Theme.of(context).colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Last Contact',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontFamily: _selectedFont,
                                    fontSize: adjustedFontSize * 0.9,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          label: 'Last Contact',
                          child: InkWell(
                            onTap: () {
                              Provider.of<PageNotifier>(context, listen: false)
                                  .setSelectedIndex(AppPages.gospel.index);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _lastContact,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontFamily: _selectedFont,
                                              fontSize: adjustedFontSize * 0.8,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}