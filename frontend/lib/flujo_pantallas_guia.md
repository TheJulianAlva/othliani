# OthliAni - Flujo de Pantallas para Guía (Front-End)

Este documento describe las pantallas y acciones principales para el diseño del front-end, excluyendo validaciones y lógica de back-end.

## Módulo: Cuenta Agencia
### Proceso: Iniciar sesión con agencia
- Pantalla/Acción: Usuario abre OthliAni Guia
- Pantalla/Acción: Usuario selecciona "Tengo cuenta de agencia"
- Pantalla/Acción: Sistema muestra formulario de inicio de sesión 
- Pantalla/Acción: Usuario ingresa datos
- Pantalla/Acción: Sistema verifica credenciales 
- Pantalla/Acción: Sistema otorga acceso
### Proceso: Cerrar sesión
- Pantalla/Acción: Usuario selecciona la opción "Cerrar sesión"
- Pantalla/Acción: Sistema verifica solicitud de cierre de sesión
- Pantalla/Acción: Sistema elimina sesión activa del usuario
- Pantalla/Acción: Sistema borra datos temporales
- Pantalla/Acción: Sistema redirige a pantalla de iniciar sesión
## Módulo: Cuenta
### Proceso: Registrarse
- Pantalla/Acción: Usuario abre OthliAni Guia
- Pantalla/Acción: Usuario selecciona "Registro"
### Proceso: Iniciar sesión
- Pantalla/Acción: Usuario selecciona "Ingresar"
- Pantalla/Acción: Sistema muestra formulario de inicio de sesión 
- Pantalla/Acción: Usuario ingresa información solicitada.
- Pantalla/Acción: Usuario selecciona "Ingresar"
- Pantalla/Acción: Sistema verifica las credenciales 
- Pantalla/Acción: Sistema otorga acceso
- Pantalla/Acción: Sistema redirige a pantalla principal del usuario
### Proceso: Recuperar Contraseña
- Pantalla/Acción: Usuario selecciona la opción “Olvidé mi contraseña”
- Pantalla/Acción: Sistema muestra un formulario solicitando el correo electrónico vinculado a la cuenta
- Pantalla/Acción: Usuario ingresa su correo electrónico
- Pantalla/Acción: Usuario envía la solicitud
- Pantalla/Acción: Sistema genera un enlace temporal
- Pantalla/Acción: Usuario ingresa al enlace
- Pantalla/Acción: Sistema muestra formulario para ingresar nueva contraseña
- Pantalla/Acción: Usuario registra nueva contraseña
- Pantalla/Acción: Usuario selecciona "Crear nueva contraseña"
- Pantalla/Acción: Sistema verifica nueva contraseña
- Pantalla/Acción: Sistema actualiza la contraseña en la base de datos.
- Pantalla/Acción: Sistema muestra mensaje de confirmación indicando que los cambios se guardaron con éxito
- Pantalla/Acción: Sistema redirige a pantalla de iniciar sesión
### Proceso: Cerrar sesión
- Pantalla/Acción: Usuario selecciona la opción "Cerrar sesión"
- Pantalla/Acción: Sistema verifica solicitud de cierre de sesión
- Pantalla/Acción: Sistema elimina sesión activa del usuario
- Pantalla/Acción: Sistema borra datos temporales
- Pantalla/Acción: Sistema redirige a pantalla de iniciar sesión
### Proceso: Ver perfil
- Pantalla/Acción: Usuario selecciona "Perfil"
- Pantalla/Acción: Sistema consulta información asociada con cuenta
- Pantalla/Acción: Sistema muestra información de perfil
- Pantalla/Acción: Usuario visualiza su información de perfil
## Módulo: Viajes
### Proceso: Dar de alta usuarios del viaje
- Pantalla/Acción: Usuario selecciona "Añadir participantes al viaje"
- Pantalla/Acción: Sistema muestra formulario para ingresar datos del turista
- Pantalla/Acción: Usuario ingresa datos
- Pantalla/Acción: Usuario selecciona "Enviar invitación al viaje"
- Pantalla/Acción: Sistema envia correo electrónico con enlace de descarga
### Proceso: Verificar asistencia de usuario 
### Proceso: Eliminar usuarios del viaje
- Pantalla/Acción: usuario selecciona viaje
- Pantalla/Acción: usuario selecciona "eliminar participantes"
- Pantalla/Acción: usuario selecciona participante
- Pantalla/Acción: usuario confirma eleminacion
- Pantalla/Acción: sistema elimina participante del viaje
### Proceso: Consultar itinerario
- Pantalla/Acción: Usuario selecciona viaje actual
- Pantalla/Acción: Usuario presiona "consultar itinerario"
- Pantalla/Acción: Sistema obtine datos del viaje asociado
- Pantalla/Acción: sistema carga itinerario
- Pantalla/Acción: usuario visualiza itinerario
### Proceso: Editar itinerario
- Pantalla/Acción: Usuario selecciona viaje actual
- Pantalla/Acción: usuario selecciona editar  itinerario
- Pantalla/Acción: usuario realiza cambios
- Pantalla/Acción: sistema actualiza cambios
## Módulo: Comunicación
### Proceso: Activar "Walkie-Talkie" con grupo
- Pantalla/Acción: Usuario selecciona “Walkie-talkie”
- Pantalla/Acción: Sistema establece conexión con el grupo
- Pantalla/Acción: Sistema envía notificación emergente
- Pantalla/Acción: Sistema inicia canal de voz
- Pantalla/Acción: Usuario selecciona "Finalizar"
### Proceso: Ver chat grupal  de viaje *
- Pantalla/Acción: Usuario selecciona  "Chat de viaje"
- Pantalla/Acción: Sistema despliega pantalla de chat grupal
- Pantalla/Acción: Sistema actualiza mensajes
### Proceso: Creación de alertas personalizadas
- Pantalla/Acción: Usuario selecciona "alertas"
- Pantalla/Acción: Sistema carga y despliega pantalla de alertas
- Pantalla/Acción: Usuario selecciona nueva alerta
- Pantalla/Acción: Sistema carga y muestra formulario 
- Pantalla/Acción: Usuario rellena formulario
- Pantalla/Acción: Usuario selecciona "crear alerta"
### Proceso: Edición de alertas personalizadas
- Pantalla/Acción: Usuario selecciona "alerta"
- Pantalla/Acción: Sistema carga y  despliega pantalla de alertas
- Pantalla/Acción: Usuario selecciona una alerta
- Pantalla/Acción: Sistema carga y muestra datos de alerta
- Pantalla/Acción: Usuario mofica la alerta
- Pantalla/Acción: Usuario selecciona "modificar alerta"
### Proceso: Eliminación de alertas personalizadas
- Pantalla/Acción: Usuario selecciona "alerta"
- Pantalla/Acción: Sistema carga y  despliega pantalla de alertas
- Pantalla/Acción: Usuario selecciona una alerta
- Pantalla/Acción: Sistema carga y muestra datos de alerta
- Pantalla/Acción: Usuario selecciona "eliminar alerta"
## Módulo: ubicación
### Proceso: visualización de mapa interactivo
- Pantalla/Acción: Usuario selecciona "Ubicación"
- Pantalla/Acción: Sistema muestra mapa interactivo
- Pantalla/Acción: usuario visualiza mapa interactivo
### Proceso: Recibir alerta de turistas alejados
- Pantalla/Acción: Sistema obtiene ubicacion de turistas
- Pantalla/Acción: sistema consulta ubicación de referencia establecida
- Pantalla/Acción: sistema calcula distancia entre turista y referencia
- Pantalla/Acción:  sistema genera notificación de turista lejano
- Pantalla/Acción: Usuario recibe notificación de turista lejano
### Proceso: indicar punto de reunion en el mapa interactivo
- Pantalla/Acción: Usuario selecciona "Indicar punto de reunión"
- Pantalla/Acción: Sistema muestra mapa interactivo
- Pantalla/Acción: Usuario marca punto de reunión en el mapa
- Pantalla/Acción: sistema guarda punto de reunión 
- Pantalla/Acción: Sistema envia notificación a los usuarios en el viaje
- Pantalla/Acción: Usuarios en el viaje reciben punto de reunión
- Pantalla/Acción: Usuario selecciona  "Idioma"
- Pantalla/Acción: Sistema despliega lista de idiomas disponibles
- Pantalla/Acción: Usuario selecciona el idioma deseado
- Pantalla/Acción: Sistema guarda preferencias de idioma seleccionado
- Pantalla/Acción: Sistema actualiza idioma
- Pantalla/Acción: Usuario selecciona “Cambiar tema de la aplicación”
- Pantalla/Acción: Sistema muestra temas disponibles
- Pantalla/Acción: Usuario selecciona tema deseado
- Pantalla/Acción: Sistema aplica el tema seleccionado
- Pantalla/Acción: Sistema guarda preferencias de tema seleccionado
### Proceso: Configurar alertas específicas
- Pantalla/Acción: Usuario selecciona “Configurar alertas”
- Pantalla/Acción: Sistema muestra alertas para configurar
- Pantalla/Acción: Usuario configura alertas
- Pantalla/Acción: Sistema guarda configuración de alertas

