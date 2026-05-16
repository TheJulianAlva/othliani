import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit que gestiona el idioma de la app Guía.
///
/// Emite [Locale] como estado y persiste el código de idioma
/// en SharedPreferences con la clave 'languageCode'.
class GuiaLocaleCubit extends Cubit<Locale> {
  final SharedPreferences sharedPreferences;

  GuiaLocaleCubit({required this.sharedPreferences})
      : super(const Locale('es')) {
    _loadLocale();
  }

  void _loadLocale() {
    final languageCode = sharedPreferences.getString('languageCode');
    if (languageCode != null) {
      emit(Locale(languageCode));
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != state.languageCode) {
      emit(locale);
      await sharedPreferences.setString('languageCode', locale.languageCode);
    }
  }
}
