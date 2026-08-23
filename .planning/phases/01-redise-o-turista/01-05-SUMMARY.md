---
phase: 01-redise-o-turista
plan: 05
subsystem: ui

tags: [flutter, theme-extension, design-system, bloc-state-branch, veltur-tokens, widget-test]

# Dependency graph
requires:
  - phase: 01-redise-o-turista (plan 01)
    provides: "VelturTokens ThemeExtension contract, TuristaTheme.lightTheme, VelturTokens.of(context) access idiom"
provides:
  - "itinerary_screen.dart's four state branches restyled onto warm tokens — the canonical BLoC state-branch reference (loading/error/empty/loaded) plans 01-06/01-07/01-08 mirror"
  - "itinerary_event_card.dart restyled: primarySoft time pill at Label type role, radiusMd card with an explicit shadowSm wrapper (Card itself stays elevation:0)"
  - "trip_home_screen.dart (1082 lines, largest file in the phase) fully restyled: activity status mapped to safe/warn/textMuted with per-status icons preserved, aviso dialog on warnSoft/warn, hero/trip-card block on radiusXl/radiusMd, _buildStatusBadge and _buildFilterChip theme-driven"
  - "main_shell_screen.dart bottom bar restyled: warm shadow tint, radiusLg (24) corners — the one chrome element visible on every primary Turista screen"
  - "activity_detail_screen.dart fully decoupled from app_colors.dart (Agencia palette) — now reads exclusively from VelturTokens/Theme.of(context)"
affects: ["01-06", "01-07", "01-08", "01-10 (human-verify checkpoint for the populated-itinerary backstop)"]

# Actuals (#2632)
actuals:
  tokens: 11053
  tasks: 3
  commits: 4

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "BLoC state-branch restyle: keep the if (state is X) structure verbatim, restyle only what each branch renders (spinner color, danger banner, EmptyStateWidget routing) — established as the phase's reference pattern on itinerary_screen.dart"
    - "Card + separate shadow Container: when cardTheme forces elevation:0, wrap the Card in a Container carrying matching borderRadius + tokens.shadowX instead of fighting the theme's elevation contract"
    - "Reused shadow tint at a custom offset: when a panel's shadow direction doesn't match a token's baked-in offset (e.g. an upward-floating sheet vs. the token's downward offset), reuse tokens.shadowX.first.color as the tint at the geometry the layout actually needs, rather than force-fitting the token's full BoxShadow"

key-files:
  created:
    - frontend/test/features/turista/home/presentation/widgets/itinerary_event_card_test.dart
  modified:
    - frontend/lib/features/turista/home/presentation/screens/itinerary_screen.dart
    - frontend/lib/features/turista/home/presentation/widgets/itinerary_event_card.dart
    - frontend/lib/features/turista/home/presentation/screens/trip_home_screen.dart
    - frontend/lib/features/turista/home/presentation/screens/main_shell_screen.dart
    - frontend/lib/features/turista/home/presentation/screens/activity_detail_screen.dart

key-decisions:
  - "itinerary_event_card.dart's Card shadow: wrapped the Card in an outer Container carrying borderRadius: radiusMd + boxShadow: tokens.shadowSm, moving the card's bottom margin to that outer Container. The Card itself keeps cardTheme's elevation:0/radiusMd unchanged — this avoids fighting the theme's flat-elevation contract while still getting the warm shadow token."
  - "itinerary_screen.dart's Stack wrapper (single BlocBuilder child, no second child) was removable per the plan's read_first note — confirmed and removed. This produced a large whole-hunk diff (indentation shift) that made the plan's own bloc-wiring git-diff gate (Task 1 acceptance criteria) register 8 false-positive matches on state.items/sl</TripBloc>-adjacent lines; manual whitespace-ignored diff review confirms zero semantic change to bloc wiring — documented as a deviation below."
  - "DraggableScrollableSheet panel shadow (trip_home_screen.dart) floats upward (offset (0,-5)), but VelturTokens.shadowLg's baked-in offset points downward (0,16). Reused tokens.shadowLg.first.color as the warm tint at the original (0,-5) geometry instead of substituting the full token list, since substituting would have inverted the shadow's visual direction."
  - "trip_home_screen.dart hero-slot containers (in-progress activity card AND the mutually-exclusive Trip Card) both treated as the section's 'hero surface' -> radiusXl (32), per the plan's explicit action-text override for this block. Sub-elements within them (image thumbnail, tabs container, progress panel) treated as 'inner cards' -> radiusMd (16), also per that explicit override, even though a naive 1:1 AppBorderRadius.sm->radiusSm mapping would have produced a smaller radius. The plan's action text is the more specific/authoritative source for this one section."
  - "_buildStatusBadge gained a BuildContext first parameter (as scoped in the plan's artifacts_this_phase_produces) — its three call sites (terminada/en_curso/pendiente badges) now pass context and the semantic tokens.safe/tokens.warn/tokens.textMuted instead of Colors.green/orange/grey."

