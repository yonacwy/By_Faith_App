import 'package:flutter/material.dart';
import 'package:by_faith_app/objectbox.dart';
import 'package:by_faith_app/models/user_preferences.dart';

class PageNotifier with ChangeNotifier {
  final ObjectBox _objectbox;
  late UserPreference _userPreference;
  int _selectedIndex = 0;

  PageNotifier(this._objectbox) {
    _userPreference = _objectbox.userPreferenceBox.get(1) ?? UserPreference();
    _selectedIndex = _userPreference.lastPageIndex;
  }

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      _userPreference.lastPageIndex = index;
      _objectbox.userPreferenceBox.put(_userPreference);
      notifyListeners();
    }
  }
}