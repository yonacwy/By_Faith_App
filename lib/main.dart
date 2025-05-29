import 'package:by_faith_app/adapters/gospel_map_entry_adapter.dart';
import 'package:by_faith_app/models/gospel_contacts_model.dart';
import 'package:by_faith_app/models/gospel_map_directory_model.dart';
import 'package:by_faith_app/models/gospel_map_entry_data_model.dart';
import 'package:by_faith_app/models/gospel_map_info_model.dart';
import 'package:by_faith_app/models/gospel_map_sub_directory_model.dart';
import 'package:by_faith_app/models/pray_model.dart';
import 'package:by_faith_app/providers/page_notifier.dart';
import 'package:by_faith_app/providers/theme_notifier.dart';
import 'package:by_faith_app/ui/gospel_map_manager_ui.dart';
import 'package:by_faith_app/ui/gospel_page_ui.dart';
import 'package:by_faith_app/ui/home_page_ui.dart';
import 'package:by_faith_app/ui/pray_page_ui.dart';
import 'package:by_faith_app/ui/read_page_ui.dart';
import 'package:by_faith_app/ui/study_page_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:path_provider/path_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboarding/onboarding.dart';
import 'package:by_faith_app/models/gospel_profile_model.dart';
import 'package:by_faith_app/ui/gospel_onboarding_ui.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FMTCObjectBoxBackend().initialise();
  await Hive.initFlutter();


  // Register Hive adapters
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(PrayerAdapter());
  Hive.registerAdapter(MapInfoAdapter());
  Hive.registerAdapter(GospelMapEntryDataAdapter());
  Hive.registerAdapter(GospelProfileAdapter());

  // Open Hive boxes
  final themeBox = await Hive.openBox('themeBox'); // For theme persistence
  await Hive.openBox<Prayer>('prayers'); // For Prayer model
  await Hive.openBox('userPreferences'); // For ReadPage book and chapter
  await Hive.openBox<MapInfo>('maps'); // For maps
  await Hive.openBox<GospelProfile>('userProfileBox'); // For user profile
  // Contacts box is opened in GospelPageUi._initHive

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(themeBox)),
        ChangeNotifierProvider(create: (_) => PageNotifier()),
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
    final userProfileBox = Hive.box<GospelProfile>('userProfileBox');
    final bool profileExists = userProfileBox.get('currentProfile') != null;

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
      home: profileExists ? const RootPage() : const GospelOnboardingUI(),
      routes: {
        '/home': (context) => const RootPage(),
      },
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  void navigateToPage(BuildContext context, int index) {
    context.findAncestorStateOfType<_RootPageState>()?._onItemTapped(index);
  }

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomePageUi(),
    const GospelPageUi(),
    PrayPageUi(),
    ReadPageUi(),
    StudyPageUi(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedIndex = Provider.of<PageNotifier>(context).selectedIndex;
  }

  void _onItemTapped(int index) {
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