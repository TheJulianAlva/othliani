# Roadmap: Veltur — Pitch Demo Milestone

## Overview

Este milestone rediseña las apps Turista y Guía hacia un look cálido y consistente (terracota/teal, tipografía redondeada, radios grandes, sombras suaves) en preparación para el video de pitch del concurso "Reto Prototipo". Es un rediseño visual/UX de extremo a extremo, no una entrega de features nuevas ni de backend. Se ejecuta como dos slices verticales: primero Turista completa (que también sienta las bases del sistema de diseño compartido en `frontend/lib/core/theme/`), luego Guía completa reutilizando ese mismo sistema. Grabación y ensamblaje del video quedan fuera de este milestone (v2).

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Rediseño Turista** - La app Turista completa (incluyendo walkie-talkie y conversor de divisas) aplica el sistema de diseño cálido de extremo a extremo, y ese sistema queda disponible como base compartida en `frontend/lib/core/theme/`
- [ ] **Phase 2: Rediseño Guía** - La app Guía completa (incluyendo el mapa de monitoreo/alerta de lejanía) aplica el mismo sistema de diseño cálido, reutilizando la base construida en la Fase 1

## Phase Details

### Phase 1: Rediseño Turista

**Goal**: La app Turista se ve y se siente cálida y consistente en todas sus pantallas — no solo en las 3 que salen en el video de pitch — lista para grabarse como una demo creíble. El sistema de diseño (colores, tipografía, radios, sombras, componentes reutilizables) se construye aquí en `frontend/lib/core/theme/` y `frontend/lib/core/widgets/`, quedando disponible para reutilizarse en la Fase 2.
**Depends on**: Nothing (first phase)
**Requirements**: DISENO-TUR-01, DISENO-TUR-02, DISENO-TUR-03
**Success Criteria** (what must be TRUE):

  1. Al navegar la app Turista completa (login, home, walkie-talkie, chat, itinerario, perfil, ajustes, conversor de divisas), toda pantalla usa la paleta terracota/teal, tipografía redondeada, radios grandes (16-24px) y sombras suaves — ninguna pantalla queda con el look navy/Material plano anterior.
  2. La pantalla de walkie-talkie (botón "presiona y habla") refleja visualmente el nuevo sistema de diseño, manteniendo intacta su funcionalidad Socket.IO existente.
  3. La pantalla de conversor de divisas refleja visualmente el nuevo sistema de diseño, manteniendo intacta su funcionalidad de conversión existente.
  4. Los componentes de UI reutilizables (botones, tarjetas, inputs, modales) usados por Turista comparten los mismos tokens de color/tipografía/radio/sombra en vez de estilos ad-hoc por pantalla.

**Plans**: TBD

- [x] 01-01-PLAN.md
- [x] 01-02-PLAN.md
- [x] 01-03-PLAN.md
- [x] 01-04-PLAN.md
- [x] 01-05-PLAN.md
- [ ] 01-06-PLAN.md

**UI hint**: yes

### Phase 2: Rediseño Guía

**Goal**: La app Guía se ve y se siente cálida y consistente en todas sus pantallas, usando el mismo sistema de diseño construido en la Fase 1 (sin reimplementarlo desde cero), lista para grabarse como una demo creíble.
**Depends on**: Phase 1 (reutiliza el sistema de diseño y los componentes compartidos construidos ahí)
**Requirements**: DISENO-GUIA-01, DISENO-GUIA-02
**Success Criteria** (what must be TRUE):

  1. Al navegar la app Guía completa (login, home, mapa de monitoreo, chat, viajes, perfil, ajustes), toda pantalla usa el mismo sistema de diseño cálido (terracota/teal, con posible acento de Guía) con tipografía redondeada, radios grandes y sombras suaves — consistente con Turista y sin pantallas en el look anterior.
  2. La pantalla de mapa de monitoreo / alerta de lejanía refleja el nuevo sistema de diseño (estados seguro→alejado→alerta legibles y cálidos, controles de mapa con radios grandes y sombras suaves), manteniendo intacto el cálculo de riesgo existente.
  3. Los componentes de UI compartidos (botones, tarjetas, inputs) se ven visualmente idénticos entre Turista y Guía, confirmando que se reutilizó el sistema de diseño de la Fase 1 en vez de reimplementarlo en paralelo.

**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Rediseño Turista | 5/6 | In Progress|  |
| 2. Rediseño Guía | 0/TBD | Not started | - |
