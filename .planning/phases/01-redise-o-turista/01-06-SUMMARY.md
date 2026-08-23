---
phase: 01-redise-o-turista
plan: 06
subsystem: ui

tags: [flutter, theme, design-system, google-maps, veltur-tokens]

# Dependency graph
requires:
  - phase: 01-01
    provides: "VelturTokens ThemeExtension contract, TuristaTheme.lightTheme, VelturTokens.of(context) access pattern"
provides:
  - "map_screen.dart and mapa_itinerario_screen.dart restyled onto VelturTokens — zone overlay, SOS control, detail sheet and legend all read from tokens instead of raw Colors.*/Color(0x literals"
  - "The itinerary-map legend (Completada/En curso/Pendiente) unified to the exact same safe/warn/textMuted tokens trip_home_screen.dart's ActivityStatus switch uses"
  - "pantalla_emergencia_turista.dart's full-bleed ground moved from a raw red-900 ARGB literal to VelturTokens.danger, matching the SOS control's token so the two surfaces read as one alarm affordance"
affects: ["01-10 (human-verify checkpoint for map-overlay contrast and emergency-screen urgency)"]

# Actuals (#2632)
actuals:
  tokens: 3600
  tasks: 2
  commits: 2

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Map overlay colors (Circle fillColor/strokeColor) sourced from VelturTokens while preserving their original alpha split, so warm tokens don't cost a live-tile overlay its contrast"
    - "Cross-screen status vocabulary: any screen showing 'completed/in-progress/pending' state reads tokens.safe/tokens.warn/tokens.textMuted, matching trip_home_screen.dart's ActivityStatus switch"

key-files:
  created: []
  modified:
    - frontend/lib/features/turista/home/presentation/screens/map_screen.dart
    - frontend/lib/features/turista/home/presentation/screens/mapa_itinerario_screen.dart
    - frontend/lib/features/turista/home/presentation/screens/pantalla_emergencia_turista.dart

key-decisions:
  - "map_screen.dart's 'safe_zone' Circle read as the safety/proximity boundary this product is built around (not a decorative accuracy circle) — recolored to tokens.safe, keeping the exact 0.2/0.5 alpha split the plan pinned as an acceptance criterion."
  - "map_screen.dart's SOS control (raw red fill + SnackBar red + ad-hoc shadow) unified to tokens.danger + tokens.shadowGlowDanger + tokens.radiusFull, matching the comunicacion_seguridad_screen.dart SOS treatment from plan 01-03 so both SOS entry points read as one affordance."
  - "pantalla_emergencia_turista.dart's pulsing-circle border opacity raised 0.38 -> 0.5 and the footnote text opacity raised 0.55 -> 0.68: the new danger token (#E5484D) is measurably lighter/more saturated than the old red-900 literal it replaced, so a white-on-background contrast estimate showed both of those tiers losing roughly a quarter of their original contrast against the lighter ground. Raised per the plan's explicit instruction to bump opacity rather than darken the ground. The other three white tiers (100%, 70%, 60%) and the decorative circle fill (15%) were left untouched — the plan only flagged the 38% and 55% tiers as at risk."

patterns-established: []

requirements-completed: [DISENO-TUR-01]

