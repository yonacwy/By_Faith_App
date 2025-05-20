import 'providers/page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'Home/home_page.dart';
import 'Gospel/gospel_page.dart';
import 'Pray/pray_page.dart';
import 'Read/read_page.dart';
import 'Study/study_page.dart';
import 'models/prayer.dart';
import 'models/map_entry_data.dart';
import 'models/sub_directory.dart';
import 'models/directory.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'providers/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PrayerAdapter());
  Hive.registerAdapter(MapInfoAdapter()); // Register MapInfoAdapter
  Hive.registerAdapter(MapEntryDataAdapter());
  Hive.registerAdapter(SubDirectoryAdapter());
  Hive.registerAdapter(DirectoryAdapter());
  await Hive.openBox<Prayer>('prayers'); // For Prayer model
  final themeBox = await Hive.openBox('themeBox'); // For theme persistence
  await Hive.openBox('userPreferences'); // For ReadPage book and chapter persistence
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
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'By Faith App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
          ),
          themeMode: themeNotifier.themeMode,
          home: const RootPage(),
        );
      },
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
    HomePage(),
    GospelPage(),
    PrayPage(),
    ReadPage(),
    StudyPage(),
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