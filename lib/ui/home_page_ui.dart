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

class HomePageUi extends StatefulWidget {
  HomePageUi({Key? key}) : super(key: key);

  @override
  _HomePageUiState createState() => _HomePageUiState();
}

class _HomePageUiState extends State<HomePageUi> {
  late Box<Prayer> _prayerBox;
  late Box _userPrefsBox;
  late Box<MapInfo> _mapBox;
  PageNotifier? _pageNotifier; // Declare PageNotifier instance

  int _newPrayersCount = 0;
  int _answeredPrayersCount = 0;
  int _unansweredPrayersCount = 0;
  String _lastRead = 'N/A';
  String _lastBookmark = 'N/A';
  String _lastFavorite = 'N/A';
  String _lastStudied = 'N/A';
  String _lastNote = 'N/A';
  String _lastSearch = 'N/A';
  String _lastContact = 'N/A';
  String _currentMap = 'N/A';
  int _downloadedMapsCount = 0;
  String _selectedFont = 'Roboto';
  double _selectedFontSize = 16.0;

  bool _isInitialized = false;
  double _opacity = 0.0; // For fade-in animation

  @override
  void initState() {
    super.initState();
    _openBoxes();
    // Store PageNotifier instance and add listener to update dashboard when returning to Home page
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
    // Remove listeners before super.dispose()
    if (_isInitialized) {
      _prayerBox.listenable().removeListener(_updateDashboardData);
      _userPrefsBox.listenable().removeListener(_updateDashboardData);
      _mapBox.listenable().removeListener(_updateDashboardData);
    }
    // Remove listener for PageNotifier using the stored instance
    _pageNotifier?.removeListener(_onPageNotifierChanged);
    super.dispose();
  }

  void _onPageNotifierChanged() {
    // Check if the currently selected page is the Home page (assuming index 0)
    if (_pageNotifier?.selectedIndex == 0) {
      _updateDashboardData();
    }
  }

  Future<void> _openBoxes() async {
    _prayerBox = await Hive.openBox<Prayer>('prayers');
    _userPrefsBox = await Hive.openBox('userPreferences');
    _mapBox = await Hive.openBox<MapInfo>('maps');

    setState(() {
      _selectedFont = _userPrefsBox.get('homeSelectedFont') ?? 'Roboto';
      _selectedFontSize = _userPrefsBox.get('homeSelectedFontSize') ?? 16.0;
      _isInitialized = true;
    });

    _prayerBox.listenable().addListener(_updateDashboardData);
    _userPrefsBox.listenable().addListener(_updateDashboardData);
    _mapBox.listenable().addListener(_updateDashboardData);

    _updateDashboardData();
  }

  void _updateDashboardData() {
    if (!mounted || !_isInitialized) return;

    print('[_updateDashboardData] called'); // Debug print

    setState(() {
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
      _lastNote = _userPrefsBox.get('lastNote') ?? 'N/A';
      _lastSearch = _userPrefsBox.get('lastSearch') ?? 'N/A';
      _lastContact = _userPrefsBox.get('lastContact') ?? 'N/A';
      _currentMap = _userPrefsBox.get('currentMap') ?? 'N/A';

      print('[_updateDashboardData] Retrieved _lastBookmark: $_lastBookmark'); // Debug print
      print('[_updateDashboardData] Retrieved _lastStudied: $_lastStudied'); // Debug print
      print('[_updateDashboardData] Retrieved _lastNote: $_lastNote'); // Debug print
      print('[_updateDashboardData] Retrieved _currentMap: $_currentMap'); // Debug print

      _downloadedMapsCount = _mapBox.values.where((map) => map is MapInfo && !map.isTemporary).length;
    });
  }

  void _saveSettings(String font, double fontSize) {
    setState(() {
      _selectedFont = font;
      _selectedFontSize = fontSize;
    });
    _userPrefsBox.put('homeSelectedFont', font);
    _userPrefsBox.put('homeSelectedFontSize', fontSize);
  }

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      _updateDashboardData();
    }
  }

  // Bar chart for prayer summary
  Widget _buildPrayerChart() {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBarHeight = screenWidth * 0.3; // Responsive height for small screens
    final totalPrayers = _newPrayersCount + _answeredPrayersCount + _unansweredPrayersCount;
    final maxY = totalPrayers > 0 ? totalPrayers.toDouble() : 10.0; // Avoid zero division

    return Card(
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
                        fontSize: _selectedFontSize * 0.9,
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
                                fontSize: _selectedFontSize * 0.8,
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
    );
  }

  // Circular progress indicator for reading/study progress
  Widget _buildProgressIndicator(String title, String value, double progress, int pageIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          Provider.of<PageNotifier>(context, listen: false).setSelectedIndex(pageIndex);
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
                      value: progress,
                      strokeWidth: 4,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: _selectedFont,
                            fontSize: _selectedFontSize * 0.7,
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
                            fontSize: _selectedFontSize * 0.9,
                          ),
                    ),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: _selectedFont,
                            fontSize: _selectedFontSize * 0.8,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final adjustedFontSize = _selectedFontSize * (screenWidth < 360 ? 0.9 : 1.0); // Adjust for small screens

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
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
                      fontSize: adjustedFontSize,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info, size: 24),
              title: Text('App Info', style: TextStyle(fontSize: adjustedFontSize * 0.9)),
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
              title: Text('App Support', style: TextStyle(fontSize: adjustedFontSize * 0.9)),
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
              title: Text('Settings', style: TextStyle(fontSize: adjustedFontSize * 0.9)),
              onTap: () {
                Navigator.pop(context);
                _openSettingsPage();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isInitialized
            ? AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 500),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.04),
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
                        0.6,
                        3,
                      ),
                      const SizedBox(height: 8),
                      _buildProgressIndicator(
                        'Last Bookmark',
                        _lastBookmark,
                        0.4,
                        3,
                      ),
                      const SizedBox(height: 8),
                      _buildProgressIndicator(
                        'Last Favorite',
                        _lastFavorite,
                        0.5,
                        3,
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
                        0.7,
                        4,
                      ),
                      const SizedBox(height: 8),
                      _buildProgressIndicator(
                        'Last Note',
                        _lastNote,
                        0.3,
                        4,
                      ),
                      const SizedBox(height: 8),
                      _buildProgressIndicator(
                        'Last Search',
                        _lastSearch,
                        0.2,
                        4,
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
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Map',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: _selectedFont,
                                      fontSize: adjustedFontSize * 0.9,
                                    ),
                              ),
                              Text(
                                _currentMap,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: _selectedFont,
                                      fontSize: adjustedFontSize * 0.8,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Downloaded Maps',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: _selectedFont,
                                      fontSize: adjustedFontSize * 0.9,
                                    ),
                              ),
                              Text(
                                '$_downloadedMapsCount',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: _selectedFont,
                                      fontSize: adjustedFontSize * 0.8,
                                    ),
                              ),
                            ],
                          ),
                        ),
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
                      Card(
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
                    ],
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}