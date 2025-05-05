import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends ChangeNotifier {
  final Box _themeBox;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier(this._themeBox) {
    final savedTheme = _themeBox.get('themeMode');
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _themeBox.put('themeMode', _themeMode.toString());
    notifyListeners();
  }
}