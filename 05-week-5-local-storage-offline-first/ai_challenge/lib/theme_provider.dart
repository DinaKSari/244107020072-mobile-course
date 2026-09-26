import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  bool _isDarkMode;

  ThemeProvider(this.prefs) : _isDarkMode = prefs.getBool('isDark') ?? false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    prefs.setBool('isDark', _isDarkMode); // Simpan preferensi secara offline
    notifyListeners();
  }
}