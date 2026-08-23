---
phase: 01-redise-o-turista
reviewed: 2026-08-23T00:00:00Z
depth: standard
files_reviewed: 29
files_reviewed_list:
  - frontend/lib/core/theme/turista_colors.dart
  - frontend/lib/core/theme/veltur_tokens.dart
  - frontend/lib/core/theme/turista_theme.dart
  - frontend/test/core/theme/turista_theme_test.dart
  - frontend/test/core/widgets/empty_state_widget_test.dart
  - frontend/pubspec.yaml
  - frontend/pubspec.lock
  - frontend/lib/main_turista.dart
  - frontend/lib/core/widgets/empty_state_widget.dart
  - frontend/lib/features/turista/chat/presentation/widgets/chat_bubble.dart
  - frontend/test/core/widgets/shared_widgets_theme_test.dart
  - frontend/lib/core/widgets/saving_overlay.dart
  - frontend/lib/core/widgets/info_modal.dart
  - frontend/lib/core/widgets/phone_number_field.dart
  - frontend/test/features/turista/home/presentation/widgets/walkie_talkie_button_test.dart
  - frontend/lib/features/turista/home/presentation/widgets/walkie_talkie_button.dart
  - frontend/lib/features/turista/home/presentation/screens/comunicacion_seguridad_screen.dart
  - frontend/lib/features/turista/chat/presentation/screens/chat_screen.dart
  - frontend/lib/features/turista/chat/presentation/widgets/message_input_field.dart
  - frontend/lib/core/tools/presentation/screens/currency_converter_screen.dart
  - frontend/test/features/turista/home/presentation/widgets/itinerary_event_card_test.dart
  - frontend/lib/features/turista/home/presentation/screens/itinerary_screen.dart
  - frontend/lib/features/turista/home/presentation/widgets/itinerary_event_card.dart
  - frontend/lib/features/turista/home/presentation/screens/trip_home_screen.dart
  - frontend/lib/features/turista/home/presentation/screens/main_shell_screen.dart
  - frontend/lib/features/turista/home/presentation/screens/activity_detail_screen.dart
  - frontend/lib/features/turista/home/presentation/screens/map_screen.dart
  - frontend/lib/features/turista/home/presentation/screens/mapa_itinerario_screen.dart
  - frontend/lib/features/turista/home/presentation/screens/pantalla_emergencia_turista.dart
findings:
  critical: 2
  warning: 4
  info: 3
  total: 9
status: issues_found
---

# Phase 01: Code Review Report

**Reviewed:** 2026-08-23T00:00:00Z
**Depth:** standard
**Files Reviewed:** 29
**Status:** issues_found

## Summary

This phase re-skins the Turista app onto a warm terracota/teal token system (`TuristaColors` → `VelturTokens` → `TuristaTheme`), and the mechanical token-substitution work across screens is careful and well-tested (theme, empty-state, chat bubble, walkie-talkie decoration, and shared-widget tests all assert on the new tokens rather than hardcoded literals). However, two defects undercut the phase's stated goal ("the redesign must look cared-for and credible throughout the app, not just in 3 isolated screens"):

1. `main_turista.dart` still wires the app's `darkTheme` to the old, unrelated `AppTheme.darkTheme` (which never registers `VelturTokens`), and `ThemeCubit` defaults to `ThemeMode.system`. Any demo device with system dark mode on (very common) will silently drop out of the warm redesign into a visually broken mix of the legacy palette and `VelturTokens.fallback`.
2. `mapa_itinerario_screen.dart`'s map legend was recolored to match the new status tokens, but the actual map markers were not updated to match — the legend now lies about what marker color means "pending."

Several smaller correctness/robustness gaps (missing `mounted` guard before a socket-triggered `showDialog`, a semantically confusing reuse of `colorScheme.surface` as a text color, an unclosed `TextRecognizer` on the OCR error path, and a new pure-network font dependency with no offline fallback) round out the findings below.

## Critical Issues

### CR-01: Dark/system theme mode breaks the entire warm redesign

