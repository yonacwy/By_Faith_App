import 'package:by_faith_app/models/gospel_map_info_model.dart';
import '../providers/page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  late Box _userPrefsBox;
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
    // Remove listeners only if initialized
    if (_isInitialized) {
      _prayerBox.listenable().removeListener(_updateDashboardData);
      _userPrefsBox.listenable().removeListener(_updateDashboardData);
      _mapBox.listenable().removeListener(_updateDashboardData);
    }
    _pageNotifier?.removeListener(_onPageNotifierChanged);
    super.dispose();
  }

  /// Handles page change events from PageNotifier
  void _onPageNotifierChanged() {
    if (_pageNotifier?.selectedIndex == AppPages.home.index) {
      _updateDashboardData();
    }
  }

  /// Opens Hive boxes and sets up listeners
  Future<void> _openBoxes() async {
    try {
      // Remove existing listeners if initialized
      if (_isInitialized) {
        _prayerBox.listenable().removeListener(_updateDashboardData);
        _userPrefsBox.listenable().removeListener(_updateDashboardData);
        _mapBox.listenable().removeListener(_updateDashboardData);
      }

      _isInitialized = false;
      setState(() => _isLoading = true);

      _prayerBox = await Hive.openBox<Prayer>('prayers');
      _userPrefsBox = await Hive.openBox('userPreferences');
      _mapBox = await Hive.openBox<MapInfo>('maps');

      setState(() {
        _selectedFont = _userPrefsBox.get('homeSelectedFont') ?? 'Roboto';
        _selectedFontSize = _userPrefsBox.get('homeSelectedFontSize') ?? 16.0;
        _isInitialized = true;
        _isLoading = false;
      });

      // Add listeners to boxes
      _prayerBox.listenable().addListener(_updateDashboardData);
      _userPrefsBox.listenable().addListener(_updateDashboardData);
      _mapBox.listenable().addListener(_updateDashboardData);

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

  /// Updates dashboard data from Hive boxes with debouncing
  void _updateDashboardData() {
    if (!mounted || !_isInitialized) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_prayerBox.isOpen || !_userPrefsBox.isOpen || !_mapBox.isOpen) {
        _openBoxes();
        return;
      }

      setState(() {
        _isLoading = true;
        _newPrayersCount = _prayerBox.values.where((p) => p.status == 'new').length;
        _answeredPrayersCount = _prayerBox.values.where((p) => p.status == 'answered').length;
        _unansweredPrayersCount = _prayerBox.values.where((p) => p.status == 'unanswered').length;

        final lastReadBook = _userPrefsBox.get('lastSelectedBook');
        final lastReadChapter = _userPrefsBox.get('lastSelectedChapter');
        _lastRead = (lastReadBook != null && lastReadChapter != null)
            ? '$lastReadBook $lastReadChapter'
            : 'N/A';

        final lastStudiedBook = _userPrefsBox.get('lastSelectedStudyBook');
        final lastStudiedChapter = _userPrefsBox.get('lastSelectedStudyChapter');
        _lastStudied = (lastStudiedBook != null && lastStudiedChapter != null)
            ? '$lastStudiedBook $lastStudiedChapter'
            : 'N/A';

        _lastBookmark = _userPrefsBox.get('lastBookmark') ?? 'N/A';
        _lastFavorite = _userPrefsBox.get('lastFavorite') ?? 'N/A';
        _lastBibleNote = _userPrefsBox.get('lastBibleNote') ?? 'N/A';
        _lastPersonalNote = _userPrefsBox.get('lastPersonalNote') ?? 'N/A';
        _lastStudyNote = _userPrefsBox.get('lastStudyNote') ?? 'N/A';
        _lastSearch = _userPrefsBox.get('lastSearch') ?? 'N/A';
        _lastContact = _userPrefsBox.get('lastContact') ?? 'N/A';
        _currentMap = _userPrefsBox.get('currentMap') ?? 'N/A';

        _downloadedMapsCount = _mapBox.values.where((map) => map is MapInfo && !map.isTemporary).length;
        _isLoading = false;
      });
    });
  }

  /// Calculates reading progress (example: based on Bible chapters)
  double _calculateReadingProgress() {
    const totalChapters = 1189; // Total Bible chapters
    final readChapters = _userPrefsBox.get('readChaptersCount', defaultValue: 0);
    return readChapters / totalChapters;
  }

  /// Calculates bookmark progress (example: based on bookmarks count)
  double _calculateBookmarkProgress() {
    const maxBookmarks = 100; // Hypothetical max
    final bookmarkCount = _userPrefsBox.get('bookmarkCount', defaultValue: 0);
    return bookmarkCount / maxBookmarks;
  }

  /// Calculates favorite progress (example: based on favorites count)
  double _calculateFavoriteProgress() {
    const maxFavorites = 50; // Hypothetical max
    final favoriteCount = _userPrefsBox.get('favoriteCount', defaultValue: 0);
    return favoriteCount / maxFavorites;
  }

  /// Calculates study progress (example: based on study chapters)
  double _calculateStudyProgress() {
    const totalStudyChapters = 1189; // Same as Bible chapters
    final studiedChapters = _userPrefsBox.get('studiedChaptersCount', defaultValue: 0);
    return studiedChapters / totalStudyChapters;
  }

  /// Calculates note progress (example: based on note count)
  double _calculateNoteProgress(String noteType) {
    const maxNotes = 100; // Hypothetical max
    final noteCount = _userPrefsBox.get('${noteType}Count', defaultValue: 0);
    return noteCount / maxNotes;
  }

  /// Calculates search progress (example: based on search history)
  double _calculateSearchProgress() {
    const maxSearches = 50; // Hypothetical max
    final searchCount = _userPrefsBox.get('searchCount', defaultValue: 0);
    return searchCount / maxSearches;
  }

  /// Saves font and font size settings
  void _saveSettings(String font, double fontSize) {
    setState(() {
      _selectedFont = font;
      _selectedFontSize = fontSize;
    });
    _userPrefsBox.put('homeSelectedFont', font);
    _userPrefsBox.put('homeSelectedFontSize', fontSize);
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
                          tooltipRoundedRadius: 8,
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
              fontSize: adjustedFontSize,
            ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
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
                      fontFamily: _selectedFont,
                      fontSize: adjustedFontSize,
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