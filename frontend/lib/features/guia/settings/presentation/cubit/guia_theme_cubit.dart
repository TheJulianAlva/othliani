import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit que gestiona el tema (claro/oscuro) de la app Guía.
///
/// Emite [ThemeMode] como estado y persiste la preferencia
/// en SharedPreferences con la clave 'darkMode'.
class GuiaThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences sharedPreferences;

  GuiaThemeCubit({required this.sharedPreferences}) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = sharedPreferences.getBool('darkMode');
    if (isDark != null) {
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    }
  }

  Future<void> setTheme(bool isDark) async {
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
    await sharedPreferences.setBool('darkMode', isDark);
  }

  Future<void> toggleTheme() async {
    final newIsDark = !isDarkMode;
    await setTheme(newIsDark);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
