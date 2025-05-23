import '../providers/page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pray_model.dart';
import '../models/gospel_map_entry_data_model.dart';
import '../models/gospel_map_directory_model.dart';
import '../models/gospel_map_sub_directory_model.dart';
import 'package:by_faith_app/ui/gospel_page_ui.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart'; // Add this for theme switching

class HomePageUi extends StatefulWidget {
  HomePageUi({Key? key}) : super(key: key);

  @override
  _HomePageUiState createState() => _HomePageUiState();
}

class _HomePageUiState extends State<HomePageUi> {
  late Box<Prayer> _prayerBox;
  late Box _userPrefsBox;
  late Box<MapInfo> _mapBox;

  int _newPrayersCount = 0;
  int _answeredPrayersCount = 0;
  int _unansweredPrayersCount = 0;
  String _lastRead = 'N/A';
  String _lastStudied = 'N/A';
  int _downloadedMapsCount = 0;
  String _selectedFont = 'Roboto'; // Add font setting
  double _selectedFontSize = 16.0; // Add font size setting

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  Future<void> _openBoxes() async {
    _prayerBox = await Hive.openBox<Prayer>('prayers');
    _userPrefsBox = await Hive.openBox('userPreferences');
    _mapBox = await Hive.openBox<MapInfo>('maps');

    // Load saved font settings
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

      _downloadedMapsCount = _mapBox.values.where((map) => !map.isTemporary).length;
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
        builder: (context) => _SettingsPage(
          onFontChanged: _saveSettings,
          initialFont: _selectedFont,
          initialFontSize: _selectedFontSize,
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _prayerBox.listenable().removeListener(_updateDashboardData);
      _userPrefsBox.listenable().removeListener(_updateDashboardData);
      _mapBox.listenable().removeListener(_updateDashboardData);
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      _updateDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettingsPage,
            tooltip: 'Settings',
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
      drawer: Drawer(
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
              leading: const Icon(Icons.support),
              title: const Text('App Support'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App Support not implemented yet')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('App Info'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'By Faith App',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 By Faith App',
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isInitialized
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prayer Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: _selectedFont,
                            fontSize: _selectedFontSize,
                          ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        Provider.of<PageNotifier>(context, listen: false).setSelectedIndex(2);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Prayers: $_newPrayersCount',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: _selectedFont,
                                      fontSize: _selectedFontSize,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Answered Prayers: $_answeredPrayersCount',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: _selectedFont,
                                      fontSize: _selectedFontSize,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unanswered Prayers: $_unansweredPrayersCount',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: _selectedFont,
                                      fontSize: _selectedFontSize,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reading Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: _selectedFont,
                            fontSize: _selectedFontSize,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: ListTile(
                        title: const Text('Last Read:'),
                        trailing: Text(
                          _lastRead,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontFamily: _selectedFont,
                                fontSize: _selectedFontSize,
                              ),
                        ),
                        onTap: () {
                          Provider.of<PageNotifier>(context, listen: false).setSelectedIndex(3);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Study Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: _selectedFont,
                            fontSize: _selectedFontSize,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: ListTile(
                        title: const Text('Last Studied:'),
                        trailing: Text(
                          _lastStudied,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontFamily: _selectedFont,
                                fontSize: _selectedFontSize,
                              ),
                        ),
                        onTap: () {
                          Provider.of<PageNotifier>(context, listen: false).setSelectedIndex(4);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gospel Maps',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: _selectedFont,
                            fontSize: _selectedFontSize,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: ListTile(
                        title: const Text('Downloaded Maps:'),
                        trailing: Text(
                          '$_downloadedMapsCount',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontFamily: _selectedFont,
                                fontSize: _selectedFontSize,
                              ),
                        ),
                        onTap: () {
                          Provider.of<PageNotifier>(context, listen: false).setSelectedIndex(1);
                        },
                      ),
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SettingsPage extends StatefulWidget {
  final Function(String, double) onFontChanged;
  final String initialFont;
  final double initialFontSize;

  const _SettingsPage({
    required this.onFontChanged,
    required this.initialFont,
    required this.initialFontSize,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  late String currentFont;
  late double currentFontSize;

  @override
  void initState() {
    super.initState();
    currentFont = widget.initialFont;
    currentFontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> fontOptions = [
      'Roboto',
      'Times New Roman',
      'Open Sans',
      'Lora',
    ];
    const String sampleText = "This is a sample dashboard text.";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    title: const Text('Theme'),
                    trailing: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (value) {
                        Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                      },
                    ),
                    subtitle: Text(
                      Theme.of(context).brightness == Brightness.light ? 'Light Mode' : 'Dark Mode',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Text Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Font Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        DropdownButton<String>(
                          value: currentFont,
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          underline: const SizedBox(),
                          items: fontOptions.map((font) {
                            return DropdownMenuItem<String>(
                              value: font,
                              child: Text(
                                font,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                currentFont = value;
                                widget.onFontChanged(currentFont, currentFontSize);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Font Size',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Slider(
                          value: currentFontSize,
                          min: 12.0,
                          max: 24.0,
                          divisions: 24,
                          label: currentFontSize.toStringAsFixed(1),
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveColor: Theme.of(context).colorScheme.outlineVariant,
                          onChanged: (value) {
                            setState(() {
                              currentFontSize = value;
                              widget.onFontChanged(currentFont, currentFontSize);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Text Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      sampleText,
                      style: TextStyle(
                        fontSize: currentFontSize,
                        fontFamily: currentFont,
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.justify,
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