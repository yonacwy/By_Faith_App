import 'package:flutter/material.dart';
import 'package:by_faith_app/objectbox.dart';
import 'package:by_faith_app/models/user_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  final ObjectBox _objectbox;
  late UserPreference _userPreference;

  ThemeNotifier(this._objectbox) {
    _userPreference = _objectbox.userPreferenceBox.get(1) ?? UserPreference();
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString().split('.').last == _userPreference.themeMode,
      orElse: () => ThemeMode.system,
    );
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _userPreference.themeMode = _themeMode.toString().split('.').last;
    _objectbox.userPreferenceBox.put(_userPreference);
    notifyListeners();
  }
}