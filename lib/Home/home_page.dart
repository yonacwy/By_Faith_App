import '../providers/page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/prayer.dart';
import '../models/map_entry_data.dart';
import '../models/directory.dart';
import '../models/sub_directory.dart';
import 'package:by_faith_app/Gospel/gospel_page.dart';
import 'package:provider/provider.dart';
import 'package:by_faith_app/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<Prayer> _prayerBox;
  late Box _userPrefsBox;
  late Box<MapInfo> _mapBox;

  int _newPrayersCount = 0;
  int _answeredPrayersCount = 0;
  int _unansweredPrayersCount = 0;
  String _lastRead = 'N/A';
  String _lastStudied = 'N/A';
  int _downloadedMapsCount = 0;

  bool _isInitialized = false; // Track initialization status

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  Future<void> _openBoxes() async {
    _prayerBox = await Hive.openBox<Prayer>('prayers');
    _userPrefsBox = await Hive.openBox('userPreferences');
    _mapBox = await Hive.openBox<MapInfo>('maps');

    // Mark initialization as complete
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }

    // Add listeners after boxes are opened
    _prayerBox.listenable().addListener(_updateDashboardData);
    _userPrefsBox.listenable().addListener(_updateDashboardData);
    _mapBox.listenable().addListener(_updateDashboardData);

    // Update dashboard data after boxes are opened
    _updateDashboardData();
  }

  void _updateDashboardData() {
    if (!mounted || !_isInitialized) return; // Prevent updates before initialization or if disposed

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

  @override
  void dispose() {
    // Remove listeners when the widget is disposed
    if (_isInitialized) {
      _prayerBox.listenable().removeListener(_updateDashboardData);
      _userPrefsBox.listenable().removeListener(_updateDashboardData);
      _mapBox.listenable().removeListener(_updateDashboardData);
    }
    // Do NOT close boxes here, they are managed in main.dart
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update dashboard data only if initialized
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
                              Text('New Prayers: $_newPrayersCount', style: Theme.of(context).textTheme.bodyLarge),
                              const SizedBox(height: 4),
                              Text('Answered Prayers: $_answeredPrayersCount', style: Theme.of(context).textTheme.bodyLarge),
                              const SizedBox(height: 4),
                              Text('Unanswered Prayers: $_unansweredPrayersCount', style: Theme.of(context).textTheme.bodyLarge),
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
                        trailing: Text(_lastRead, style: Theme.of(context).textTheme.bodyLarge),
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
                        trailing: Text(_lastStudied, style: Theme.of(context).textTheme.bodyLarge),
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
                        trailing: Text('$_downloadedMapsCount', style: Theme.of(context).textTheme.bodyLarge),
                        onTap: () {
                          Provider.of<PageNotifier>(context, listen: false).setSelectedIndex(1);
                        },
                      ),
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()), // Show loading indicator until initialized
      ),
    );
  }
}