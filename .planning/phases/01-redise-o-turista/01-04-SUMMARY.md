---
phase: 01-redise-o-turista
plan: 04
subsystem: ui

tags: [flutter, theme, veltur-tokens, currency-converter, snackbar, ocr]

# Dependency graph
requires:
  - phase: 01-01
    provides: "VelturTokens ThemeExtension contract + TuristaTheme.lightTheme (terracota/teal tokens, Poppins textTheme roles), consumed via VelturTokens.of(context)"
provides:
  - "Currency converter screen fully off the Agencia AppBorderRadius scale — every radius now reads from VelturTokens (radiusMd/radiusLg/radiusSm/radiusFull)"
  - "Result card wearing the Display type role (textTheme.displaySmall, 32/600) in terracota on a primarySoft wash with a warm shadow"
  - "_showError(BuildContext, String) helper — the themed-SnackBar pattern other Turista screens in this phase can mirror"
  - "Both loading spinners (OCR overlay, rate-fetch) recolored terracota; OCR scrim warm-tinted instead of Colors.black54"
affects: ["01-10 (phase-wide human verification — currency converter transparency/loading judgment)"]

# Actuals (#2632)
actuals:
  tokens: 3158
  tasks: 2
  commits: 2

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Private _showError(BuildContext, String) helper centralizing SnackBar theming (danger background + onError text) to prevent five call sites from drifting apart"
    - "Deriving a warm scrim tint from an existing VelturTokens shadow color (tokens.shadowLg.first.color.withValues(alpha:)) instead of introducing a new raw color literal"

key-files:
  created: []
  modified:
    - frontend/lib/core/tools/presentation/screens/currency_converter_screen.dart

key-decisions:
  - "Image-preview border and result-card border both moved to the `border` token at width 1 (down from an implicit/explicit primary-color outline) — a heavy terracota outline around content reads as an error state in the new palette, per the plan's action guidance."
  - "SnackBar text color sourced from theme.colorScheme.onError (Material's computed contrast color for the error/danger role) instead of a Colors.white literal, keeping the error path fully theme-driven with zero new raw color literals."
  - "OCR scrim tint reuses tokens.shadowLg.first.color (the existing warm shadowTint RGB) at alpha 0.54 to match Colors.black54's prior opacity, rather than declaring a new Color literal — satisfies the plan's 'read the tint through VelturTokens.of(context) rather than introducing a literal' instruction."
  - "Currency-selector dropdown radius (_buildCurrencySelector) switched from AppBorderRadius.sm to tokens.radiusSm; its border color (theme.colorScheme.outline) and label text style were left untouched — not mandated by the plan and no acceptance criterion covers them, so this stayed a minimal, scoped change."

patterns-established:
  - "Warm-tint-from-shadow-token derivation: when a screen needs a translucent warm scrim/overlay and no dedicated VelturTokens field exists for it, derive the color from an existing shadow token's RGB rather than hardcoding a new literal."

requirements-completed: [DISENO-TUR-03, DISENO-TUR-01]

