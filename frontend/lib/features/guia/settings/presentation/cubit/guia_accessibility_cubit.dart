import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Opciones de tamaño de fuente ────────────────────────────────────────────
enum GuiaFontSizeOption { small, medium, large, extraLarge }

// ─── Estado inmutable ────────────────────────────────────────────────────────
class GuiaAccessibilityState extends Equatable {
  final GuiaFontSizeOption fontSize;
  final bool highContrast;
  final bool screenReader;
  final bool reduceAnimations;
  final bool hapticFeedback;

  const GuiaAccessibilityState({
    this.fontSize = GuiaFontSizeOption.medium,
    this.highContrast = false,
    this.screenReader = false,
    this.reduceAnimations = false,
    this.hapticFeedback = true,
  });

  /// Escala de texto que se aplica a MediaQuery.textScaler
  double get fontScale {
    switch (fontSize) {
      case GuiaFontSizeOption.small:
        return 0.85;
      case GuiaFontSizeOption.medium:
        return 1.0;
      case GuiaFontSizeOption.large:
        return 1.15;
      case GuiaFontSizeOption.extraLarge:
        return 1.3;
    }
  }

  GuiaAccessibilityState copyWith({
    GuiaFontSizeOption? fontSize,
    bool? highContrast,
    bool? screenReader,
    bool? reduceAnimations,
    bool? hapticFeedback,
  }) {
    return GuiaAccessibilityState(
      fontSize: fontSize ?? this.fontSize,
      highContrast: highContrast ?? this.highContrast,
      screenReader: screenReader ?? this.screenReader,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }

  @override
  List<Object?> get props => [
        fontSize,
        highContrast,
        screenReader,
        reduceAnimations,
        hapticFeedback,
      ];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

/// Cubit que gestiona las preferencias de accesibilidad de la app Guía.
///
/// A diferencia del AccessibilityCubit de Turista, este **persiste** todas
/// las preferencias en SharedPreferences (mismas claves que el antiguo
/// AccessibilityProvider para compatibilidad).
class GuiaAccessibilityCubit extends Cubit<GuiaAccessibilityState> {
  final SharedPreferences sharedPreferences;

  GuiaAccessibilityCubit({required this.sharedPreferences})
      : super(const GuiaAccessibilityState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final fontSizeIndex = sharedPreferences.getInt('fontSize') ?? 1;
    final validIndex = fontSizeIndex.clamp(0, GuiaFontSizeOption.values.length - 1);

    emit(GuiaAccessibilityState(
      fontSize: GuiaFontSizeOption.values[validIndex],
      highContrast: sharedPreferences.getBool('highContrast') ?? false,
      screenReader: sharedPreferences.getBool('screenReader') ?? false,
      reduceAnimations: sharedPreferences.getBool('reduceAnimations') ?? false,
      hapticFeedback: sharedPreferences.getBool('hapticFeedback') ?? true,
    ));
  }

  Future<void> setFontSize(GuiaFontSizeOption size) async {
    emit(state.copyWith(fontSize: size));
    await sharedPreferences.setInt('fontSize', size.index);
  }

  Future<void> setHighContrast(bool value) async {
    emit(state.copyWith(highContrast: value));
    await sharedPreferences.setBool('highContrast', value);
  }

  Future<void> setScreenReader(bool value) async {
    emit(state.copyWith(screenReader: value));
    await sharedPreferences.setBool('screenReader', value);
  }

  Future<void> setReduceAnimations(bool value) async {
    emit(state.copyWith(reduceAnimations: value));
    await sharedPreferences.setBool('reduceAnimations', value);
  }

  Future<void> setHapticFeedback(bool value) async {
    emit(state.copyWith(hapticFeedback: value));
    await sharedPreferences.setBool('hapticFeedback', value);
  }
}
