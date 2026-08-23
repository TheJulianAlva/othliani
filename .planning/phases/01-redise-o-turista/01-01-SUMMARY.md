---
phase: 01-redise-o-turista
plan: 01
subsystem: ui

tags: [flutter, theme, design-system, theme-extension, google_fonts, widget-test]

# Dependency graph
requires: []
provides:
  - "TuristaColors — raw D-03 terracota/teal palette (18 static const Color fields), the only file in the Turista tree allowed raw ARGB literals"
  - "VelturTokens — app-neutral ThemeExtension<VelturTokens> contract (13 semantic colors, 5 radii, 5 shadow lists), with VelturTokens.of(context) non-null lookup and a documented VelturTokens.fallback"
  - "TuristaTheme.lightTheme — assembled ThemeData wired into main_turista.dart's MaterialApp.router, registering TuristaTheme.tokens as a theme extension"
  - "Theme-driven EmptyStateWidget and ChatBubble — first two widgets consuming VelturTokens.of(context) instead of hardcoded colors, proving the D-02 reusability mechanism"
  - "turista_theme_test.dart / empty_state_widget_test.dart — the mechanical D-02 portability proof future plans in this phase (and Phase 2/Guía) can rely on instead of re-reading widget source"
affects: [01-02, 01-03, 01-04, 01-05, 01-06, "phase 02 (Guía) reuses VelturTokens contract"]

# Actuals (#2632)
actuals:
  tokens: 8910
  tasks: 2
  commits: 2

# Tech tracking
tech-stack:
  added: ["google_fonts ^8.2.1 (Poppins via GoogleFonts.poppinsTextTheme)"]
  patterns:
    - "ThemeExtension<T> as the app-neutral token contract: shared widgets read VelturTokens.of(context) instead of importing an app-specific colors file"
    - "Raw color literals confined to one file (TuristaColors); every other file reads through VelturTokens or Theme.of(context)"

key-files:
  created:
    - frontend/lib/core/theme/turista_colors.dart
    - frontend/lib/core/theme/veltur_tokens.dart
    - frontend/lib/core/theme/turista_theme.dart
    - frontend/test/core/theme/turista_theme_test.dart
    - frontend/test/core/widgets/empty_state_widget_test.dart
  modified:
    - frontend/pubspec.yaml
    - frontend/lib/main_turista.dart
    - frontend/lib/core/widgets/empty_state_widget.dart
    - frontend/lib/features/turista/chat/presentation/widgets/chat_bubble.dart

key-decisions:
  - "google_fonts resolved to 8.2.1 (matches the ^8.2.1 constraint); no font asset bundled, per D-04."
  - "VelturTokens.fallback ships the same tinted-shadow/D-03 values as TuristaTheme.tokens, so a missing-registration degrade during a live recording still reads warm, not generic-Material."
  - "MaterialApp wraps `theme:` in AnimatedTheme — the D-02 portability test needed an explicit pumpAndSettle() after each pumpWidget to read the settled color, not the pre-lerp frame. Documented inline in the test."

patterns-established:
  - "Single token-access idiom: VelturTokens.of(context) for semantic colors/radii/shadows, Theme.of(context).colorScheme for primary/surface/error, Theme.of(context).textTheme for type. No plan should import TuristaColors outside turista_theme.dart."

requirements-completed: [DISENO-TUR-01]

coverage:
  - id: D1
    description: "Token -> theme -> main_turista.dart -> widget chain wired end-to-end: TuristaTheme.lightTheme registers VelturTokens and is the theme MaterialApp.router uses"
    requirement: DISENO-TUR-01
    verification:
      - kind: unit
        ref: "frontend/test/core/theme/turista_theme_test.dart#TuristaTheme.lightTheme expone el token de color primario terracota y el fondo cálido"
        status: pass
      - kind: unit
        ref: "frontend/test/core/theme/turista_theme_test.dart#Cadena token -> tema -> widget renderizado (tracer)"
        status: pass
    human_judgment: false
  - id: D2
    description: "EmptyStateWidget and ChatBubble render terracota/teal token colors and are portable to a second VelturTokens instance (D-02 contract for Phase 2/Guía reuse)"
    requirement: DISENO-TUR-01
    verification:
      - kind: unit
        ref: "frontend/test/core/widgets/empty_state_widget_test.dart#La MISMA instancia de EmptyStateWidget renderiza un color DISTINTO bajo un segundo VelturTokens registrado"
        status: pass
      - kind: unit
        ref: "frontend/test/core/widgets/empty_state_widget_test.dart#VelturTokens.of(context) bajo un MaterialApp sin extensión registrada devuelve VelturTokens.fallback sin lanzar"
        status: pass
    human_judgment: false
  - id: D3
    description: "Full visual/UX correctness of the warm redesign in a real running app (typeface rendering, spacing rhythm, contrast) — mechanical tests cover token wiring, not the live pitch-recording look"
    verification: []
    human_judgment: true
    rationale: "This plan proves the mechanism with widget tests under a test binding (no real font fetch, no device rendering). Actual visual/typographic confirmation on a running Turista build is deferred to plan 01-10's human-verify checkpoint per the plan's own must_haves.assumptions."

