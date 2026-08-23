# Phase 1: Rediseño Turista - Context

**Gathered:** 2026-08-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Rediseño visual de la app Turista completa (todas las pantallas: login, home, walkie-talkie, chat, itinerario, perfil, ajustes, conversor de divisas) hacia un sistema de diseño cálido y consistente (terracota/teal, tipografía redondeada, radios grandes, sombras suaves). Se construye el sistema de diseño reutilizable (`frontend/lib/core/theme/`, `frontend/lib/core/widgets/`) para que la Fase 2 (Guía) lo reutilice. Solo visual/UX — no se tocan flujos, lógica de negocio ni el backend demo Socket.IO.

</domain>

<decisions>
## Implementation Decisions

### Alcance del tema
- **D-01:** El tema compartido (`frontend/lib/core/theme/app_theme.dart`) NO se modifica in-place. Se crea un tema específico para Turista (ej. `TuristaTheme` / `frontend/lib/core/theme/turista_theme.dart` o equivalente) que Turista consume, dejando la Agencia intacta con el navy actual hasta su propia fase futura. La Fase 2 (Guía) creará su propio tema análogo reutilizando los mismos tokens/componentes base. — **Reversibility:** reversible — es una decisión de estructura de archivos, fácil de consolidar después si se decide unificar.
- **D-02:** Componentes de UI compartidos (`frontend/lib/core/widgets/`) se generalizan para aceptar los nuevos tokens de tema en vez de tener estilos hardcodeados, de modo que sean reutilizables entre Turista y Guía sin duplicar widgets.

### Paleta de color
- **D-03:** Se usa la paleta `default.css` de `.planning/sketches/themes/default.css` (terracota + teal cálido), NO la variante `brand.css` (navy + acentos). Tokens exactos:
  - Fondo: `#fff8f0` / Superficie: `#ffffff` / Superficie cálida: `#fff2e6` / Borde: `#f0e2d4`
  - Texto: `#2b1d14` / Texto secundario: `#8a7669`
  - Primario (terracota): `#e8623d` (hover `#d1502e`, soft `#fce3da`)
  - Acento (teal): `#1fada0` (soft `#d9f3f0`)
  - Estados: seguro `#3cb371`/`#e1f5e9`, advertencia `#f2a03d`/`#fdecd4`, peligro `#e5484d`/`#fbe0e1`

### Tipografía
- **D-04:** Se agrega el paquete `google_fonts` a `pubspec.yaml` para cargar Poppins/Nunito dinámicamente (fuente principal: Poppins con fallback a Nunito, per `.planning/sketches/themes/default.css` `--font-sans`). No se empaquetan archivos `.ttf` localmente.

### Radios y sombras
- **D-05:** Radios: sm=10px, md=16px, lg=24px, xl=32px, full=9999px (reemplaza los radios actuales de 5-8px). Sombras suaves con tinte cálido (`rgba(43,29,20,...)`) en vez de `Colors.black12` genérico — ver tokens `--shadow-sm/md/lg` en `default.css`.

### Modo oscuro
- **D-06:** Fuera de alcance de esta fase. `dark_theme.dart` no se toca; el rediseño cubre solo el tema claro. Anotar como deferred idea para cuando se decida si Turista necesita dark mode cálido.

### Claude's Discretion
- Nombre exacto de archivos/clases para el tema de Turista (ej. `turista_theme.dart` vs `app_theme_turista.dart`) — seguir la convención `snake_case` existente y el patrón de `app_theme.dart`.
- Cómo generalizar exactamente los widgets compartidos en `core/widgets/` (parámetros de tema vs extensión de ThemeData) — decisión de implementación, no de producto.
- Mapeo fino de qué elementos de UI usan radio `sm` vs `md` vs `lg` en cada pantalla.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Dirección de diseño (sketches)
- `.planning/sketches/MANIFEST.md` — contexto y decisiones de la ronda de sketches (referencia de dirección, NO plantilla literal — las apps reales tienen muchas más pantallas que los 3 sketches)
- `.planning/sketches/themes/default.css` — tokens exactos de color/tipografía/radio/sombra a portar a Flutter (fuente de verdad de esta fase)
- `.planning/sketches/002-turista-walkie-talkie/` — sketch de referencia visual para la pantalla de walkie-talkie
- `.planning/sketches/003-conversor-divisas/` — sketch de referencia visual para el conversor de divisas

### Proyecto
- `.planning/PROJECT.md` — contexto de negocio y alcance del milestone
- `.planning/REQUIREMENTS.md` — DISENO-TUR-01/02/03

### Codebase (tema actual a reemplazar)
- `frontend/lib/core/theme/app_colors.dart` — colores actuales (navy `#1E407D`) a reemplazar en el tema de Turista
- `frontend/lib/core/theme/app_theme.dart` — ThemeData actual (radios 5-8px, elevaciones planas) — patrón a seguir para construir el nuevo tema de Turista
- `frontend/lib/core/theme/dark_theme.dart` — NO modificar en esta fase

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `frontend/lib/core/theme/app_theme.dart`: patrón existente de `ThemeData` con `colorScheme`, `elevatedButtonTheme`, `textTheme`, `cardTheme`, `bottomNavigationBarTheme` — usar como esqueleto para el nuevo tema de Turista
- `frontend/lib/core/widgets/`: `empty_state_widget.dart`, `info_modal.dart`, `phone_number_field.dart`, `saving_overlay.dart` — widgets compartidos a generalizar con los nuevos tokens

### Established Patterns
- DI vía GetIt (`frontend/lib/core/di/turista_locator.dart`) — el tema se inyecta o se referencia directo desde `main_turista.dart`, no vía DI
- Cada app tiene su propio entry point (`main_turista.dart`) que construye su `MaterialApp` — es el punto natural para aplicar el tema específico de Turista sin afectar Guía/Agencia

### Integration Points
- `frontend/lib/main_turista.dart` — punto donde se aplica `ThemeData` a `MaterialApp` para Turista
- `frontend/lib/features/turista/home/presentation/widgets/walkie_talkie_button.dart` — pantalla de demo, debe verse con el nuevo tema
- `frontend/lib/core/tools/presentation/screens/currency_converter_screen.dart` — pantalla de demo, debe verse con el nuevo tema

</code_context>

<specifics>
## Specific Ideas

- Los sketches (`.planning/sketches/`) son dirección de diseño, no plantilla literal — las apps reales tienen muchas más pantallas que los 3 sketches hechos para el pitch. El sistema de diseño debe generalizarse a TODAS las pantallas de Turista, no solo replicar las 3 mockeadas.
- Nota de la ronda de sketches: se quitó la barra de estado simulada (hora/batería) de los sketches — no aportaba. No es relevante para la app real (no hay barra de estado simulada en Flutter), mencionar solo como contexto histórico.

</specifics>

<deferred>
## Deferred Ideas

- Modo oscuro cálido (`dark_theme.dart`) — fuera de esta fase, revisar si se necesita más adelante
- Rediseño de Agencia — su propia fase futura, no tocar `app_theme.dart` compartido actual
- Grabación de pantalla y ensamblaje de video (DEMO-*, VIDEO-*) — v2 en REQUIREMENTS.md, espera a que el guion se estabilice
- Variante de paleta `brand.css` (navy + acentos Veltur) — descartada para esta fase en favor de `default.css`, pero queda documentada en los sketches por si se reconsidera

### Reviewed Todos (not folded)
None — no pending todos matched this phase.

</deferred>

---

*Phase: 1-Rediseño Turista*
*Context gathered: 2026-08-22*
