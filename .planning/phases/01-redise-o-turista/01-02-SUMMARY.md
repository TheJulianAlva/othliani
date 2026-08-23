---
phase: 01-redise-o-turista
plan: 02
subsystem: ui

tags: [flutter, theme, design-system, theme-extension, widget-test, country_picker]

# Dependency graph
requires:
  - phase: 01-01
    provides: "VelturTokens ThemeExtension contract, TuristaTheme.lightTheme, VelturTokens.of(context) idiom"
provides:
  - "SavingOverlay, InfoModal, PhoneNumberField — the three remaining widgets in core/widgets/ converted from hardcoded colors to VelturTokens.of(context)/Theme.of(context)"
  - "Every widget in core/widgets/ is now theme-driven (fourth, EmptyStateWidget, was done in 01-01) — D-02 generalization of the shared widget directory is complete"
  - "shared_widgets_theme_test.dart — 8 tests proving token consumption, D-02 portability, and preserved static API/blocking-guard/input-masking behaviour"
affects: ["01-03", "01-04", "01-05", "01-06", "phase 02 (Guía) reuses all four core/widgets/ unchanged"]

# Actuals (#2632)
actuals:
  tokens: 5109
  tasks: 2
  commits: 2

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Widgets whose overlay/sheet lives in a separate widget tree (showDialog's builder, showCountryPicker's route) still receive VelturTokens.of(context)/Theme.of(context) via the *calling* BuildContext, read before the async gap, not via ambient inheritance inside the overlay's own tree."
    - "Test idiom for asserting a merged (theme + local) resolved value: read field.decoration on the internal TextField found via find.byType(TextField) — TextFormField already calls InputDecoration.applyDefaults(theme) before constructing it, so the resolved border/focusedBorder is directly assertable without simulating focus."

key-files:
  created:
    - frontend/test/core/widgets/shared_widgets_theme_test.dart
  modified:
    - frontend/lib/core/widgets/saving_overlay.dart
    - frontend/lib/core/widgets/info_modal.dart
    - frontend/lib/core/widgets/phone_number_field.dart

key-decisions:
  - "SavingOverlay's barrier color is computed from VelturTokens.of(context).shadowMd.first.color.withValues(alpha: 0.35) inside the static show() method (context is available there, before the async showDialog builder runs), producing a warm-tinted barrier instead of pure black at the same 35% opacity."
  - "country_picker resolved to 2.0.27 (pubspec constrains ^2.0.26); its CountryListThemeData exposes backgroundColor/borderRadius/textStyle/searchTextStyle/inputDecoration/bottomSheetHeight verbatim — no field substitution was needed, contrary to the plan's flagged possibility."
  - "Added stable Keys (savingOverlaySpinnerCircle, infoModalSheet, infoModalDragHandle) to internal Containers purely for test targeting — these are private widgets, not part of any public constructor/API, so they don't affect the plan's 'no API changes' invariant."

patterns-established:
  - "Every widget in frontend/lib/core/widgets/ now reads colors/radii/shadows exclusively through VelturTokens.of(context) / Theme.of(context) — zero hardcoded Color(0x...) or named Colors.* (besides the two explicitly-permitted Colors.transparent uses). Phase 2 (Guía) can reuse all four widgets by constructing its own VelturTokens instance."

requirements-completed: [DISENO-TUR-01]

