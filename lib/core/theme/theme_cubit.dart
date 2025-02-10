import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadThemeMode(_prefs));

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final String? themeStr = prefs.getString(_themeKey);
    return themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _prefs.setString(_themeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
    emit(newMode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
