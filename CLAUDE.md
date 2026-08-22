# Veltur

Veltur es un ecosistema de gestión de logística para viajes: tres apps Flutter (Turista, Guía, Agencia) que comparten un core de dominio y datos, más un backend Node.js. Monorepo: `frontend/` (Flutter) y `backend/` (Node.js).

## Stack real (verificado contra el código)

- **Frontend:** Flutter + `flutter_bloc` (Bloc para manejo de estado), Clean Architecture (Domain/Data/Presentation). Las tres apps comparten 100% del Domain y Data layer; solo la Presentation layer es específica por app. Routing con `go_router`, mapas con `google_maps_flutter`.
- **Backend:** Node.js, estilo Express. Hoy en día solo existe `backend/demo-server/` (un servidor Socket.IO mínimo) — la API REST/PostGIS descrita en `docs/05-ARQUITECTURA_BACKEND.md` está planeada, no completamente construida.
- **No están en el código real:** NestJS, Mapbox, Isar, WebRTC. Esas tecnologías aparecen en una propuesta de arquitectura no implementada archivada en `docs/archive/aspirational-architecture/` — ignóralas al escribir código, no son el stack vigente.

## Reglas de trabajo

- **Fuente de verdad de negocio:** `docs/product_requirements/*_user_stories.md`. No inventes reglas de negocio ni flujos de usuario que no estén ahí. Si hay ambigüedad, pregunta antes de asumir.
- **Plan antes que código:** para cambios no triviales, propone un plan/lista de tareas y espera confirmación antes de modificar código fuente.
- **Idioma:** código (variables, clases, funciones, ramas de git) en **inglés**. Documentación técnica, comentarios y strings de UI en **español**.
- **Clean Architecture estricta en Flutter:** separa UI (Presentation) de Repositorios (Data) y de la capa de Dominio; usa Bloc para estado.

## Dónde encontrar cada cosa

| Necesitas | Ve a |
|---|---|
| Índice completo de docs | [docs/README.md](docs/README.md) |
| Arquitectura frontend | [docs/03-ARQUITECTURA_FRONTEND.md](docs/03-ARQUITECTURA_FRONTEND.md) |
| Arquitectura backend | [docs/05-ARQUITECTURA_BACKEND.md](docs/05-ARQUITECTURA_BACKEND.md) |
| Requerimientos de producto | [docs/product_requirements/](docs/product_requirements/) |
| Estándares de código | [docs/06-ESTANDARES_DE_CODIGO.md](docs/06-ESTANDARES_DE_CODIGO.md) |
| Setup de entorno | [docs/02-CONFIGURACION_ENTORNO.md](docs/02-CONFIGURACION_ENTORNO.md) |
| Flujo de Git/PRs | [CONTRIBUTING.md](CONTRIBUTING.md) |

`docs/archive/` contiene material histórico/superado (demos pasados, propuestas no implementadas, planes de iteración ya completados) — **no es fuente de verdad**, no lo uses para entender el estado actual del proyecto.
