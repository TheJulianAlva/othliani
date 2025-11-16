# 04. Dependencias Clave del Frontend (Flutter)

Usamos un conjunto de paquetes (librerías) estándar de la industria que nos ayudan a implementar nuestra arquitectura.

**Para instalar:** `flutter pub add <nombre_del_paquete>`

---

### Gestión de Estado

* **Paquete:** `flutter_bloc`
* **Documentación:** [https://bloclibrary.dev/](https://bloclibrary.dev/)
* **Rol en la Arquitectura:** Es el "cerebro" de nuestra capa de **Presentación**. Vive en `presentation_.../blocs/`. Su trabajo es tomar eventos de la UI, llamar a los `usecases` del Dominio y emitir nuevos estados a los que la UI reacciona.
* **Información Adicional:** 
    * [BLoC for Beginners 📱 State Management [YouTube]](https://youtu.be/rF6eq1oru-Y)

### Red (Networking)

* **Paquete:** `dio`
* **Documentación:** [https://pub.dev/packages/dio](https://pub.dev/packages/dio)
* **Rol en la Arquitectura:** Es el motor de nuestra capa de **Datos**. Vive en `data/datasources/`. Es el cliente HTTP que usamos para hacer las llamadas a nuestra API de Node.js. Lo elegimos sobre `http` por su manejo avanzado de errores, *interceptors* y timeouts.

### Navegación

* **Paquete:** `go_router`
* **Documentación:** [https://pub.dev/packages/go_router](https://pub.dev/packages/go_router)
* **Rol en la Arquitectura:** Es el "mapa de calles" de la app. Vive en `core/navigation/`. Nos permite definir una navegación limpia basada en URLs (ej. `/viaje/123/mapa`) y es el estándar oficial de Flutter.
* **Información Adicional:** 
    * [go_router (Package of the week) [YouTube]](https://youtu.be/b6Z885Z46cU)

### Inyección de Dependencias (DI)

* **Paquete:** `get_it`
* **Documentación:** [https://pub.dev/packages/get_it](https://pub.dev/packages/get_it)
* **Rol en la Arquitectura:** Es el "pegamento" de toda nuestra arquitectura. Vive en `core/DI/` (o `core/injection/`). Nos permite "registrar" nuestras clases (Repositorios, UseCases) en un lugar central y luego "pedirlas" desde donde las necesitemos (como en los BLoCs), sin acoplar fuertemente el código.
* **Información Adicional:** 
    * [get_it (Package of the week) [YouTube]](https://youtu.be/f9XQD5mf6FY)

### Mapas

* **Paquete:** `Maps_flutter`
* **Documentación:** [https://pub.dev/packages/google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
* **Rol en la Arquitectura:** Es un Widget de **Presentación**. Lo usaremos en las pantallas de mapa (ej. `presentation_guia/screens/mapa_screen.dart`) para renderizar la ubicación de los participantes.

### Manejo de Errores Funcional

* **Paquete:** `dartz`
* **Documentación:** [https://pub.dev/packages/dartz](https://pub.dev/packages/dartz)
* **Rol en la Arquitectura:** Es clave en nuestro **Dominio**. Nuestros `usecases` y `repositories` no devolverán un `Participante` o un `Error`. Devolverán un `Either<Falla, Participante>`, forzándonos a manejar explícitamente el caso de éxito (`Right`) y el de error (`Left`) en nuestros BLoCs.
* **Información Adicional:** 
    * [Level Up Your Error Handling 🔥 - Dartz [YouTube]](https://youtu.be/WcMwfJSRcnE)

### Comparación de Objetos

* **Paquete:** `equatable`
* **Documentación:** [https://pub.dev/packages/equatable](https://pub.dev/packages/equatable)
* **Rol en la Arquitectura:** Es una utilidad de **Presentación** y **Dominio**. Permite que `flutter_bloc` sepa si un estado es *realmente* nuevo (comparando sus propiedades) antes de redibujar la pantalla. También lo usamos en nuestras `entities` del Dominio.
* **Información Adicional:** 
    * [Flutter Package Equatable To Easily Check For Object Equality [YouTube]](https://youtu.be/FIKbXn6MQu4)
