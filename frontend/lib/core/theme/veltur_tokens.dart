import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Contrato de tokens de diseño app-neutral (D-02).
///
/// Declara la *forma* de los tokens semánticos (colores, radios y sombras)
/// que cualquier widget compartido en `core/widgets/` puede leer vía
/// `Theme.of(context).extension<VelturTokens>()` sin conocer qué app
/// (Turista, Guía, Agencia) lo registró. Este archivo NO contiene valores
/// concretos de Turista — esos viven en `turista_colors.dart` y se enlazan
/// en `turista_theme.dart`. La Fase 2 (Guía) construye su propia instancia
/// de [VelturTokens] con sus propios valores, reutilizando este mismo
/// contrato sin duplicar widgets.
class VelturTokens extends ThemeExtension<VelturTokens> {
  const VelturTokens({
    required this.surfaceWarm,
    required this.border,
    required this.textMuted,
    required this.primaryHover,
    required this.primarySoft,
    required this.accentTeal,
    required this.accentTealSoft,
    required this.safe,
    required this.safeSoft,
    required this.warn,
    required this.warnSoft,
    required this.danger,
    required this.dangerSoft,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusFull,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
    required this.shadowGlowPrimary,
    required this.shadowGlowDanger,
  });

  // Semantic colors
  final Color surfaceWarm;
  final Color border;
  final Color textMuted;
  final Color primaryHover;
  final Color primarySoft;
  final Color accentTeal;
  final Color accentTealSoft;
  final Color safe;
  final Color safeSoft;
  final Color warn;
  final Color warnSoft;
  final Color danger;
  final Color dangerSoft;

  // Radii
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusFull;

  // Shadows
  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowLg;
  final List<BoxShadow> shadowGlowPrimary;
  final List<BoxShadow> shadowGlowDanger;

  /// Token de respaldo cuando ningún tema registró un [VelturTokens].
  ///
  /// Existe para que un widget compartido nunca lance por un extension
  /// nulo durante una grabación en vivo del pitch: si la registración se
  /// rompe, la app debe degradar a un render cálido-pero-plano, no a un
  /// crash. Los tests del plan 01-01 aseguran que el tema real SÍ registra
  /// la extensión, así que este fallback es una red de seguridad, no el
  /// camino en producción.
  static const VelturTokens fallback = VelturTokens(
    surfaceWarm: Color(0xFFFFF2E6),
    border: Color(0xFFF0E2D4),
    textMuted: Color(0xFF8A7669),
    primaryHover: Color(0xFFD1502E),
    primarySoft: Color(0xFFFCE3DA),
    accentTeal: Color(0xFF1FADA0),
    accentTealSoft: Color(0xFFD9F3F0),
    safe: Color(0xFF3CB371),
    safeSoft: Color(0xFFE1F5E9),
    warn: Color(0xFFF2A03D),
    warnSoft: Color(0xFFFDECD4),
    danger: Color(0xFFE5484D),
    dangerSoft: Color(0xFFFBE0E1),
    radiusSm: 10,
    radiusMd: 16,
    radiusLg: 24,
    radiusXl: 32,
    radiusFull: 9999,
    shadowSm: [
      BoxShadow(
        color: Color(0x0F2B1D14),
        offset: Offset(0, 2),
        blurRadius: 8,
      ),
    ],
    shadowMd: [
      BoxShadow(
        color: Color(0x1A2B1D14),
        offset: Offset(0, 8),
        blurRadius: 24,
      ),
    ],
    shadowLg: [
      BoxShadow(
        color: Color(0x292B1D14),
        offset: Offset(0, 16),
        blurRadius: 40,
      ),
    ],
    shadowGlowPrimary: [
      BoxShadow(color: Color(0x24E8623D), spreadRadius: 8),
    ],
    shadowGlowDanger: [
      BoxShadow(color: Color(0x29E5484D), spreadRadius: 10),
    ],
  );

  /// Devuelve el [VelturTokens] registrado en el tema actual, o
  /// [VelturTokens.fallback] si ninguno fue registrado. Nunca es nulo.
  static VelturTokens of(BuildContext context) {
    return Theme.of(context).extension<VelturTokens>() ?? fallback;
  }

  @override
  VelturTokens copyWith({
    Color? surfaceWarm,
    Color? border,
    Color? textMuted,
    Color? primaryHover,
    Color? primarySoft,
    Color? accentTeal,
    Color? accentTealSoft,
    Color? safe,
    Color? safeSoft,
    Color? warn,
    Color? warnSoft,
    Color? danger,
    Color? dangerSoft,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusFull,
    List<BoxShadow>? shadowSm,
    List<BoxShadow>? shadowMd,
    List<BoxShadow>? shadowLg,
    List<BoxShadow>? shadowGlowPrimary,
    List<BoxShadow>? shadowGlowDanger,
  }) {
    return VelturTokens(
      surfaceWarm: surfaceWarm ?? this.surfaceWarm,
      border: border ?? this.border,
      textMuted: textMuted ?? this.textMuted,
      primaryHover: primaryHover ?? this.primaryHover,
      primarySoft: primarySoft ?? this.primarySoft,
      accentTeal: accentTeal ?? this.accentTeal,
      accentTealSoft: accentTealSoft ?? this.accentTealSoft,
      safe: safe ?? this.safe,
      safeSoft: safeSoft ?? this.safeSoft,
      warn: warn ?? this.warn,
      warnSoft: warnSoft ?? this.warnSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusFull: radiusFull ?? this.radiusFull,
      shadowSm: shadowSm ?? this.shadowSm,
      shadowMd: shadowMd ?? this.shadowMd,
      shadowLg: shadowLg ?? this.shadowLg,
      shadowGlowPrimary: shadowGlowPrimary ?? this.shadowGlowPrimary,
      shadowGlowDanger: shadowGlowDanger ?? this.shadowGlowDanger,
    );
  }

  @override
  VelturTokens lerp(ThemeExtension<VelturTokens>? other, double t) {
    if (other is! VelturTokens) return this;
    return VelturTokens(
      surfaceWarm: Color.lerp(surfaceWarm, other.surfaceWarm, t)!,
      border: Color.lerp(border, other.border, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accentTeal: Color.lerp(accentTeal, other.accentTeal, t)!,
      accentTealSoft: Color.lerp(accentTealSoft, other.accentTealSoft, t)!,
      safe: Color.lerp(safe, other.safe, t)!,
      safeSoft: Color.lerp(safeSoft, other.safeSoft, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnSoft: Color.lerp(warnSoft, other.warnSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
      radiusFull: lerpDouble(radiusFull, other.radiusFull, t)!,
      shadowSm: BoxShadow.lerpList(shadowSm, other.shadowSm, t)!,
      shadowMd: BoxShadow.lerpList(shadowMd, other.shadowMd, t)!,
      shadowLg: BoxShadow.lerpList(shadowLg, other.shadowLg, t)!,
      shadowGlowPrimary: BoxShadow.lerpList(
        shadowGlowPrimary,
        other.shadowGlowPrimary,
        t,
      )!,
      shadowGlowDanger: BoxShadow.lerpList(
        shadowGlowDanger,
        other.shadowGlowDanger,
        t,
      )!,
    );
  }
}