patterns-established:
  - "When a plan-mandated structural simplification (removing a redundant Stack/wrapper) triggers a whole-hunk diff that a mechanical git-diff acceptance gate can't distinguish from a logic change, verify semantic equivalence with `git diff --ignore-all-space` and document the false-positive explicitly rather than either skipping the simplification or silently ignoring the gate."

requirements-completed: [DISENO-TUR-01]

coverage:
  - id: D1
    description: "itinerary_screen.dart's four BLoC state branches (loading/error/empty/loaded) restyled onto warm tokens: terracota spinner, dangerSoft error banner with bloc's own message, EmptyStateWidget-routed empty state with copy preserved verbatim, unchanged ListView.builder for loaded"
    requirement: DISENO-TUR-01
    verification:
      - kind: automated_ui
        ref: "cd frontend && flutter analyze lib/features/turista/home/presentation/screens/itinerary_screen.dart"
        status: pass
      - kind: other
        ref: "grep -c 'No hay eventos planificados.' itinerary_screen.dart == 1; grep -c 'EmptyStateWidget' itinerary_screen.dart == 2"
        status: pass
    human_judgment: false
  - id: D2
    description: "itinerary_event_card.dart: time pill on primarySoft token at full radius with Label type role (14/600), radiusMd card with explicit shadowSm, no maxLines/overflow added to title/description"
    requirement: DISENO-TUR-01
    verification:
      - kind: unit
        ref: "frontend/test/features/turista/home/presentation/widgets/itinerary_event_card_test.dart#renderiza el pill de hora sobre el token primarySoft con radio completo y su etiqueta con el rol tipográfico Label"
        status: pass
      - kind: unit
        ref: "frontend/test/features/turista/home/presentation/widgets/itinerary_event_card_test.dart#una descripción de 300 caracteres se renderiza completa sin elipsis ni maxLines, y la tarjeta crece verticalmente para acomodarla"
        status: pass
    human_judgment: false
  - id: D3
    description: "5+ stacked ItineraryEventCard widgets render without their rendered bounds overlapping — mechanical half of the populated-volume backstop truth"
    requirement: DISENO-TUR-01
    verification:
      - kind: unit
        ref: "frontend/test/features/turista/home/presentation/widgets/itinerary_event_card_test.dart#cinco tarjetas apiladas no superponen sus límites renderizados (mitad mecánica del backstop de volumen poblado)"
        status: pass
    human_judgment: false
  - id: D4
    description: "trip_home_screen.dart fully restyled: activity status -> safe/warn/textMuted tokens with per-status icons preserved, aviso dialog on warnSoft/warn, hero/trip-card block corners/shadows on token scale, _buildStatusBadge/_buildFilterChip theme-driven, zero literal Colors.* or AppBorderRadius remaining, bloc/navigation/permission/l10n lines byte-identical"
    requirement: DISENO-TUR-01
    verification:
      - kind: automated_ui
        ref: "cd frontend && flutter analyze lib/features/turista/home/presentation/screens/trip_home_screen.dart (0 errors)"
        status: pass
      - kind: other
        ref: "scoped literal-colour grep gate + AppBorderRadius grep gate + aviso/status-icon count gates + git diff bloc/nav/perm/l10n gate — all pass per Task 2 acceptance criteria"
        status: pass
    human_judgment: false
  - id: D5
    description: "main_shell_screen.dart bottom bar carries a warm-tinted shadow and radiusLg (24) corners; tab index/onTap/_getTitle/l10n logic byte-identical"
    requirement: DISENO-TUR-01
    verification:
      - kind: other
        ref: "git diff HEAD -- main_shell_screen.dart | grep -cE '_currentIndex|activeIndex|onTap|_getTitle|l10n\\.' == 0; flutter analyze 0 errors"
        status: pass
    human_judgment: false
  - id: D6
    description: "activity_detail_screen.dart no longer imports app_colors.dart or AppBorderRadius; all colors/radii/type sourced from VelturTokens/Theme.of(context); every Spanish string and constructor param preserved"
    requirement: DISENO-TUR-01
    verification:
      - kind: other
        ref: "! grep -q 'theme/app_colors.dart' activity_detail_screen.dart; ! grep -q AppBorderRadius activity_detail_screen.dart; flutter analyze 0 errors"
        status: pass
    human_judgment: false
  - id: D7
    description: "Full visual/UX correctness of the restyled trip home surface in a real running app — vertical rhythm at 5+ itinerary items, hero card legibility over the photographic map background, overall warm cohesion across the largest screen cluster in the phase"
    verification: []
    human_judgment: true
    rationale: "Mechanical tests and grep gates prove token wiring, structural preservation and the two-half backstop's card-overlap mechanics, but not live rendering fidelity (font metrics, photographic-background contrast, real-device shadow appearance). Deferred to plan 01-10's human-verify checkpoint per this plan's own must_haves.assumptions."