coverage:
  - id: D1
    description: "SavingOverlay renders a terracota spinner in a warm-shadowed circle, sourced from Theme.of(context).colorScheme.primary and VelturTokens.of(context).shadowMd, replacing the legacy blue Color(0xFF1565C0) and neutral Colors.black shadow"
    requirement: DISENO-TUR-01
    verification:
      - kind: unit
        ref: "frontend/test/core/widgets/shared_widgets_theme_test.dart#SavingOverlay (tokens de tema) El CircularProgressIndicator usa el color primario terracota del tema"
        status: pass
      - kind: unit
        ref: "frontend/test/core/widgets/shared_widgets_theme_test.dart#SavingOverlay (tokens de tema) La sombra del círculo del spinner usa el tinte cálido, no uno neutro"
        status: pass
    human_judgment: false
  - id: D2
    description: "SavingOverlay.show() preserves its blocking contract (barrierDismissible: false, PopScope canPop: false) while restyling the barrier to a warm tint"
    requirement: DISENO-TUR-01
    verification:
      - kind: unit
        ref: "frontend/test/core/widgets/shared_widgets_theme_test.dart#SavingOverlay (tokens de tema) SavingOverlay.show abre una barrera no descartable y bloquea el back-pop"
        status: pass
    human_judgment: false
  - id: D3
    description: "InfoModal's sheet uses the 24px large radius (VelturTokens.radiusLg) on its top corners and the theme surface color for its background, replacing the hardcoded 16px/Colors.white"
    requirement: DISENO-TUR-01
    verification:
      - kind: unit
        ref: "frontend/test/core/widgets/shared_widgets_theme_test.dart#InfoModal (tokens de tema) La hoja usa BorderRadius superior de 24 y el color de superficie del tema"
        status: pass
    human_judgment: false
  - id: D4
    description: "InfoModal is portable to a second VelturTokens instance (D-02): the same widget renders a different drag-handle color under a Guía-shaped token set without any code change"
    requirement: DISENO-TUR-01
    verification:
      - kind: unit
        ref: "frontend/test/core/widgets/shared_widgets_theme_test.dart#InfoModal (tokens de tema) Pumped bajo un segundo VelturTokens, el indicador de arrastre cambia de color"
        status: pass
    human_judgment: false
  - id: D5
    description: "PhoneNumberField no longer shadows the theme's InputDecorationTheme: the resolved border is 10px radius / theme border color, and the resolved focusedBorder is terracota — both inherited, not locally declared"
    requirement: DISENO-TUR-01
    verification:
      - kind: unit
        ref: "frontend/test/core/widgets/shared_widgets_theme_test.dart#PhoneNumberField (hereda el tema) El borde resuelto del TextFormField tiene radio 10, heredado del tema"
        status: pass
      - kind: unit
        ref: "frontend/test/core/widgets/shared_widgets_theme_test.dart#PhoneNumberField (hereda el tema) El focusedBorder resuelto del campo es terracota, no el default de Material"
        status: pass
    human_judgment: false
  - id: D6
    description: "PhoneNumberField's input masking/emit behaviour (onChanged, localDigits/localMasked pair) is unchanged by the restyle"
    requirement: DISENO-TUR-01
    verification:
      - kind: unit
        ref: "frontend/test/core/widgets/shared_widgets_theme_test.dart#PhoneNumberField (hereda el tema) onChanged sigue emitiendo el par de valores enmascarado/sin máscara"
        status: pass
    human_judgment: false
  - id: D7
    description: "The country-picker bottom sheet (its own overlay widget tree, outside the calling screen's Theme inheritance) renders with the same warm radius/border/typography treatment as the rest of the app via an explicitly-built CountryListThemeData"
    verification: []
    human_judgment: true
    rationale: "country_picker's search field/list rows are rendered by third-party package internals not exposed to widget tests in a way that lets us assert on rendered colors without forking the package. The CountryListThemeData construction is code-reviewed and token-sourced (see key-decisions), but its live visual appearance needs human confirmation, deferred to plan 01-10's human-verify checkpoint per this plan's own must_haves.assumptions."
  - id: D8
    description: "Public constructor signatures and static APIs of SavingOverlay, InfoModal, PhoneNumberField are unchanged — no call site elsewhere in the app needs editing"
    requirement: DISENO-TUR-01
    verification:
      - kind: other
        ref: "git diff HEAD -- frontend/lib/core/widgets/saving_overlay.dart | grep -cE '^[-+].*(static void show|static Future<void> showAndWait|static void hide|canPop|barrierDismissible)' => 0"
        status: pass
      - kind: other
        ref: "git diff HEAD -- frontend/lib/core/widgets/info_modal.dart | grep -cE '^[-+].*(Duration|Curve|AnimationController|_fade|_slide)' => 0"
        status: pass
      - kind: other
        ref: "git diff HEAD -- frontend/lib/core/widgets/phone_number_field.dart | grep -cE '^[-+].*(_maskFormatter|_emitChange|onChanged|localDigits|_flagEmoji)' => 0"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-08-22
status: complete
---

# Phase 01 Plan 02: Widgets compartidos de core/widgets/ leen sus tokens del tema Summary