**File:** `frontend/lib/main_turista.dart:89-93`
**Issue:** `MaterialApp.router` is configured with `theme: TuristaTheme.lightTheme` (the new warm theme, which registers `VelturTokens`) but `darkTheme: AppTheme.darkTheme` — a completely unrelated legacy theme (`frontend/lib/core/theme/app_theme.dart:53-99`) that uses `AppColors` (not `TuristaColors`) and never registers a `VelturTokens` extension. `themeMode` is bound to `ThemeCubit`, whose initial state is `ThemeMode.system` (`frontend/lib/features/turista/settings/presentation/cubit/theme_cubit.dart:8`) and is only overridden once the user has explicitly toggled a setting (`sharedPreferences.getBool('isDarkMode')` starts `null`).

Practical impact: on any device/emulator with OS-level dark mode enabled (a very common default, including on demo hardware), the app renders `AppTheme.darkTheme` instead of the redesigned theme. Every widget that calls `VelturTokens.of(context)` (the vast majority of the screens touched in this phase) silently falls back to `VelturTokens.fallback` — i.e. the *light* warm tokens — while the surrounding `Theme.of(context)` values (colorScheme, textTheme, appBarTheme, cardTheme, bottomNavigationBarTheme, etc.) come from the dark legacy palette. The result is an incoherent mashup: e.g. `SavingOverlay` sets both its spinner-circle background (`theme.colorScheme.surface`) and its loading-text color (also `theme.colorScheme.surface`) to the *same* value; under `AppTheme.darkTheme` that value is `Color(0xFF1E1E1E)` (near-black), so the message text becomes nearly invisible against the backdrop. `main_shell_screen.dart`'s bottom nav bar likewise reads `Theme.of(context).bottomNavigationBarTheme.selectedItemColor`, which under the dark theme is the old `AppColors.primary`, not the new terracota primary.

This is exactly the failure mode the phase is meant to prevent ("no solo en 3 pantallas aisladas") — a single OS setting undoes the whole redesign across the app for the pitch demo.

**Fix:** Either give `TuristaTheme` a proper dark variant that also registers `VelturTokens` (with dark-appropriate values) and wire it as `darkTheme:`, or — simpler for a design-phase milestone with a 2-week deadline — force the app to the light theme regardless of system setting until a dark variant exists:
```dart
return MaterialApp.router(
  title: 'Turista App',
  theme: TuristaTheme.lightTheme,
  themeMode: ThemeMode.light, // no warm dark theme yet — don't silently fall back
  // darkTheme: intentionally omitted/removed until D-0x defines dark tokens
  ...
);
```
At minimum, gate `ThemeCubit`'s dark option out of the UI (settings screen) until a real dark `VelturTokens` instance exists, so the app can never end up in this state during the demo.

### CR-02: Map legend no longer matches the marker colors it describes

**File:** `frontend/lib/features/turista/home/presentation/screens/mapa_itinerario_screen.dart:73-79` (markers) vs `:218-226` (legend)
**Issue:** `_buildMarkers()` still colors pending-itinerary markers with `BitmapDescriptor.hueAzure` (blue):
```dart
icon: BitmapDescriptor.defaultMarkerWithHue(
  items[i].endTime.isBefore(now)
      ? BitmapDescriptor.hueGreen
      : items[i].startTime.isBefore(now)
      ? BitmapDescriptor.hueOrange
      : BitmapDescriptor.hueAzure,   // <-- still blue
),
```
but the on-screen legend was updated by this phase to describe "Pendiente" with `tokens.textMuted` (a warm gray-brown), replacing the previous `Colors.blue`:
```dart
_LegendItem(color: tokens.textMuted, label: 'Pendiente'),
```
The legend swatch color and the actual pin color for the same status ("pending") no longer agree. A user reading the legend to interpret the map (exactly its purpose) will not be able to find a gray-brown pin — every "pending" item still renders as a blue pin.