duration: 35min
completed: 2026-08-22
status: complete
---

# Phase 01 Plan 05: Turista Home Surface (Itinerario, Trip Home, Tab Shell, Activity Detail) Summary

**Restyled the largest screen cluster in the phase — trip home, tab shell, itinerary list/card, and activity detail — onto VelturTokens, establishing itinerary_screen.dart's four BLoC state branches as the canonical loading/error/empty/loaded reference pattern the rest of the phase copies.**

## Performance

- **Duration:** ~35 min
- **Tasks:** 3/3 completed
- **Files modified:** 6 (5 source files restyled, 1 new widget test file)

## Accomplishments

- `itinerary_screen.dart`'s four state branches (loading/error/empty/loaded) restyled as the phase's reference BLoC treatment: terracota spinner, `dangerSoft` error banner carrying the bloc's own `state.message` untouched, empty state routed through `EmptyStateWidget` with copy preserved verbatim, and the redundant single-child `Stack` wrapper removed.
- `itinerary_event_card.dart`: time pill moved from `primaryContainer` to the `primarySoft` token at the Label type role (14/600), card now carries an explicit `shadowSm` via an outer `Container` (the `Card` itself keeps the theme's flat `elevation: 0`), no `maxLines`/`overflow` added — long descriptions still wrap and grow the card.
- `trip_home_screen.dart` (1082 lines, the largest file in the phase) fully restyled section by section: activity status maps to `safe`/`warn`/`textMuted` tokens while keeping each status's distinct icon; the aviso dialog moved from an amber/orange ad-hoc wash to `warnSoft`/`warn`; the hero (in-progress activity) and Trip Card both promoted to `radiusXl` (32) as the section's hero surfaces, with inner cards (thumbnail, tabs, progress panel) at `radiusMd` (16); `_buildStatusBadge` gained a `BuildContext` parameter and now reads the Label type role; `_buildFilterChip` now uses a `radiusFull` pill shape.
- `main_shell_screen.dart`'s bottom bar — the one chrome element visible behind every primary Turista screen — now carries a warm-tinted shadow and `radiusLg` (24) corners instead of a neutral `Colors.black` shadow and 16px corners.
- `activity_detail_screen.dart` fully decoupled from `app_colors.dart` (the Agencia navy palette) — one of the eight files D-01 targets for removal — now reading exclusively from `VelturTokens.of(context)`/`Theme.of(context)`.
- Zero literal `Colors.*`/`Color(0x...)` and zero `AppBorderRadius`/`AppTextStyles` references remain across all five restyled files; `flutter analyze` reports zero errors project-wide.

## Task Commits

Each task was committed atomically, with Task 1 following the TDD RED → GREEN cycle (tdd="true"):

1. **Task 1: Itinerario — ramas de estado y tarjeta de evento**
   - `4879a9c` (test) — RED: added the 3-test suite against the *original* unrestyled files, confirmed the token-color assertion failed as expected
   - `9cadc15` (feat) — GREEN: restyled `itinerary_screen.dart` and `itinerary_event_card.dart`, all 3 tests pass
2. **Task 2: Pantalla principal del viaje (trip_home_screen)** - `69cfb91` (feat)
3. **Task 3: Shell de pestañas y detalle de actividad** - `1ea793e` (feat)

**Plan metadata:** commit pending (this commit)

## Files Created/Modified

- `frontend/lib/features/turista/home/presentation/screens/itinerary_screen.dart` - Four BLoC state branches restyled; `Stack` wrapper removed
- `frontend/lib/features/turista/home/presentation/widgets/itinerary_event_card.dart` - Time pill on `primarySoft`/Label role; outer `Container` carries `shadowSm`
- `frontend/lib/features/turista/home/presentation/screens/trip_home_screen.dart` - Full restyle: status semantics, aviso dialog, hero/trip-card block, tabs, progress panel, filter chips, `ActivityCard`
- `frontend/lib/features/turista/home/presentation/screens/main_shell_screen.dart` - Bottom bar warm shadow + `radiusLg` corners
- `frontend/lib/features/turista/home/presentation/screens/activity_detail_screen.dart` - `app_colors.dart` import removed; fully token-driven
- `frontend/test/features/turista/home/presentation/widgets/itinerary_event_card_test.dart` - New: 3 tests (token pill/Label role, 300-char no-truncation growth, 5-card no-overlap)

## Decisions Made

- **Card shadow attachment (itinerary_event_card.dart):** wrapped the `Card` in an outer `Container` carrying `borderRadius: tokens.radiusMd` + `boxShadow: tokens.shadowSm`, moving the card's bottom margin to that outer `Container`. The `Card` itself keeps `cardTheme`'s `elevation: 0`/`radiusMd` unmodified — this was chosen over overriding the `Card`'s own `shape`/`elevation` because it keeps `Card` semantics intact for any future `Card`-specific theming while still producing the warm shadow token.
- **Stack removal (itinerary_screen.dart):** confirmed the `Stack` wrapped only the single `BlocBuilder` child (no second child) and removed it per the plan's explicit instruction. See Deviations below for the resulting git-diff gate false positive.
- **Upward-floating panel shadow (trip_home_screen.dart DraggableScrollableSheet):** reused `tokens.shadowLg.first.color` as the tint at the panel's original `(0, -5)` offset/`blurRadius: 10` geometry, rather than substituting the full `tokens.shadowLg` list (whose baked-in offset points downward and would have inverted the shadow's visual direction on this upward-floating sheet).
- **Hero-surface scope (trip_home_screen.dart):** both the in-progress-activity card and the mutually-exclusive Trip Card (same visual slot, alternate display) were treated as the section's "hero surface" and promoted to `radiusXl` (32); their sub-elements (thumbnail, tabs container, progress panel) were treated as "inner cards" at `radiusMd` (16) — following the plan's explicit action-text override for this section rather than a naive 1:1 `AppBorderRadius.sm`→`radiusSm` mapping.
- **`_buildStatusBadge` signature:** added a `BuildContext` first parameter (as anticipated in the plan's `artifacts_this_phase_produces`), updated all three call sites to pass `context` and the semantic `tokens.safe`/`tokens.warn`/`tokens.textMuted` colors.

## Deviations from Plan

**1. [Documented false positive] Task 1's bloc-wiring git-diff acceptance gate registered 8 matches despite zero semantic change**
- **Found during:** Task 1, post-implementation acceptance-criteria verification
- **Issue:** The plan's fifth acceptance criterion for Task 1 (`git diff HEAD -- itinerary_screen.dart | grep -cE '(ItineraryBloc|LoadItinerary|state\.items|sl<)'` expected to be `0`) returned `8` after removing the single-child `Stack` wrapper (an explicitly plan-mandated simplification, confirmed via `read_first` that the `Stack` had no second child).
- **Root cause:** Removing the `Stack` dedents the entire `BlocBuilder` subtree by one level. Because the branches within that subtree were simultaneously rewritten (loading/error/empty restyled), git's diff algorithm treated the whole block as one replaced hunk rather than matching unchanged lines at their new indentation — so lines like `state.items.isEmpty`, `itemCount: state.items.length`, and `final item = state.items[index]` show as removed+added even though their content is byte-identical, only their leading whitespace changed.
- **Verification:** Re-ran the same `git diff` with `--ignore-all-space` and manually inspected every matched line — confirmed all four matched lines are pure re-indentation with zero content change (see the "Issues Encountered" detail below for the exact diff).
- **Files affected:** `frontend/lib/features/turista/home/presentation/screens/itinerary_screen.dart`
- **Committed in:** `9cadc15`

---

**Total deviations:** 1 documented false positive (no code change required — the gate itself cannot distinguish reindentation from logic change when combined with an explicitly-mandated structural simplification in the same hunk).
**Impact on plan:** None on functionality — `state.items`/`ItineraryBloc`/`sl<...>` wiring is provably untouched by manual whitespace-ignored diff review. The `Stack` removal itself was explicitly instructed by the plan's `read_first` note.

## Issues Encountered

- The `git diff --ignore-all-space` review for the Task 1 false positive above showed the four flagged lines matching content-for-content across the diff (only whitespace differs):
  ```
  -          BlocBuilder<ItineraryBloc, ItineraryState>(          (10 spaces, inside Stack)
  +      body: BlocBuilder<ItineraryBloc, ItineraryState>(        (6 spaces, direct Scaffold.body)
  -                if (state.items.isEmpty) {
  +              if (state.items.isEmpty) {
  -                  itemCount: state.items.length,
  +              itemCount: state.items.length,
  -                    final item = state.items[index];
  +                final item = state.items[index];
  ```
  Confirmed no logic change — only indentation shifted from the `Stack` removal, and the `BlocBuilder<ItineraryBloc, ItineraryState>(` line's own prefix changed from nothing to `body:` (expected, since it's now assigned directly to `Scaffold.body` instead of being a `Stack` child).
- No other issues. `flutter analyze` reported zero errors across all five restyled files on first pass except a transient `int`/`double` type mismatch on `main_shell_screen.dart`'s `leftCornerRadius`/`rightCornerRadius` (expected `double?`, not `int`) — fixed immediately by dropping an unnecessary `.toInt()` conversion, verified clean on re-analysis.

## Next Phase Readiness

- `itinerary_screen.dart`'s four-branch restyle is now the concrete reference implementation plans 01-06, 01-07 and 01-08 should mirror for their own BLoC-driven screens.
- `main_shell_screen.dart`'s warm bottom bar is live behind every primary Turista tab, closing out the one piece of persistent chrome that touches every screen in the pitch video.
- No blockers. The populated-itinerary backstop (5+ cards, vertical rhythm at real device rendering) remains flagged for plan 01-10's human-verify checkpoint, per this plan's documented assumption — the mechanical half (no rendered-bounds overlap) is proven by `itinerary_event_card_test.dart`.

---
*Phase: 01-redise-o-turista*
*Completed: 2026-08-22*
