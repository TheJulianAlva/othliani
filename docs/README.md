# Documentación de Veltur

Índice de toda la documentación técnica del proyecto. Si eres nuevo en el equipo, empieza por la sección 1 y sigue el orden.

Ver también: [README principal](../README.md) · [Guía de contribución](../CONTRIBUTING.md)

## 1. Visión general

| Doc | Contenido |
|---|---|
| [01-VISUALIZACION_PROYECTO.md](01-VISUALIZACION_PROYECTO.md) | Qué es este proyecto, estructura general de carpetas del monorepo. |
| [02-CONFIGURACION_ENTORNO.md](02-CONFIGURACION_ENTORNO.md) | Checklist de instalación (Flutter, Node.js, Docker, etc.). |

## 2. Arquitectura (Frontend)

| Doc | Contenido |
|---|---|
| [03-ARQUITECTURA_FRONTEND.md](03-ARQUITECTURA_FRONTEND.md) | **(¡MUY IMPORTANTE!)** Clean Architecture (Domain, Data, Presentation) y el modelo multi-app (Turista/Guía/Agencia). |
| [04-DEPENDENCIAS_FRONTEND.md](04-DEPENDENCIAS_FRONTEND.md) | Lista y rol de las dependencias clave de Flutter. |
| [architecture/mock_database_guide.md](architecture/mock_database_guide.md) | Guía del patrón `MockDatabase` usado para simular el backend durante el desarrollo. |
| [architecture/entidad_relacion.puml](architecture/entidad_relacion.puml) | Diagrama entidad-relación (PlantUML). |

## 3. Arquitectura (Backend)

| Doc | Contenido |
|---|---|
| [05-ARQUITECTURA_BACKEND.md](05-ARQUITECTURA_BACKEND.md) | API de Node.js, rol de PostGIS y migraciones de base de datos. |
| [07-ANALISIS_COSTOS_HOSTING.md](07-ANALISIS_COSTOS_HOSTING.md) | Análisis de costos de hosting (Render/Railway/Supabase) y la estrategia de "última ubicación" en Redis. |
| [08-ENTENDIENDO_REDIS.md](08-ENTENDIENDO_REDIS.md) | Guía práctica de Redis para quien no lo haya usado antes. |

## 4. Estándares y flujo de trabajo

| Doc | Contenido |
|---|---|
| [06-ESTANDARES_DE_CODIGO.md](06-ESTANDARES_DE_CODIGO.md) | Reglas de nomenclatura y estilo de código Dart/Flutter. |
| [../CONTRIBUTING.md](../CONTRIBUTING.md) | Ramas, commits, Pull Requests y revisión de código. |

## 5. Extensiones y features

| Doc | Contenido |
|---|---|
| [extensions/CONECTIVIDAD.md](extensions/CONECTIVIDAD.md) | Detección de estado de red (`connectivity_plus`, `SyncBloc`). |
| [extensions/CURRENCY_CONVERTER_GUIDE.md](extensions/CURRENCY_CONVERTER_GUIDE.md) | Conversor de moneda con OCR (Google ML Kit). |
| [extensions/GOOGLE_MAPS_SETUP.md](extensions/GOOGLE_MAPS_SETUP.md) | Configuración de la API key de Google Maps SDK. |

## 6. Requerimientos de producto

Fuente de verdad de las reglas de negocio — ver también la regla en [`CLAUDE.md`](../CLAUDE.md).

| Doc | Contenido |
|---|---|
| [product_requirements/tourist_user_stories.md](product_requirements/tourist_user_stories.md) | User stories de la App Turista. |
| [product_requirements/guide_user_stories.md](product_requirements/guide_user_stories.md) | User stories de la App Guía. |
| [product_requirements/agency_user_stories.md](product_requirements/agency_user_stories.md) | User stories del Portal Agencia. |

Exportes en PDF de los tres documentos anteriores: [`product_requirements/pdf/`](product_requirements/pdf/).

## 7. Archivo histórico

[`archive/`](archive/README.md) contiene documentación histórica o superada (planes de demo, propuestas de arquitectura no implementadas, drafts de requerimientos ya reemplazados, planes de iteración de frontend ya completados). **No es fuente de verdad** — se conserva solo como referencia histórica.
