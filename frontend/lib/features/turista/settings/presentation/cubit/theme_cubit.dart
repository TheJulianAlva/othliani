import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences sharedPreferences;

  ThemeCubit({required this.sharedPreferences}) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = sharedPreferences.getBool('isDarkMode');
    if (isDark != null) {
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    }
  }

  Future<void> setTheme(bool isDark) async {
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
    await sharedPreferences.setBool('isDarkMode', isDark);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