duration: 20min
completed: 2026-08-22
status: complete
---

# Phase 01 Plan 01: Cadena token -> tema -> widget cálida de Turista Summary

**ThemeExtension<VelturTokens> app-neutral contract + TuristaTheme.lightTheme (terracota/teal, Poppins via google_fonts 8.2.1) wired into main_turista.dart, proven end-to-end on EmptyStateWidget and ChatBubble with a mechanical D-02 portability test.**

## Performance

- **Duration:** ~20 min
- **Tasks:** 2/2 completed
- **Files modified:** 10 (5 created, 4 modified in `frontend/lib/`, plus `pubspec.lock`)

## Accomplishments

- Built the full token chain: `TuristaColors` (raw D-03 ARGB values) → `VelturTokens` (app-neutral `ThemeExtension<VelturTokens>` contract, no Turista imports) → `TuristaTheme.lightTheme` (binds the two, assembled from the `app_theme.dart` skeleton with D-05 radii, warm shadows, and `GoogleFonts.poppinsTextTheme`).
- Wired `main_turista.dart`'s `MaterialApp.router` to `TuristaTheme.lightTheme`, leaving `darkTheme`, `themeMode`, and the accessibility `builder:` block (TextScaler + boldText) byte-identical.
- Converted `EmptyStateWidget` (shared, `core/widgets/`) and `ChatBubble` (feature-level) to read colors/radii exclusively from `VelturTokens.of(context)` — zero hardcoded colors, zero import of `app_colors.dart`/`app_constants.dart` in `chat_bubble.dart`.
- Proved the D-02 reusability contract mechanically: the same `EmptyStateWidget` instance renders a *different* icon color when pumped under a second, independently-constructed `VelturTokens` (a Guía-shaped stand-in) — this is the test Phase 2 can point at instead of re-reading widget source.
- Verified `app_theme.dart`, `app_colors.dart`, `app_constants.dart`, `dark_theme.dart` are provably untouched (`git diff --stat` empty against the base commit), preserving Agencia's current navy look per D-01/D-06.

## Task Commits

Each task was committed atomically:

1. **Task 1: Cadena completa token → tema → main_turista → widget renderizado (tracer)** - `ea72d3a` (feat)
2. **Task 2: Prueba de portabilidad del tema (contrato D-02 para la Fase 2)** - `cf5c102` (test)

_Tracer feedback gate: re-ran Task 1's `<verify>` (full `flutter test test/core/theme/turista_theme_test.dart`) after committing — all 4 tests passed — before starting Task 2's expansion, per this plan's `type="tracer"` requirement._

## Files Created/Modified

- `frontend/lib/core/theme/turista_colors.dart` - Raw D-03 palette, 18 `static const Color` fields incl. `shadowTint`
- `frontend/lib/core/theme/veltur_tokens.dart` - `VelturTokens extends ThemeExtension<VelturTokens>`: 13 semantic colors, 5 radii, 5 shadow lists, `copyWith`/`lerp` overrides, `of(context)`, documented `fallback`
- `frontend/lib/core/theme/turista_theme.dart` - `TuristaTheme.tokens` (the Turista `VelturTokens` instance) and `TuristaTheme.lightTheme` (`ThemeData` with terracota `ColorScheme`, warm `appBarTheme`/`elevatedButtonTheme`/`inputDecorationTheme`/`cardTheme`/`bottomNavigationBarTheme`/`snackBarTheme`, Poppins text theme, `extensions: [tokens]`)
- `frontend/lib/main_turista.dart` - Light theme binding swapped from `AppTheme.lightTheme` to `TuristaTheme.lightTheme`; dark theme/accessibility builder unchanged
- `frontend/lib/core/widgets/empty_state_widget.dart` - Icon/text colors sourced from `VelturTokens.of(context)` instead of `Colors.grey`/`AppTextStyles.caption`
- `frontend/lib/features/turista/chat/presentation/widgets/chat_bubble.dart` - Bubble colors/radius sourced from `VelturTokens.of(context)`; `app_colors.dart`/`app_constants.dart` imports removed
- `frontend/pubspec.yaml` / `frontend/pubspec.lock` - Added `google_fonts: ^8.2.1` (resolved `8.2.1`), no font asset bundled
- `frontend/test/core/theme/turista_theme_test.dart` - Tracer end-to-end proof (Task 1) plus D-05 radii, UI-SPEC type scale/weight-count, and shadow-tint assertions (Task 2)
- `frontend/test/core/widgets/empty_state_widget_test.dart` - D-02 portability proof: theme-driven render, cross-theme color divergence, non-throwing fallback

