import 'providers/page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'ui/home_page_ui.dart';
import 'ui/gospel_page_ui.dart';
import 'ui/pray_page_ui.dart';
import 'ui/read_page_ui.dart';
import 'ui/study_page_ui.dart';
import 'models/pray_model.dart';
import 'models/gospel_map_entry_data_model.dart';
import 'models/gospel_map_sub_directory_model.dart';
import 'models/gospel_map_directory_model.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'providers/theme_notifier.dart';
import 'package:onboarding/onboarding.dart'; // Import onboarding package
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'adapters/gospel_map_directory_adapter.dart';
import 'adapters/gospel_map_entry_adapter.dart';
import 'adapters/gospel_map_sub_directory_adapter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PrayerAdapter());
  Hive.registerAdapter(MapInfoAdapter()); // Register MapInfoAdapter
  Hive.registerAdapter(GospelMapEntryAdapter());
  Hive.registerAdapter(GospelMapSubDirectoryAdapter());
  Hive.registerAdapter(GospelMapDirectoryAdapter());
  await Hive.openBox<Prayer>('prayers'); // For Prayer model
  final themeBox = await Hive.openBox('themeBox'); // For theme persistence
  await Hive.openBox('userPreferences'); // For ReadPage book and chapter persistence

  // Clear Hive data for a clean start
  await Hive.box<Prayer>('prayers').clear();
  await Hive.box('themeBox').clear();
  await Hive.box('userPreferences').clear();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(themeBox)),
        ChangeNotifierProvider(create: (_) => PageNotifier()), // Add PageNotifier
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final userPreferencesBox = Hive.box('userPreferences');
    final bool onboardingComplete = userPreferencesBox.get('onboardingComplete') ?? false;

    return MaterialApp(
      title: 'By Faith App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
      ),
      themeMode: themeNotifier.themeMode,
      home: onboardingComplete ? const RootPage() : OnboardingScreen(), // Show OnboardingScreen if not complete
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  // Public method to navigate to a specific page
  void navigateToPage(BuildContext context, int index) {
    // Find the state object and call its private method
    context.findAncestorStateOfType<_RootPageState>()?._onItemTapped(index);
  }

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  // Listen to PageNotifier for index changes
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomePageUi(),
    GospelPageUi(),
    PrayPageUi(),
    ReadPageUi(),
    StudyPageUi(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update selected index when PageNotifier changes
    _selectedIndex = Provider.of<PageNotifier>(context).selectedIndex;
  }

  void _onItemTapped(int index) {
    // Update PageNotifier, which will trigger didChangeDependencies
    Provider.of<PageNotifier>(context, listen: false).setSelectedIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Gospel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.folded_hands),
            label: 'Pray',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Read',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Study',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Placeholder Onboarding Screen
class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is the Onboarding Screen'),
            ElevatedButton(
              onPressed: () {
                // Mark onboarding as complete and navigate to RootPage
                Hive.box('userPreferences').put('onboardingComplete', true);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const RootPage()),
                );
              },
              child: Text('Skip Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}