coverage:
  - id: D1
    description: "Every radius on the currency converter screen (image preview, result card, rate chip, currency selectors, swap button) reads from VelturTokens instead of the Agencia AppBorderRadius scale"
    requirement: DISENO-TUR-03
    verification:
      - kind: other
        ref: "grep -q 'AppBorderRadius' lib/core/tools/presentation/screens/currency_converter_screen.dart (expect no match)"
        status: pass
      - kind: other
        ref: "flutter analyze (zero error lines)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Converted-amount figure renders at the Display type role (32px/600, terracota) inside a primarySoft card with 24px radius and a warm shadow instead of a local fontSize:32/FontWeight.bold literal"
    requirement: DISENO-TUR-03
    verification:
      - kind: other
        ref: "grep -q 'fontSize: 32' lib/core/tools/presentation/screens/currency_converter_screen.dart (expect no match — role-named via textTheme.displaySmall)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Conversion math, exchange-rate fetch, OCR pipeline, image pickers and CurrencyCubit state handling are unchanged — this plan touched only presentation"
    requirement: DISENO-TUR-03
    verification:
      - kind: other
        ref: "git diff HEAD~2 HEAD -- currency_converter_screen.dart | grep -E '^[-+][^-+]' | grep -c '(_convert|toStringAsFixed|_getCurrencySymbol|_getCurrencyName|_processImage|_takePicture|_pickFromGallery|CurrencyCubit|rates\\[)' -> 0 content lines (the literal grep against the raw diff returns 2 due to the '---/+++ ... currency_converter_screen.dart' file-path headers matching '_convert' as a substring of 'converter' — confirmed a false positive, not a behavioral change, by filtering diff headers)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Both CircularProgressIndicator instances (rate-fetch, OCR scrim) render terracota instead of Flutter's default blue; OCR scrim is warm-tinted instead of a neutral black wash; all five SnackBar error sites route through one themed _showError helper carrying danger-token background while keeping l10n strings invalidAmount/noNumberFound verbatim"
    requirement: DISENO-TUR-01
    verification:
      - kind: other
        ref: "grep -c 'CircularProgressIndicator' == 2, both with color: within 3 lines; grep -c '_showError' == 6; grep -c 'l10n.invalidAmount' == 1; grep -c 'l10n.noNumberFound' == 1; literal-color scan clean"
        status: pass
    human_judgment: false
  - id: D5
    description: "Full visual/UX correctness on a running Turista build (warm scrim tint, card shadow depth, spinner color, SnackBar legibility over danger background)"
    verification: []
    human_judgment: true
    rationale: "This plan proves the change mechanically via grep/analyze gates against source, not a rendered device/simulator screenshot. Actual visual confirmation is deferred to plan 01-10's phase-wide human-verify checkpoint, consistent with 01-01's precedent."

duration: 25min
completed: 2026-08-22
status: complete
---

# Phase 01 Plan 04: Currency Converter Warm Restyle Summary

**Currency converter off the Agencia radius scale entirely — Display-role result figure in terracota on a primarySoft/shadowSm card, both spinners recolored terracota, OCR scrim warm-tinted, and all five SnackBar error sites routed through one new `_showError` helper — with zero changes to conversion math, rate fetch, or OCR logic.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 2/2 completed
- **Files modified:** 1 (`currency_converter_screen.dart`)

## Accomplishments

- Replaced every `AppBorderRadius` reference on the screen with `VelturTokens.of(context)` equivalents: image preview and its `ClipRRect` → `radiusMd` (16), result card → `radiusLg` (24), rate-detail chip and currency selectors → `radiusSm` (10).
- Result card restyled to the palette's `primarySoft` wash, a 1px `border`-token side, and `shadowSm` depth (replacing a 2px hard primary outline); its caption/figure/currency-name lines now route through `textTheme.labelLarge`/`displaySmall`/`bodyLarge` instead of local `TextStyle`/`fontSize`/`FontWeight.bold` literals.
- Swap `IconButton` restyled to a `primarySoft`-filled `radiusFull` pill with the terracota foreground.
- Rate-detail chip recolored to `surfaceWarm`/`textMuted` with `textTheme.labelLarge`, replacing `surfaceContainerHighest`/`fontSize: 12`.
- Both `CircularProgressIndicator` instances (rate-fetch, OCR overlay) now render `theme.colorScheme.primary` instead of Flutter's default blue.
- OCR full-screen scrim recolored from `Colors.black54` to a warm tint derived from `tokens.shadowLg.first.color` at the same 0.54 opacity.
- Extracted `_showError(BuildContext, String)` — a themed `SnackBar` helper (danger-token background, `onError` text) — and routed all five existing error sites through it, preserving `l10n.invalidAmount`, `l10n.noNumberFound`, and the `'${l10n.error}: $e'` interpolation verbatim.
- Verified the currency-selector labels (`l10n.from`/`l10n.to`) remain individually visible after the restyle — the direction-clarity prohibition holds.