coverage:
  - id: D1
    description: "map_screen.dart's zone overlay and SOS control read VelturTokens (safe for the boundary circle at its original alpha split, danger + shadowGlowDanger + radiusFull for SOS), with zero raw Colors.*/Color(0x literals and zero map-mechanic (marker/camera/geolocation) lines touched"
    requirement: DISENO-TUR-01
    verification:
      - kind: other
        ref: "cd frontend && flutter analyze lib/features/turista/home/presentation/screens/map_screen.dart -- 0 issues"
        status: pass
      - kind: other
        ref: "scoped literal-colour grep (Colors.red|...|Color(0x) over map_screen.dart -- 0 matches"
        status: pass
      - kind: other
        ref: "git diff HEAD~2..HEAD -- map_screen.dart | grep -c 'Marker(|Polyline|CameraPosition|GoogleMapController|MapController|LatLng(|Geolocator|onTap:' -- 0"
        status: pass
      - kind: other
        ref: "grep -c 'alpha: 0.2' and 'alpha: 0.5' in map_screen.dart -- both 1 (alpha split preserved)"
        status: pass
    human_judgment: false
  - id: D2
    description: "mapa_itinerario_screen.dart's detail sheet (radius/drag-handle/typography) and legend card moved to VelturTokens/theme text roles; the three legend states (Completada/En curso/Pendiente) match the exact safe/warn/textMuted tokens trip_home_screen.dart uses for ActivityStatus.finished/inProgress/pending"
    requirement: DISENO-TUR-01
    verification:
      - kind: other
        ref: "cd frontend && flutter analyze lib/features/turista/home/presentation/screens/mapa_itinerario_screen.dart -- 0 issues"
        status: pass
      - kind: other
        ref: "grep -c 'Completada'/'En curso'/'Pendiente' in mapa_itinerario_screen.dart -- each exactly 1"
        status: pass
      - kind: other
        ref: "cross-file token comparison: mapa_itinerario_screen.dart tokens.safe/tokens.warn/tokens.textMuted vs trip_home_screen.dart tokens.safe/tokens.warn/tokens.textMuted for finished/inProgress/pending -- identical token names"
        status: pass
    human_judgment: false
  - id: D3
    description: "pantalla_emergencia_turista.dart's ground moved from a raw Color(0xFFB71C1C) literal to VelturTokens.danger, all five white-opacity foreground tiers preserved (two raised for contrast per key-decisions), close handler/pulse animation/socket path untouched, no calming treatment (shadow/rounded card) added"
    requirement: DISENO-TUR-01
    verification:
      - kind: other
        ref: "cd frontend && flutter analyze lib/features/turista/home/presentation/screens/pantalla_emergencia_turista.dart -- 0 issues"
        status: pass
      - kind: other
        ref: "grep -qE 'Color\\(0x' over pantalla_emergencia_turista.dart -- 0 matches (ARGB ground literal gone)"
        status: pass
      - kind: other
        ref: "grep -c 'Colors.white' pantalla_emergencia_turista.dart -- 8 (>= 5 required, full opacity hierarchy intact)"
        status: pass
      - kind: other
        ref: "grep -q 'fontSize' pantalla_emergencia_turista.dart -- 0 matches (type fully theme-driven)"
        status: pass
      - kind: other
        ref: "git diff HEAD~1..HEAD -- pantalla_emergencia_turista.dart | grep -c 'DemoSocketService|Navigator\\.|onPressed|AnimationController|Timer' -- 0"
        status: pass
    human_judgment: false
  - id: D4
    description: "Live visual correctness: map-overlay contrast against real Google Maps tiles, and the emergency screen still reading as an unmistakable alarm at a glance -- neither can be judged from static analysis or grep"
    verification: []
    human_judgment: true
    rationale: "This plan's own threat model (T-01-06-I, T-01-06-D) explicitly routes both concerns to plan 01-10's human-verify checkpoint since no widget test renders live map tiles or gives a 'does this still look urgent' judgment. Mechanical gates in D1-D3 prove the token wiring and alpha/opacity preservation; the visual outcome itself is deferred by design."

duration: 25min
completed: 2026-08-23
status: complete
---

# Phase 01 Plan 06: Mapas y pantalla de emergencia cálidos Summary

**Turista's two map surfaces and the SOS emergency screen restyled onto VelturTokens (safe-token zone overlay, danger-token SOS control with radiusFull + shadowGlowDanger, unified status-legend vocabulary, and a danger-token alarm ground) with zero map-mechanic or handler lines touched.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 2/2 completed
- **Files modified:** 3

## Accomplishments

