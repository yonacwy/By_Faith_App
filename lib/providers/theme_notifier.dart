import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:by_faith_app/database/database.dart'; // Import Drift database

class ThemeNotifier extends ChangeNotifier {
  final AppDatabase _database;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier(this._database) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final settings = await _database.getSettings();
    if (settings != null && settings.selectedStudyFont != null) { // Reusing a setting field for theme for now
       _themeMode = settings.selectedStudyFont == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _database.updateThemeSetting(_themeMode == ThemeMode.dark ? 'dark' : 'light'); // Need to implement this method in database.dart
    notifyListeners();
  }
}