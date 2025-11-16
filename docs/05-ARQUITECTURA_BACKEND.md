# 05. Arquitectura del Backend (Node.js)

Documento que ilustra cómo se estructurará el Backend

## El Stack Tecnológico

* **Entorno:** Node.js
* **Framework:** Express.js (para crear la API REST)
* **Base de Datos:** PostgreSQL (corriendo en Docker)
* **Extensión Clave:** PostGIS

## ¿Por qué PostGIS?

Este es un punto clave de nuestra arquitectura. `PostGIS` es una extensión de PostgreSQL que la convierte en una base de datos geoespacial. Nos da funciones avanzadas para consultar ubicaciones.

Cuando el frontend necesite saber qué turistas están "lejos" (`distanciaMax`), el backend no calculará esto en Node.js. Simplemente ejecutará una consulta ultra-rápida en PostGIS como:

`... WHERE ST_DWithin(turista.ubicacion, guia.ubicacion, [distanciaMax])`

## Estructura de Carpetas (`/backend/src/`)

El backend sigue una arquitectura similar a la nuestra, separando responsabilidades:

* `/src/routes/`: Define las rutas de la API (ej. `POST /api/v1/auth/login`). Llama a los Controladores.
* `/src/controllers/`: Maneja el objeto `request` y `response`. Valida la entrada y llama a los Servicios.
* `/src/services/`: Contiene la lógica de negocio (ej. `calcularDistanciaSiEsNecesario`). Llama a los Repositorios/Modelos.
* `/src/models/` (o `repositories`): Es la capa que habla *directamente* con la base de datos (usando un ORM como Prisma o Sequelize, o SQL puro).

## El Secreto de la Sincronización: Migraciones

Cada desarrollador tiene su *propia* base de datos local en Docker. ¿Cómo mantenemos la *estructura* (las tablas, las columnas) sincronizada?

La respuesta es **Migraciones**.

* Una migración es un archivo de código (`.sql` o `.js`) que describe un cambio en la base de datos (Ej. `CREAR_TABLA_Plan`, `AÑADIR_COLUMNA_tipo_a_Agencia`).
* Estos archivos **se suben a Git** (viven en `/backend/migrations/`).
* Cuando un desarrollador hace `git pull` y obtiene una nueva migración, ejecuta un comando (ej. `npm run db:migrate`).
* Ese comando lee el archivo de migración y aplica los cambios a su base de datos local en Docker.

**Resultado:** Todos los desarrolladores (y el servidor de producción) tienen una estructura de base de datos idéntica, gestionada por control de versiones.
