# Phase 1: Rediseño Turista - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-08-22
**Phase:** 1-Rediseño Turista
**Areas discussed:** Alcance del tema, Paleta de color, Tipografía, Modo oscuro

---

## Alcance del tema

| Option | Description | Selected |
|--------|-------------|----------|
| Tema por app (Recomendado) | Crear un tema específico para Turista ahora; Agencia sigue con el navy actual hasta su propia fase | ✓ |
| Tema global ya mismo | Cambiar el tema compartido ahora; Agencia también se vería cálida aunque no sea su fase todavía | |

**User's choice:** Tema por app (Recomendado)
**Notes:** `app_theme.dart` es compartido por las 3 apps hoy; se decidió no tocarlo in-place para no afectar Agencia antes de tiempo.

---

## Paleta de color

| Option | Description | Selected |
|--------|-------------|----------|
| default.css — terracota+teal | La dirección cálida original, más alejada del navy actual | ✓ |
| brand.css — navy + acentos | Más cercana a la identidad Veltur existente (navy + naranja Guía + turquesa Agencia) | |

**User's choice:** default.css — terracota+teal
**Notes:** Tokens exactos tomados de `.planning/sketches/themes/default.css`.

---

## Tipografía

| Option | Description | Selected |
|--------|-------------|----------|
| Paquete google_fonts (Recomendado) | Agregar el paquete pub, carga dinámica de Poppins/Nunito | ✓ |
| Fuente empaquetada localmente | Descargar los .ttf y empaquetarlos como assets (sin dependencia de red) | |

**User's choice:** Paquete google_fonts (Recomendado)

---

## Modo oscuro

| Option | Description | Selected |
|--------|-------------|----------|
| Solo modo claro por ahora | El video se graba en modo claro; dark mode queda para después | ✓ |
| Ambos modos | Rediseñar también dark_theme.dart en esta fase | |

**User's choice:** Solo modo claro por ahora

---

## Claude's Discretion

- Nombre exacto de archivos/clases para el tema de Turista
- Cómo generalizar los widgets compartidos en `core/widgets/` (parámetros de tema vs extensión de ThemeData)
- Mapeo fino de qué elementos de UI usan radio sm/md/lg en cada pantalla

## Deferred Ideas

- Modo oscuro cálido para Turista
- Rediseño de Agencia (fase futura)
- Grabación de pantalla y ensamblaje de video (v2 en REQUIREMENTS.md)
- Variante de paleta brand.css (descartada para esta fase)
