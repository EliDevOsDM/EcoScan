import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeMode();
    notifyListeners();
  }
  
  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    _saveThemeMode();
    notifyListeners();
  }
  
  String get themeModeString {
    return _isDarkMode ? 'Oscuro' : 'Claro';
  }
  
  IconData get themeModeIcon {
    return _isDarkMode ? Icons.dark_mode : Icons.light_mode;
  }
  
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
  
  void _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }
} 