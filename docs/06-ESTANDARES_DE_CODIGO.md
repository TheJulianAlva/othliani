# 06. Estándares de Codificación

Un código consistente es más fácil de leer, mantener y depurar. Debe parecer que fue escrito por una sola persona.

> "Escribe código como si la persona que lo fuera a mantener fuera un psicópata violento que sabe dónde vives."  
> . - *John Woods*

Escribimos código para que lo entiendan *otros humanos*, no solo la máquina.

## Nomenclatura en Dart/Flutter

### 1. Nomenclatura de Archivos
Usamos `snake_case` (minúsculas con guiones bajos) para todos los archivos `.dart`.

* **BIEN:** `login_screen.dart`, `auth_repository.dart`, `main_turista.dart`
* **MAL:** `LoginScreen.dart`, `authRepository.dart`, `MainTurista.dart`

### 2. Nomenclatura de Clases y Tipos
Usamos `PascalCase` (Mayúscula inicial en cada palabra).

* **Aplica a:** Clases de Widgets, BLoCs, Estados, Entidades, Modelos, UseCases, Repositorios.
* **BIEN:** `class LoginScreen`, `class LoginBloc`, `class LoginStateSuccess`, `class Participante`
* **MAL:** `class login_screen`, `class loginBloc`

### 3. Nomenclatura de Variables y Métodos
Usamos `camelCase` (Minúscula inicial, luego mayúsculas).

* **Aplica a:** Variables (`distanciaMax`), funciones (`calcularDistancia()`), parámetros (`String folioAcceso`).
* **BIEN:** `final int distanciaMaxima;`, `void miFuncion() {}`
* **MAL:** `final int DistanciaMaxima;`, `void mi_funcion() {}`

### 4. Variables Privadas
Las variables, clases o métodos que solo deben ser usados *dentro* del mismo archivo deben empezar con un guion bajo `_`.

* **BIEN:** `class _MiWidgetPrivado`, `final String _apiKey;`

## Reglas de Estilo de Flutter

### 1. `const` por Defecto
**Usa `const` siempre que sea posible.** Si un widget y sus hijos no cambian, decláralo `const`. Esto le da a Flutter una enorme ventaja de rendimiento, ya que puede saltarse el redibujado de ese widget.

* **BIEN:** `return const Center(child: Text('Hola'));`
* **OK:** `return Center(child: Text(variableDinamica));`
* **MAL:** `return Center(child: Text('Hola'));` (Falta el `const`)

Tu IDE (VS Code) te ayudará a identificar esto con un subrayado azul.

### 2. Coma al Final (Trailing Comma)
**SIEMPRE** coloca una coma al final de la última propiedad o widget en una lista, incluso si es el último.

* **BIEN:**
    ```dart
    Column(
      children: [
        Text('Hola'),
        Text('Mundo'), // <-- Esta coma
      ], // <-- Esta coma
    );
    ```
* **¿Por qué?** Porque activa el auto-formateador de VS Code para que ponga cada widget en su propia línea, haciendo el código infinitamente más legible.

## Comentarios
* Usa `//` para comentarios de una línea.
* Usa `///` para comentarios de documentación (que explican qué hace una función o clase).
* **No comentes lo obvio:**
    * **MAL:** `int i += 1; // Incrementa i`
* **Comenta el "por qué":**
    * **BIEN:** `// Usamos un delay aquí para simular la latencia de red en el Mock`

## Linter
Próximamente, añadiremos un archivo `analysis_options.yaml` al proyecto. Este archivo es un *"linter"* que forzará automáticamente estas reglas en VS Code y fallará las pruebas si no se cumplen.