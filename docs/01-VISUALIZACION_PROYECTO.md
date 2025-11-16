# 01. Visión General del Proyecto

## ¿Qué es este Proyecto?

Este repositorio contiene el código fuente de todo el ecosistema OhtliAni. Nuestro objetivo es construir un sistema de seguridad y logística para agencias de viajes, compuesto por tres aplicaciones cliente y un servidor central:

1.  **App Turista (Flutter):** Aplicación móvil para el cliente final, enfocada en seguridad, itinerario y comunicación.
2.  **App Guía (Flutter):** Aplicación móvil para el guía, enfocada en la gestión de participantes, alertas y trazabilidad.
3.  **App Agencia (Flutter Web/Escritorio):** Aplicación de escritorio para el staff, enfocada en la administración de viajes, guías, turistas y la configuración del sistema.
4.  **Backend (Node.js):** La API central que da servicio a las tres aplicaciones y se comunica con la base de datos.

## La Estrategia: Monorepo

Se ha elegido un enfoque de un solo repositorio para todo el código por varias razones estratégicas:

* **Visibilidad Total:** Todos los miembros del equipo tienen acceso al código de todos los componentes, lo que facilita la comprensión de cómo encajan las piezas.
* **Sincronización de Código:** Es fácil mantener sincronizados los modelos de datos entre el frontend y el backend, ya que viven juntos.
* **Gestión Centralizada:** Un solo lugar para gestionar tareas (Issues), revisiones de código (Pull Requests) y la documentación.

## Estructura de Carpetas Raíz

Así es como se organiza el repositorio en su nivel más alto:

```
/ohtliani-mvp/
│
├── .github/          <-- (CI/CD) Configuración de GitHub Actions para pruebas automáticas.
├── .gitignore        <-- Ignora archivos globales de SO e IDEs.
├── README.md         <-- El portal de bienvenida e índice (el archivo que leíste primero).
│
├── docker-compose.yml <-- ¡CLAVE! Define nuestra base de datos PostGIS local.
│
├── docs/               <-- ¡ESTÁS AQUÍ! Toda la documentación del proyecto.
│
├── backend/            <-- Contiene el proyecto completo del servidor (Node.js + Express).
│
└── frontend/           <-- Contiene el proyecto completo de Flutter (que genera las 3 apps).
```
