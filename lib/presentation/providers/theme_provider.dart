import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;
  
  // Constructor loads saved theme on initialization
  ThemeProvider() {
    _loadThemePreference();
  }

  // Load saved theme from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeString = prefs.getString('themeMode');
      
      if (savedThemeString != null) {
        // Convert string back to ThemeMode enum
        if (savedThemeString == 'ThemeMode.light') {
          _themeMode = ThemeMode.light;
        } else if (savedThemeString == 'ThemeMode.dark') {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
        notifyListeners();
      }
    } catch (e) {
      // Default to system if there's an error
      _themeMode = ThemeMode.system;
    }
  }

  // Update and save theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
    
    // Notify listeners to rebuild UI
    notifyListeners();
  }
}