**Fix:** Keep both in sync. Either restyle the marker hue to something derivable from the same warm token (Google Maps markers only accept a `hue` value, so an exact token color isn't possible, but pick the closest matching hue, e.g. keep `hueAzure` and also keep the legend blue, or pick `hueViolet`/`hueRose` if you want the legend to move):
```dart
// Option: keep legend and marker aligned on the same semantic hue
_LegendItem(color: Colors.blue, label: 'Pendiente'), // matches BitmapDescriptor.hueAzure
```
or update the marker hue to whichever `BitmapDescriptor.hue*` most closely resembles the new legend color, and add a code comment tying the two together so they don't drift again.

## Warnings

### WR-01: `google_fonts` is a new pure-runtime-network dependency with no offline fallback

**File:** `frontend/pubspec.yaml:35`, `frontend/lib/core/theme/turista_theme.dart:74`
**Issue:** This phase adds `google_fonts: ^8.2.1` as a direct dependency and uses `GoogleFonts.poppinsTextTheme(...)` to build the entire text theme. By default, `google_fonts` fetches the font file(s) over the network on first use and falls back to the platform default font until the download completes (or fails). No font assets are bundled in `pubspec.yaml`'s `assets:` list, and `GoogleFonts.config.allowRuntimeFetching` is not set to `false` anywhere.

Given this project's stated offline-first ambitions and the concrete requirement that the demo/pitch video "se sienta como un producto real," a connectivity hiccup on a demo device (or a fresh install with `flutter run` on the day of recording, without cached fonts) means the whole app first renders in a fallback system font, and dependent layout metrics (e.g. any hand-tuned `FittedBox`/`Wrap` sizing) could shift once the font swaps in mid-recording.
**Fix:** Bundle the Poppins `.ttf` files as local Flutter font assets and declare them in `pubspec.yaml`'s `flutter: fonts:` section, then load via `TextTheme(fontFamily: 'Poppins', ...)` instead of `GoogleFonts.poppinsTextTheme`, or at minimum call `GoogleFonts.config.allowRuntimeFetching = false;` early in `main()` after confirming fonts are pre-cached, so a missing network connection can't silently degrade the redesign during a recording session.

### WR-02: Socket-triggered dialog doesn't guard against a disposed context

**File:** `frontend/lib/features/turista/home/presentation/screens/trip_home_screen.dart:87-123`
**Issue:** `_mostrarAlertaEnPantalla` is invoked directly from a Socket.IO event handler (`socket!.on('alertaAmarilla', ...)` at line 81-84) with no `mounted` check:
```dart
socket!.on('alertaAmarilla', (data) {
  debugPrint('Turista recibió alertaAmarilla: $data');
  _mostrarAlertaEnPantalla(data['mensaje']);
});

void _mostrarAlertaEnPantalla(String mensaje) {
  final tokens = VelturTokens.of(context);   // no `if (mounted)` guard
  showDialog(context: context, ...);
}
```
If this event arrives after the user has navigated away from `TripHomeScreen` (and before `dispose()`'s `socket?.disconnect()` has actually severed the connection — sockets are inherently async), `VelturTokens.of(context)`/`showDialog(context: context)` will be called on a deactivated element, which Flutter treats as a programmer error (`"Looking up a deactivated widget's ancestor is unsafe"`) and can crash in debug or misbehave in release. Other handlers in the sibling `walkie_talkie_button.dart` (`canalDenegado`) do guard with `if (mounted)` — this call site is the inconsistent one.
**Fix:**
```dart
void _mostrarAlertaEnPantalla(String mensaje) {
  if (!mounted) return;
  final tokens = VelturTokens.of(context);
  showDialog(context: context, ...);
}
```

### WR-03: `SavingOverlay` reuses a background-role token (`colorScheme.surface`) as foreground text color

**File:** `frontend/lib/core/widgets/saving_overlay.dart:59-107`
**Issue:** Both the spinner-circle background and the loading message's text color are set to `theme.colorScheme.surface`:
```dart
Container(
  decoration: BoxDecoration(color: theme.colorScheme.surface, ...),  // circle background
  ...
),
...
Text(
  mensaje,
  style: theme.textTheme.titleMedium?.copyWith(
    color: theme.colorScheme.surface,   // also "surface" — used here as *text* color
    ...
  ),
),
```
This happens to work today only because `TuristaColors.surface` is hardcoded white and the widget is designed on the assumption that `colorScheme.surface` is always light enough to read as "white text over a blurred dark backdrop." It is a semantically confusing reuse of a background-role token as a foreground role, and it is precisely the kind of coupling that breaks under `AppTheme.darkTheme` (see CR-01), where `colorScheme.surface` is `Color(0xFF1E1E1E)`.
**Fix:** Introduce a dedicated "overlay foreground" concept (e.g. always `Colors.white` for this specific always-on-dark-scrim widget, or a new semantic token such as `tokens.onOverlay`) instead of repurposing `colorScheme.surface`.

### WR-04: `TextRecognizer` is not closed if OCR processing throws

**File:** `frontend/lib/core/tools/presentation/screens/currency_converter_screen.dart:148-191`
**Issue:** `_extractTextFromImage` creates a `TextRecognizer`, calls `processImage`, and only calls `textRecognizer.close()` after a successful result:
```dart
final textRecognizer = TextRecognizer();
final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
... // parsing
await textRecognizer.close();
```
If `processImage` (or anything between construction and `close()`) throws, execution jumps to the `catch` block, which never calls `textRecognizer.close()`. `TextRecognizer` wraps a native ML Kit resource; repeated failed OCR attempts (e.g. a blurry photo, a corrupted file, or the model failing to load) leak native recognizer instances for the lifetime of the app.
**Fix:**
```dart
final textRecognizer = TextRecognizer();
try {
  final recognizedText = await textRecognizer.processImage(inputImage);
  // ... parsing / setState ...
} finally {
  await textRecognizer.close();
}
```

## Info

### IN-01: Itinerary event time is not zero-padded

**File:** `frontend/lib/features/turista/home/presentation/screens/itinerary_screen.dart:84-88`
**Issue:** `'${item.startTime.hour}:${item.startTime.minute.toString().padLeft(2, '0')}'` pads the minute but not the hour, so times before 10:00 render as `9:05` while the itinerary-map screen's own `_fmt` helper (`mapa_itinerario_screen.dart:155-156`) correctly zero-pads both (`09:05`). This screen was otherwise materially reworked by this phase (new `EmptyStateWidget`/error card), so it's a reasonable place to also fix the inconsistency.
**Fix:** `'${item.startTime.hour.toString().padLeft(2, '0')}:${item.startTime.minute.toString().padLeft(2, '0')}'`.

### IN-02: Shadow tint literal duplicated instead of derived from `TuristaColors.shadowTint`

**File:** `frontend/lib/core/theme/turista_theme.dart:38-70`, `frontend/lib/core/theme/veltur_tokens.dart:98-125`
**Issue:** `TuristaColors.shadowTint = Color(0xFF2B1D14)` is declared as the canonical warm shadow tint, but no code path actually reads it — `turista_theme.dart` re-derives the same ARGB values as five separate raw `Color(0x0F2B1D14)`/`Color(0x1A2B1D14)`/etc. literals (only annotated with a comment saying which percentage of `shadowTint` they represent), and `veltur_tokens.dart`'s `VelturTokens.fallback` duplicates those same five literals a third time, independently. If `shadowTint` (or any shadow opacity) is ever revised, all of these sites must be hand-updated in lockstep, or the theme, the token fallback, and the documented "source of truth" constant silently drift apart.
**Fix:** Compute the tinted shadow colors from `TuristaColors.shadowTint.withValues(alpha: ...)` at the single call site (`turista_theme.dart`), and have `VelturTokens.fallback` reuse `TuristaTheme.tokens`'s values (or a shared constant) rather than re-literal-izing them.

### IN-03: Demo-mode socket URL is hardcoded and duplicated

**File:** `frontend/lib/features/turista/home/presentation/widgets/walkie_talkie_button.dart:61`, `frontend/lib/features/turista/home/presentation/screens/trip_home_screen.dart:58`
**Issue:** The non-demo Socket.IO server URL `'http://10.170.6.0:3000'` (a private-network IP, presumably a specific developer's machine) is hardcoded identically in two separate files rather than being defined once alongside `kDemoServerUrl`/`kDemoMode` in `frontend/lib/core/demo/demo_config.dart`. This is unrelated to the redesign itself but was left untouched by this phase in both files it edited.
**Fix:** Hoist to a single named constant (e.g. `kLiveServerUrl`) in `demo_config.dart` so there is one place to update it.

---

_Reviewed: 2026-08-23T00:00:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