- `map_screen.dart`: the "safe_zone" `Circle` (the group-proximity boundary concept the product is built around) now reads `tokens.safe` at its original 0.2/0.5 alpha split; the SOS floating control unified to `tokens.danger` + `tokens.shadowGlowDanger` + `tokens.radiusFull`, matching the SOS treatment plan 01-03 built on `comunicacion_seguridad_screen.dart` so both SOS entry points feel like the same affordance.
- `mapa_itinerario_screen.dart`: the event detail bottom sheet's radius, drag handle, title/meta/body typography and the legend card now read from `VelturTokens`/theme text roles; the three legend states (Completada/En curso/Pendiente) were cross-checked token-for-token against `trip_home_screen.dart`'s `ActivityStatus` switch and match exactly (`safe`/`warn`/`textMuted`).
- `pantalla_emergencia_turista.dart`: the full-bleed ground moved from a raw `Color(0xFFB71C1C)` literal to `VelturTokens.danger`; all five white-opacity foreground tiers were kept, with the two lightest (38% border, 55% footnote) raised to 50%/68% after a contrast estimate showed the lighter danger token cost them meaningful legibility. No calming treatment (shadow, rounded card, softened corners) was added — the screen still reads as a full-bleed alarm.
- Every marker construction, polyline, camera position, map-controller call, close handler, pulse animation and socket call across all three files is byte-identical to before this plan — confirmed via scoped `git diff` greps on each task's `<acceptance_criteria>`.

## Task Commits

Each task was committed atomically:

1. **Task 1: Mapas — superposiciones, controles y hoja de detalle** - `fc9088a` (feat)
2. **Task 2: Pantalla de emergencia — token de peligro sin perder la alarma** - `dbc8757` (feat)

## Files Created/Modified

- `frontend/lib/features/turista/home/presentation/screens/map_screen.dart` - Zone overlay recolored to `tokens.safe` (alpha split preserved), SOS control moved to `tokens.danger`/`shadowGlowDanger`/`radiusFull`, label text moved to `textTheme.bodyLarge`
- `frontend/lib/features/turista/home/presentation/screens/mapa_itinerario_screen.dart` - Detail sheet radius/drag-handle/typography moved to `VelturTokens`/theme text roles, legend card moved to `surface`/`radiusMd`/`shadowSm`, legend colors unified to `safe`/`warn`/`textMuted`
- `frontend/lib/features/turista/home/presentation/screens/pantalla_emergencia_turista.dart` - Ground moved to `tokens.danger`, heading/subtitle/hint/footnote moved to `textTheme.headlineSmall`/`titleLarge`/`labelLarge`, two lightest white-opacity tiers raised for contrast

## Decisions Made

- The `map_screen.dart` zone circle was read as a safety/proximity boundary (not a decorative accuracy circle) because the app's whole premise is group-radius alerting — `tokens.safe` fits that semantic better than `accentTeal`, which the UI spec reserves for decorative/secondary use only.
- Raised two white-opacity tiers on the emergency screen (border 38%→50%, footnote 55%→68%) rather than darkening the danger ground, per the plan's explicit instruction — a perceived-luminance estimate showed both tiers losing roughly 25% of their contrast against the new, lighter danger token compared to the old red-900 literal.

## Deviations from Plan

None - plan executed exactly as written. Both `<read_first>` reference files (`comunicacion_seguridad_screen.dart` for the SOS treatment, `trip_home_screen.dart` for the status-token vocabulary) were read and matched exactly as instructed.

## Issues Encountered

None.

## Next Phase Readiness

- All 6 plans of Phase 01 (Rediseño Turista) are now complete; `DISENO-TUR-01` is fully implemented across theme foundation, shared widgets, walkie-talkie/chat, itinerary, home surfaces, and now maps/emergency.
- Live visual verification (map-overlay contrast on real tiles, emergency-screen urgency at a glance) is deferred to plan 01-10's human-verify checkpoint per this plan's threat model — no blockers, just an intentionally deferred judgment call.
- No blockers for Phase 02 (Guía) — Guía reuses the same `VelturTokens` contract and can follow this plan's cross-screen status-vocabulary pattern for its own map/monitoring screens.

---
*Phase: 01-redise-o-turista*
*Completed: 2026-08-23*