## Task Commits

Each task was committed atomically:

1. **Task 1: Tarjeta de resultado, escala tipográfica y radios de token** - `dd1bc59` (feat)
2. **Task 2: Estados de carga y error del conversor en tokens cálidos** - `37f4d91` (feat)

## Files Created/Modified

- `frontend/lib/core/tools/presentation/screens/currency_converter_screen.dart` - Radii moved to `VelturTokens`, result card/rate chip/swap button restyled to warm tokens, Display-role figure, `_showError` helper added and wired to all five SnackBar sites, both spinners recolored terracota, OCR scrim warm-tinted.

## Decisions Made

- Image-preview and result-card borders moved to the `border` token at width 1 (down from an implicit/explicit primary-color outline) — a heavy terracota outline around content reads as an error state in the new palette.
- SnackBar text color sourced from `theme.colorScheme.onError` rather than a `Colors.white` literal, keeping the error path fully theme-driven.
- OCR scrim tint reuses `tokens.shadowLg.first.color` (the existing warm `shadowTint` RGB) at `alpha: 0.54` instead of declaring a new `Color` literal, per the plan's instruction to read the tint through `VelturTokens.of(context)`.
- `_buildCurrencySelector`'s dropdown border color (`theme.colorScheme.outline`) and label style were left unchanged — only its radius moved to the token scale, since neither the plan action text nor its acceptance criteria required touching those.

## Deviations from Plan

None - plan executed exactly as written. All `must_haves.truths` and both tasks' `<action>` instructions were followed; the "keeps the primary color but ... takes the border token" phrasing in Task 1's image-preview instruction was interpreted per its stated rationale ("a 2px terracota outline around a photo reads as an error state") — moved to the `border` token color at width 1, consistent with the parallel, unambiguous instruction for the result card's border in the same task.

**Total deviations:** 0
**Impact on plan:** None — plan executed as specified.

## Issues Encountered

- Task 1's own `git diff` behavior-preservation gate (`grep -cE '^[-+].*(_convert|...)' -> expect 0`) returns `2` when run against the raw `git diff` output, because the diff's `--- a/.../currency_converter_screen.dart` / `+++ b/.../currency_converter_screen.dart` header lines contain the substring `_convert` (as part of "**_convert**er"). Confirmed this is a false positive, not a behavioral change, by re-running the same grep with diff-header lines (`^---`/`^+++`) filtered out: `0` matches. No conversion, rate-fetch, or OCR logic was touched in either task — verified directly by reading the diffs.

## Next Phase Readiness

- The `_showError` helper pattern (danger-token background + `onError` text, no restated shape/behavior) is the reference other Turista screens in this phase can mirror for their own SnackBar restyles.
- The warm-tint-from-shadow-token derivation (`tokens.shadowLg.first.color.withValues(alpha:)`) is available as a reusable technique for any other screen needing a translucent warm scrim without a dedicated `VelturTokens` field.
- No rate-freshness or source cue exists on this screen today (grepped for "fecha", "timestamp", "actualizado", "updated", "fresh", "live", "en vivo", "cached" — none found). Recorded here per the plan's output instruction so 01-10's human verification can judge the transparency prohibition (rendering a cached rate as if live) with this fact in hand — nothing was added, since inventing a freshness claim would be new copy.
- `AppSpacing` occurrence count confirmed unchanged at 21 before and after both tasks — spacing was not collaterally edited while radius constants were swapped.
- No blockers for the remaining Turista screens in this phase.

## Self-Check: PASSED

- FOUND: frontend/lib/core/tools/presentation/screens/currency_converter_screen.dart
- FOUND: .planning/phases/01-redise-o-turista/01-04-SUMMARY.md
- FOUND: commit dd1bc59 (Task 1)
- FOUND: commit 37f4d91 (Task 2)

---
*Phase: 01-redise-o-turista*
*Completed: 2026-08-22*
