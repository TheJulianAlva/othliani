# ¡Bienvenido al Repositorio Oficial de OhtliAni!

Este es el **repo oficial** para todo el ecosistema de OhtliAni. Contiene el código fuente de todas nuestras aplicaciones:

* **Aplicaciones Frontend** (Turista, Guía, Agencia) construidas con Flutter.
* **Servidor Backend** (API) construido con Node.js (no implementado aún).
* **Configuración de Base de Datos** (PostGIS) gestionada con Docker (no implementado aún).

Este repositorio es la única fuente de verdad para todo nuestro trabajo.

## ¿Cómo Empezar?

Si eres nuevo en el proyecto o necesitas configurar tu entorno, sigue estos pasos:

1.  **Configura tu PC:** Revisa la [Guía de Configuración del Entorno](./docs/02-CONFIGURACION_ENTORNO.md) para instalar todo el software necesario.
2.  **Entiende el Flujo de Trabajo:** Lee [Nuestro Flujo de Trabajo en Git](./CONTRIBUTING.md) para saber cómo contribuir código.

---

## Índice de Documentación

Toda nuestra documentación técnica y guías de arquitectura viven en la carpeta `/docs`. Consulta estos archivos para entender *cómo* y *por qué* construimos el software de esta manera.

### 1. Visión General
* **[./docs/01-VISUALIZACION_PROYECTO.md](./docs/01-VISUALIZACION_PROYECTO.md):** Qué es este proyecto, estructura general de carpetas.

### 2. Configuración y Flujo de Trabajo
* **[./docs/02-CONFIGURACION_ENTORNO.md](./docs/02-CONFIGURACION_ENTORNO.md):** 
Checklist de instalación (Flutter, Node.js, Docker, etc.).
* **[CONTRIBUTING.md](./CONTRIBUTING.md):** Reglas para las ramas (branches), Pull Requests y revisiones de código.

### 3. Arquitectura (Frontend)
* **[./docs/03-ARQUITECTURA_FRONTEND.md](./docs/03-ARQUITECTURA_FRONTEND.md):** (¡MUY IMPORTANTE!) Explica **Clean Architecture** *(Domain, Data, Presentation)* y el modelo multi-aplicación.
* **[./docs/04-DEPENDENCIAS_FRONTEND.md](./docs/04-DEPENDENCIAS_FRONTEND.md):** Lista y descripción de las dependencias clave.

### 4. Arquitectura (Backend)
* **[./docs/05-ARQUITECTURA_BACKEND.md](./docs/05-ARQUITECTURA_BACKEND.md):** Resumen de la API de Node.js, el rol de PostGIS y las migraciones de base de datos.

### 5. Estándares
* **[./docs/06-ESTANDARES_DE_CODIGO.md](./docs/06-ESTANDARES_DE_CODIGO.md):** Reglas de nomenclatura y estilo para mantener el código limpio y consistente.
