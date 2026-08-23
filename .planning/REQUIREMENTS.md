# Requirements: Veltur — Pitch Demo Milestone

**Defined:** 2026-08-22
**Core Value:** El video de pitch debe convencer al jurado de que Veltur es un producto real y funcional, grabando las 3 tomas clave desde la app real con un diseño cálido y consistente. Este milestone se concentra en el diseño; la grabación y el ensamblaje del video esperan a que el guión quede definido.

## v1 Requirements

Requisitos para este milestone. Cada uno mapea a una fase del roadmap.

### Diseño Turista

- [x] **DISENO-TUR-01**: La app Turista aplica un sistema de diseño cálido consistente (paleta terracota/teal, tipografía redondeada, radios grandes, sombras suaves) en todas sus pantallas, no solo en las que salen en el video
- [x] **DISENO-TUR-02**: La pantalla de walkie-talkie del Turista refleja el nuevo sistema de diseño
- [x] **DISENO-TUR-03**: La pantalla de conversor de divisas del Turista refleja el nuevo sistema de diseño

### Diseño Guía

- [ ] **DISENO-GUIA-01**: La app Guía aplica el mismo sistema de diseño cálido consistente en todas sus pantallas
- [ ] **DISENO-GUIA-02**: La pantalla de mapa de monitoreo / alerta de lejanía del Guía refleja el nuevo sistema de diseño

## v2 Requirements

Deferred a futuro release. No forman parte de este milestone — esperan a que el guion del video (`pitch/script/guion-video.md`) quede definido.

### Demo Grabable

- **DEMO-01**: Las 3 pantallas de demo (alerta de lejanía, walkie-talkie, conversor de divisas) funcionan de extremo a extremo sin errores visibles, listas para grabarse en pantalla completa
- **DEMO-02**: Grabación de "alerta de lejanía" en `pitch/video/public/footage/alerta-lejania.mp4`
- **DEMO-03**: Grabación de "walkie-talkie" en `pitch/video/public/footage/walkie-talkie.mp4`
- **DEMO-04**: Grabación de "conversor de divisas" en `pitch/video/public/footage/conversor-divisas.mp4`

### Ensamblaje de Video

- **VIDEO-01**: La composición Remotion `VelturPitch` integra las 3 grabaciones reales en la escena Demo
- **VIDEO-02**: El video final renderiza en 1920x1080, 30fps, exactamente 3:00

### Diseño Agencia

- **DISENO-AGEN-01**: Aplicar el mismo sistema de diseño cálido al portal de Agencia (escritorio)

### Backend de Producción

- **BACKEND-01**: Construir el backend NestJS/Redis/PostgreSQL-PostGIS descrito en `docs/product_requirements/`
- **BACKEND-02**: Notificaciones push (FCM/APNs) para alertas críticas
- **BACKEND-03**: Autenticación real con Folio de Viaje, Device Binding y JWT

## Out of Scope

Excluido explícitamente de este milestone.

| Feature | Reason |
|---------|--------|
| Grabación de pantalla y ensamblaje de video | El guion aún va a cambiar; grabar ahora arriesgaría rehacer el trabajo |
| Backend de producción (NestJS/Redis/PostGIS/FCM) | El demo Socket.IO actual basta; no aporta al alcance de este milestone |
| Rediseño de la app Agencia | No aparece en el video de pitch de 3 minutos |
| Demo en vivo ante jurado | El entregable final es el video grabado, no una sesión interactiva |
| Registro legal (INDAUTOR, IMPI, ISO 31000) | Fuera del alcance de desarrollo de software |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DISENO-TUR-01 | Phase 1 | Complete |
| DISENO-TUR-02 | Phase 1 | Complete |
| DISENO-TUR-03 | Phase 1 | Complete |
| DISENO-GUIA-01 | Phase 2 | Pending |
| DISENO-GUIA-02 | Phase 2 | Pending |

**Coverage:**

- v1 requirements: 5 total
- Mapped to phases: 5 (Phase 1: 3, Phase 2: 2)
- Unmapped: 0 ✓

---
*Requirements defined: 2026-08-22*
*Last updated: 2026-08-22 after roadmap creation (2 phases, full v1 coverage)*
