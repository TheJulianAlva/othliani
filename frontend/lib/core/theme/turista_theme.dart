import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'turista_colors.dart';
import 'veltur_tokens.dart';

/// Tema cálido (terracota + teal) de la app Turista.
///
/// Nota de tipografía (D-04): `default.css` documenta Poppins con fallback a
/// Nunito (`--font-sans`), pero `google_fonts` resuelve una única familia por
/// llamada — este tema carga solo Poppins. Nunito queda como intención
/// documentada, no como fallback real en tiempo de ejecución.
class TuristaTheme {
  TuristaTheme._();

  /// Instancia de [VelturTokens] construida a partir de [TuristaColors].
  /// Es la única fuente de radios/sombras/colores semánticos que los
  /// widgets compartidos leen vía `VelturTokens.of(context)`.
  static const VelturTokens tokens = VelturTokens(
    surfaceWarm: TuristaColors.surfaceWarm,
    border: TuristaColors.border,
    textMuted: TuristaColors.textMuted,
    primaryHover: TuristaColors.primaryHover,
    primarySoft: TuristaColors.primarySoft,
    accentTeal: TuristaColors.accentTeal,
    accentTealSoft: TuristaColors.accentTealSoft,
    safe: TuristaColors.safe,
    safeSoft: TuristaColors.safeSoft,
    warn: TuristaColors.warn,
    warnSoft: TuristaColors.warnSoft,
    danger: TuristaColors.danger,
    dangerSoft: TuristaColors.dangerSoft,
    radiusSm: 10,
    radiusMd: 16,
    radiusLg: 24,
    radiusXl: 32,
    radiusFull: 9999,
    shadowSm: [
      BoxShadow(
        color: Color(0x0F2B1D14), // TuristaColors.shadowTint @ 6%
        offset: Offset(0, 2),
        blurRadius: 8,
      ),
    ],
    shadowMd: [
      BoxShadow(
        color: Color(0x1A2B1D14), // TuristaColors.shadowTint @ 10%
        offset: Offset(0, 8),
        blurRadius: 24,
      ),
    ],
    shadowLg: [
      BoxShadow(
        color: Color(0x292B1D14), // TuristaColors.shadowTint @ 16%
        offset: Offset(0, 16),
        blurRadius: 40,
      ),
    ],
    shadowGlowPrimary: [
      BoxShadow(
        color: Color(0x24E8623D), // TuristaColors.primary @ 14%
        spreadRadius: 8,
      ),
    ],
    shadowGlowDanger: [
      BoxShadow(
        color: Color(0x29E5484D), // TuristaColors.danger @ 16%
        spreadRadius: 10,
      ),
    ],
  );

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme(ThemeData().textTheme);

    return ThemeData(
      primaryColor: TuristaColors.primary,
      scaffoldBackgroundColor: TuristaColors.background,
      colorScheme: const ColorScheme.light(
        primary: TuristaColors.primary,
        secondary: TuristaColors.accentTeal,
        surface: TuristaColors.surface,
        error: TuristaColors.danger,
        onPrimary: Colors.white,
        onSurface: TuristaColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TuristaColors.background,
        foregroundColor: TuristaColors.text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TuristaColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TuristaColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: const BorderSide(color: TuristaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: const BorderSide(color: TuristaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: const BorderSide(
            color: TuristaColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: const BorderSide(color: TuristaColors.danger),
        ),
      ),
      cardTheme: CardThemeData(
        color: TuristaColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: TuristaColors.surface,
        selectedItemColor: TuristaColors.primary,
        unselectedItemColor: TuristaColors.textMuted,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: TuristaColors.border),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
        contentTextStyle: const TextStyle(color: TuristaColors.surface),
      ),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: TuristaColors.text,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: TuristaColors.text,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: TuristaColors.text,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.15,
          color: TuristaColors.text,
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[tokens],
    );
  }
}