**SavingOverlay, InfoModal and PhoneNumberField converted from hardcoded colors/radii to VelturTokens.of(context)/Theme.of(context), completing the D-02 generalization of `frontend/lib/core/widgets/` started in 01-01 — all four shared widgets are now theme-driven and Guía-portable.**

## Performance

- **Duration:** ~15 min
- **Tasks:** 2/2 completed
- **Files modified:** 4 (1 test file created, 3 production files modified)

## Accomplishments

- `SavingOverlay`: spinner recolored from the legacy blue `Color(0xFF1565C0)` to `Theme.of(context).colorScheme.primary` (terracota); circle shadow replaced with `VelturTokens.of(context).shadowMd` (warm brown tint instead of `Colors.black.withValues(alpha: 0.18)`); the modal barrier color, computed inside the static `show()` method from the same warm-tint source at 35% alpha, replacing `Colors.black.withValues(alpha: 0.35)`. `PopScope(canPop: false)` and `barrierDismissible: false` verified byte-identical.
- `InfoModal`: sheet container and its `showModalBottomSheet` shape both moved to `VelturTokens.of(context).radiusLg` (24px, up from 16px); background moved from `Colors.white` to `Theme.of(context).colorScheme.surface`; drag-handle pill recolored to `VelturTokens.of(context).border`; the default (no `titleColor`) leading icon moved from neutral black to `Theme.of(context).colorScheme.primary`; dropped the local `fontWeight: FontWeight.w700` override on the title so it inherits `titleLarge`'s theme weight-600. Animation controllers/curves/durations untouched.
- `PhoneNumberField`: removed the local `border: const OutlineInputBorder()` that was shadowing `TuristaTheme.inputDecorationTheme`, so the field now inherits the 10px radius and terracota `focusedBorder` from the theme; hint text recolored to `VelturTokens.of(context).textMuted`. The country-picker sheet (a separate overlay widget tree that does not inherit `InputDecorationTheme`) now builds an explicit `CountryListThemeData` from the same tokens — `radiusSm`/`border`/primary-focused `OutlineInputBorder`, `radiusLg` sheet corners, and the theme's `textStyle`/`searchTextStyle`. Mask/emit behaviour, the `Buscar país` label, and the `['MX', 'US', 'ES']` favourites list preserved verbatim.
- Added `frontend/test/core/widgets/shared_widgets_theme_test.dart` — 8 tests spanning the 3 widgets, mirroring the AAA/Spanish-name/`t`-prefix idiom from 01-01's `empty_state_widget_test.dart`, including a D-02 portability proof on `InfoModal`'s drag-handle color under a second `VelturTokens` instance.
- Every widget in `frontend/lib/core/widgets/` (all four, counting `EmptyStateWidget` from 01-01) is now free of hardcoded colors — confirmed by a scoped literal-color grep gate that permits only `Colors.transparent`.

## Task Commits

Each task was committed atomically:

1. **Task 1: SavingOverlay e InfoModal leen sus tokens del tema** - `84964d7` (feat)
2. **Task 2: PhoneNumberField hereda el tema en vez de sobrescribirlo** - `2c7843d` (feat)

_Both tasks were TDD (`tdd="true"`): the test file was written and run alongside each task's
implementation, so RED/GREEN happened within a single feat commit per task rather than as
separate `test(...)`/`feat(...)` commits — the plan's `<verify>` gates (not a strict RED-first
git-history split) were the enforcement mechanism, consistent with `type="execute"` plans._

## Files Created/Modified

- `frontend/lib/core/widgets/saving_overlay.dart` - Spinner color, shadow, mensaje text-shadow tint, and barrier color sourced from `VelturTokens.of(context)`/`Theme.of(context)`
- `frontend/lib/core/widgets/info_modal.dart` - Sheet radius/color, drag-handle color, default icon color sourced from tokens; dropped redundant `fontWeight` override
- `frontend/lib/core/widgets/phone_number_field.dart` - Removed theme-shadowing local border; hint text muted-token color; country-picker `CountryListThemeData` explicitly token-built
- `frontend/test/core/widgets/shared_widgets_theme_test.dart` (new) - 8 tests: SavingOverlay spinner/shadow/blocking-guard (3), InfoModal radius+surface/portability (2), PhoneNumberField inherited-border/focused-border/onChanged (3)

## Resolved Package Version

