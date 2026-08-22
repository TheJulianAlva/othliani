# Veltur

## What This Is

Veltur es un ecosistema de tres apps Flutter (Turista, Guía, Agencia) que acompaña digitalmente a turistas en viajes grupales: comunicación privada (walkie-talkie), alertas de alejamiento sobre mapa, itinerario offline-first y herramientas como conversor de divisas. Este milestone no construye el backend de producción (NestJS/Redis/PostGIS descrito en las historias de usuario sigue siendo aspiracional) — el foco es preparar un video de pitch de 3 minutos, creíble y bien producido, para un concurso de prototipos ("Reto Prototipo"), con Turista y Guía luciendo un rediseño visual cálido y consistente.

## Core Value

El video de pitch debe convencer al jurado de que Veltur es un producto real y funcional: las 3 tomas de demo (alerta de lejanía, walkie-talkie, conversor de divisas) deben grabarse desde la app real corriendo, con un diseño cálido y simple que se sienta cuidado, no como un prototipo a medio hacer.

## Business Context

- **Customer**: Jurado del concurso "Reto Prototipo" (no un cliente pagador todavía)
- **Revenue model**: Suscripción mensual B2B a agencias de viajes (Standard/Professional/Enterprise) — ver `pitch/modelo-de-negocios.md`, no es foco de este milestone
- **Success metric**: Video de 3:00 renderizado y entregado a tiempo, con las 3 tomas grabadas desde la app real
- **Strategy notes**: `pitch/memoria-tecnica-veltur.md`, `pitch/modelo-de-negocios.md`, `pitch/ficha-tecnica.md`

## Requirements

### Validated

- ✓ Arquitectura Clean (Presentation/Domain/Data) compartida entre las 3 apps Flutter — existing
- ✓ Turista: walkie-talkie funcional vía Socket.IO (`frontend/lib/features/turista/home/presentation/widgets/walkie_talkie_button.dart`) — existing
- ✓ Guía: mapa de monitoreo con cálculo de riesgo/alejamiento (`frontend/lib/features/guia/shared/widgets/mapa_monitoreo_widget.dart`, `calculate_risk_usecase.dart`) — existing
- ✓ Turista: conversor de divisas (`frontend/lib/core/tools/presentation/screens/currency_converter_screen.dart`) — existing
- ✓ Backend demo Socket.IO para tiempo real (`backend/demo-server/`) — existing, suficiente para esta demo
- ✓ Proyecto Remotion para ensamblar el video de pitch (`pitch/video/`) — existing, faltan las grabaciones

### Active

- [ ] Rediseño visual cálido/simple (dirección de `.planning/sketches/`: terracota+teal, tipografía redondeada, radios grandes) aplicado de forma consistente en toda la app Turista
- [ ] Mismo rediseño aplicado de forma consistente en toda la app Guía
- [ ] Las 3 pantallas de demo (alerta de lejanía, walkie-talkie, conversor de divisas) pulidas y grabables en pantalla completa, sin marcos de navegador
- [ ] Grabación de las 3 tomas de pantalla completa (`pitch/video/public/footage/*.mp4`)
- [ ] Video renderizado 1920x1080, 30fps, 3:00 exactos vía Remotion (composición `VelturPitch`)

### Out of Scope

- Backend de producción (NestJS, Redis, PostgreSQL/PostGIS, FCM/APNs) — las historias de usuario en `docs/product_requirements/` lo describen pero no se construye en este milestone; el demo Socket.IO actual basta para grabar la demo
- Rediseño de la app Agencia (portal de escritorio) — no aparece en el video de pitch, se pospone
- Demo en vivo ante jurado — el entregable es el video grabado, no una demo interactiva
- Registro legal (INDAUTOR, IMPI, ISO 31000, certificaciones) — mencionado en `pitch/memoria-tecnica-veltur.md` pero fuera del alcance de desarrollo de software

## Context

- Monorepo `frontend/` (Flutter, 3 apps: Turista, Guía, Agencia) + `backend/` (Node.js, hoy solo `backend/demo-server/`)
- Fuente de verdad de negocio/funcional: `docs/product_requirements/{tourist,guide,agency}_user_stories.md` — muy detalladas pero describen una arquitectura de backend (NestJS/Redis/PostGIS) más avanzada que el código real; no usar esas menciones de stack como guía de implementación en este milestone
- Guion del video: `pitch/script/guion-video.md` — ya especifica qué debe mostrar cada toma y en qué archivos vive el código de cada feature
- Dirección de diseño ya explorada en sketches (`.planning/sketches/`, 3 pantallas prototipo): cálido/humano, terracota+teal, tipografía redondeada (Poppins/Nunito), radios grandes (16-24px), sombras suaves — referencia de dirección, no plantilla literal a copiar pantalla por pantalla, dado que las apps reales tienen muchas más pantallas que los sketches
- Existe también `themes/brand.css` en los sketches con una variante recoloreada más cercana a la marca Veltur (navy `#1e407d` + acentos de Guía/Agencia) — variante disponible pero no obligatoria

## Constraints

- **Timeline**: Video listo en 2 semanas — el roadmap debe acotarse a lo indispensable para esa entrega
- **Tech stack**: Flutter/Dart para frontend, sin introducir backend nuevo en este milestone
- **Idioma**: identificadores de código en inglés, UI y documentación en español (convención del proyecto, ver CLAUDE.md)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| No construir backend de producción este milestone | El objetivo inmediato es el video de pitch, no un producto listo para agencias reales; el demo Socket.IO ya sustenta las 3 tomas necesarias | — Pending |
| Rediseño cubre Turista y Guía, no Agencia | Agencia no aparece en el video de 3 minutos; enfocar el tiempo limitado en lo que se graba | — Pending |
| Sketches como dirección de diseño, no plantilla literal | Las apps reales tienen más pantallas que los 3 sketches hechos para el pitch; se necesita un sistema de diseño consistente, no solo 3 pantallas rediseñadas | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-08-22 after initialization*
