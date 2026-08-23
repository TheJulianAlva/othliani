import 'package:flutter/material.dart';

/// Paleta cálida (terracota + teal) exclusiva de la app Turista.
///
/// Única clase del árbol de Turista autorizada a declarar literales ARGB
/// crudos (ver D-01/D-03 en `.planning/phases/01-redise-o-turista/01-CONTEXT.md`).
/// El resto del código lee estos valores indirectamente a través de
/// [VelturTokens]/[TuristaTheme], nunca importando este archivo directamente
/// (salvo `turista_theme.dart`).
class TuristaColors {
  static const Color background = Color(0xFFFFF8F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceWarm = Color(0xFFFFF2E6);
  static const Color border = Color(0xFFF0E2D4);
  static const Color text = Color(0xFF2B1D14);
  static const Color textMuted = Color(0xFF8A7669);

  static const Color primary = Color(0xFFE8623D);
  static const Color primaryHover = Color(0xFFD1502E);
  static const Color primarySoft = Color(0xFFFCE3DA);

  static const Color accentTeal = Color(0xFF1FADA0);
  static const Color accentTealSoft = Color(0xFFD9F3F0);

  static const Color safe = Color(0xFF3CB371);
  static const Color safeSoft = Color(0xFFE1F5E9);
  static const Color warn = Color(0xFFF2A03D);
  static const Color warnSoft = Color(0xFFFDECD4);
  static const Color danger = Color(0xFFE5484D);
  static const Color dangerSoft = Color(0xFFFBE0E1);

  /// Tinte cálido base con el que se colorean todas las sombras del sistema
  /// (en vez del `Colors.black12` genérico del tema legado).
  static const Color shadowTint = Color(0xFF2B1D14);
}