## Resolved Package Version

`google_fonts` resolved to **8.2.1** in `frontend/pubspec.lock` (matches the `^8.2.1` constraint; publisher `flutter.dev`, verified at plan time).

## VelturTokens Field List (for later plans — read this section instead of re-reading source)

**Semantic colors:** `surfaceWarm`, `border`, `textMuted`, `primaryHover`, `primarySoft`, `accentTeal`, `accentTealSoft`, `safe`, `safeSoft`, `warn`, `warnSoft`, `danger`, `dangerSoft`
**Radii (`double`):** `radiusSm` (10), `radiusMd` (16), `radiusLg` (24), `radiusXl` (32), `radiusFull` (9999)
**Shadows (`List<BoxShadow>`):** `shadowSm`, `shadowMd`, `shadowLg`, `shadowGlowPrimary`, `shadowGlowDanger` — all tinted with the warm brown `TuristaColors.shadowTint` (`0xFF2B1D14`) except the two glow tokens, which use `primary`/`danger` respectively.
**Access:** `VelturTokens.of(BuildContext context)` — non-null, falls back to `VelturTokens.fallback` if no extension is registered. `Theme.of(context).colorScheme` still supplies `primary`/`secondary`(=accentTeal)/`surface`/`error`. `Theme.of(context).textTheme` supplies `bodyLarge`/`labelLarge`/`titleLarge`/`displaySmall` per the UI-SPEC type scale (two weights only: 400, 600).

## Decisions Made

- `google_fonts` resolves only Poppins at runtime; Nunito remains a documented fallback intent in `default.css`/code comments, not an active runtime fallback (per D-04, `google_fonts` resolves one family per call).
- `VelturTokens.fallback` deliberately mirrors the real Turista shadow/radius values (not a generic gray) so a broken registration during a live pitch recording degrades gracefully rather than looking obviously wrong.
- `SnackBarThemeData.contentTextStyle` colored `TuristaColors.surface` (white) since the default Material `SnackBar` background stays dark — legible contrast without a full snackbar restyle, which is out of this plan's scope.

## Deviations from Plan

None - plan executed exactly as written. All `must_haves.truths`, radius/shadow/typography values, and file/class names match the plan's `design_decisions` table verbatim.

## Observed RED Message (Task 2 portability-test revert check)

Per the plan's acceptance criteria, `empty_state_widget.dart`'s icon color was temporarily reverted to `Colors.grey` and the suite re-run. Both portability-dependent tests failed as expected:

```
Expected: Color:<Color(alpha: 1.0000, red: 0.1216, green: 0.6784, blue: 0.6275, colorSpace: ColorSpace.sRGB)>
  Actual: MaterialColor:<MaterialColor(primary value: Color(alpha: 1.0000, red: 0.6196, green: 0.6196, blue: 0.6196, colorSpace: ColorSpace.sRGB))>
```

(from `EmptyStateWidget (contrato de portabilidad D-02) Renderiza el ícono con el token teal de Turista bajo TuristaTheme.lightTheme` and the dependent cross-theme-divergence test.) The file was then restored to the committed version and the full suite re-verified green (10/10 passing) before the Task 2 commit.

## Issues Encountered

- The cross-theme portability test initially failed with the *second* pumped theme still showing the *first* theme's color. Root cause: `MaterialApp` wraps its `theme:` in `AnimatedTheme`, so a bare `pumpWidget()` (one frame) captures the pre-lerp frame after a theme swap. Fixed by adding `await tester.pumpAndSettle()` after each `pumpWidget` call in the portability test — documented inline as a code comment so the pattern is visible to future test authors in this phase.

## Next Phase Readiness

- The single token-access idiom (`VelturTokens.of(context)` / `Theme.of(context).colorScheme` / `Theme.of(context).textTheme`) is proven and ready for the remaining 01-02..01-06 plans to restyle every other Turista screen against.
- Phase 2 (Guía) can construct its own `VelturTokens` instance and reuse `EmptyStateWidget` (and any future shared widget following this pattern) unchanged — mechanically enforced by the portability test in this plan.
- No blockers. The `google_fonts` runtime-fetch assumption (device must have run online once before pitch recording) remains an open flag for plan 01-10's human-verify checkpoint, unchanged from the plan's documented assumptions.

---
*Phase: 01-redise-o-turista*
*Completed: 2026-08-22*