`country_picker` resolved to **2.0.27** in `frontend/pubspec.lock` (constraint `^2.0.26`, unchanged by this plan — no new dependency added). Its `CountryListThemeData` (`lib/src/country_list_theme_data.dart`) exposes every field the plan named (`backgroundColor`, `textStyle`, `searchTextStyle`, `inputDecoration`, `borderRadius`, `bottomSheetHeight`) verbatim — **no field substitution was required**, contrary to the plan's flagged possibility.

## Decisions Made

- `SavingOverlay.show()`'s barrier color reads `VelturTokens.of(context)` synchronously before `showDialog` is invoked (the `context` passed to `show()` is still valid at that point, no async gap), then forces the alpha to 35% via `.withValues(alpha: 0.35)` on the warm-tint RGB — this is how a static method with no widget-tree context of its own still gets a themed value.
- Added test-only `Key`s (`savingOverlaySpinnerCircle`, `infoModalSheet`, `infoModalDragHandle`) to internal `Container`s so tests can target the exact node instead of guessing by decoration shape — these live on private widgets and don't touch any public constructor.
- `PhoneNumberField`'s tests assert on the *merged* `TextField.decoration` (post `applyDefaults`) rather than the raw pre-merge decoration, after discovering `TextFormField` always calls `InputDecoration.applyDefaults(InputDecorationTheme.of(context))` before constructing its internal `TextField` — see Issues Encountered.

## Deviations from Plan

None - plan executed exactly as written. All `must_haves.truths`, the country-picker field-availability assumption, and the "no API/animation/masking change" prohibitions verified via the plan's own git-diff acceptance-criteria gates (all returned 0).

## Issues Encountered

- **`pumpAndSettle()` timeout on `SavingOverlay`.** `CircularProgressIndicator`'s indeterminate animation never settles, so `pumpAndSettle()` (used successfully in 01-01's `empty_state_widget_test.dart` idiom) hung and timed out on every `SavingOverlay` test. Fixed by pumping explicit durations (`kThemeAnimationDuration` for the `AnimatedTheme` transition, a fixed 200ms for the dialog transition) instead of waiting for full settlement — documented inline in the test as a reusable idiom for any future widget test involving an active spinner.
- **`field.decoration.border` was not `null` after removing the local override.** Initial assumption was that `TextFormField.decoration` exposes the raw, pre-theme `InputDecoration` passed by the widget. In fact `TextFormField` calls `(decoration ?? const InputDecoration()).applyDefaults(InputDecorationTheme.of(context))` before constructing its internal `TextField`, so the decoration read via `find.byType(TextField)` is already theme-merged. Rewrote the two border-related tests to assert on the *resolved* `border`/`focusedBorder` (radius 10, theme border/primary color) instead of asserting `isNull` — a more accurate test of the actual behaviour requirement ("the field inherits from the theme") than the original null-check would have been.
- **Pre-existing unrelated test failures in `guia/`** (`sos_cubit_test.dart`, `critical_medical_card_test.dart`) surfaced when running the full `flutter test` suite. Confirmed unrelated (they don't import any file this plan touched) and out of scope per the executor's scope-boundary rule — logged to `.planning/phases/01-redise-o-turista/deferred-items.md`, not fixed here. `flutter test test/core/widgets/` (this plan's actual verification scope) passes 11/11.

## Next Phase Readiness

- All four widgets in `frontend/lib/core/widgets/` are now theme-driven; Phase 2 (Guía) can construct its own `VelturTokens` instance and reuse every one of them unchanged, mechanically enforced by the portability tests in `empty_state_widget_test.dart` (01-01) and `shared_widgets_theme_test.dart` (this plan).
- `SavingOverlay` still has zero Turista call sites in the current tree — its restyle is proven only by the widget test, not by navigating a real screen. This is expected per the plan's documented assumption; any future plan that adds a Turista call site inherits the theming for free.
- The country-picker sheet's live visual appearance (third-party package internals) is not mechanically testable from here and remains an open item for plan 01-10's human-verify checkpoint, alongside the `google_fonts` runtime-fetch flag carried over from 01-01.
- No blockers.

---
*Phase: 01-redise-o-turista*
*Completed: 2026-08-22*

## Self-Check: PASSED

All created/modified files and referenced commit hashes verified present on disk / in git history.
