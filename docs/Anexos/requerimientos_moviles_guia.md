# OthliAni - Plataforma Móvil (Rol Guía)

## Módulo: Cuenta Agencia
### Proceso: Iniciar sesión con agencia
- **Actividad:** Usuario abre OthliAni Guia

- **Actividad:** Usuario selecciona "Tengo cuenta de agencia"

- **Actividad:** Sistema muestra formulario de inicio de sesión 

- **Actividad:** Usuario ingresa datos

- **Actividad:** Sistema verifica credenciales 

- **Actividad:** Sistema otorga acceso

### Proceso: Cerrar sesión
- **Actividad:** Usuario selecciona la opción "Cerrar sesión"

- **Actividad:** Sistema verifica solicitud de cierre de sesión

- **Actividad:** Sistema elimina sesión activa del usuario

- **Actividad:** Sistema borra datos temporales

- **Actividad:** Sistema redirige a pantalla de iniciar sesión



## Módulo: Cuenta
### Proceso: Registrarse

- **Actividad:** Usuario abre OthliAni Guia

- **Actividad:** Usuario selecciona "Registro"










### Proceso: Iniciar sesión
- **Actividad:** Usuario selecciona "Ingresar"

- **Actividad:** Sistema muestra formulario de inicio de sesión 

- **Actividad:** Usuario ingresa información solicitada.

- **Actividad:** Usuario selecciona "Ingresar"

- **Actividad:** Sistema verifica las credenciales 
    - Sistematizable: Si
    - Restricciones: Los campos no deben estar vacíos, el correo debe tener formato válido; el correo debe estar registrado en la base de datos de cuentas de usuarios/turistas. La contraseña ingresada debe ser correcta.
    - Validaciones: Validar que la cuenta del usuario exista y que la contraseña coincida con la registrada.
    - Excepciones: Si el usuario no existe, mostrar: “El correo no está registrado”; si la contraseña no coincide, mostrar: “Contraseña incorrecta”.

- **Actividad:** Sistema otorga acceso
    - Sistematizable: SI
    - Restricciones: La cuenta no debe estar bloqueada o suspendida.
    - Validaciones: Verificar que la cuenta no cuente con restricciones de uso.

- **Actividad:** Sistema redirige a pantalla principal del usuario
    - Sistematizable: Si

### Proceso: Recuperar Contraseña
- **Actividad:** Usuario selecciona la opción “Olvidé mi contraseña”

- **Actividad:** Sistema muestra un formulario solicitando el correo electrónico vinculado a la cuenta
    - Sistematizable: Si
    - Restricciones: Sistema solo debe permitir correos con formato válido.
    - Validaciones: Validar formato correcto del correo ingresado. Que este no posea espacios y debe poseer un "@". Antes y después del "@" debe aver caracteres y debe tener un  "." después del "@".
    - Excepciones: Si el correo no cumple formato válido, mostrar mensaje: “Ingrese un correo válido”.

- **Actividad:** Usuario ingresa su correo electrónico

- **Actividad:** Usuario envía la solicitud

- **Actividad:** Sistema genera un enlace temporal
    - Sistematizable: Si
    - Restricciones: El correo solo puede enviarse a un correo registrado.
    - Validaciones: Verificar que el correo esté registrado en la base de datos.
    - Excepciones: Si el correo no se puede enviar, mostrar mensaje: “Error al enviar el correo, intente más tarde”.

- **Actividad:** Usuario ingresa al enlace

- **Actividad:** Sistema muestra formulario para ingresar nueva contraseña
    - Sistematizable: Si
    - Restricciones: El enlace/ticket de acceso no debe de haber sido usado anteriormente.
    - Validaciones: Validar que el enlace/ticket no esté expirado ni haya sido usado antes.

- **Actividad:** Usuario registra nueva contraseña

- **Actividad:** Usuario selecciona "Crear nueva contraseña"

- **Actividad:** Sistema verifica nueva contraseña
    - Sistematizable: Si
    - Restricciones: La nueva contraseña debe tener el formato indicado y no debe ser igual a la anterior.
    - Validaciones: La nueva contraseña debe ser diferente a la puesta anteriormente. Debe poseer por lo menos un caracter en mayúsculas, uno en minúsculas, un símbolo y un número.

- **Actividad:** Sistema actualiza la contraseña en la base de datos.
    - Sistematizable: Si
    - Restricciones: La nueva contraseña debe tener el formato indicado.
    - Validaciones: Validar que los campos no estén vacios, que ambos campos coincidan, que la contraseña tenga el formato indicado.

- **Actividad:** Sistema muestra mensaje de confirmación indicando que los cambios se guardaron con éxito
    - Sistematizable: Si

- **Actividad:** Sistema redirige a pantalla de iniciar sesión
    - Sistematizable: Si

### Proceso: Cerrar sesión
- **Actividad:** Usuario selecciona la opción "Cerrar sesión"

- **Actividad:** Sistema verifica solicitud de cierre de sesión
    - Sistematizable: Si
    - Restricciones: El usuario no se debe encontrar en un viaje.
    - Validaciones: El usuario no está en un viaje en ese momento.

- **Actividad:** Sistema elimina sesión activa del usuario
    - Sistematizable: Si

- **Actividad:** Sistema borra datos temporales
    - Sistematizable: Si

- **Actividad:** Sistema redirige a pantalla de iniciar sesión
    - Sistematizable: Si




### Proceso: Ver perfil
- **Actividad:** Usuario selecciona "Perfil"

- **Actividad:** Sistema consulta información asociada con cuenta
    - Sistematizable: Si
    - Restricciones: Debe de haber una sesión activa autenticada.
    - Validaciones: Verificar existencia de una sesión  activa

- **Actividad:** Sistema muestra información de perfil
    - Sistematizable: Si
    - Excepciones: Si ocurre un error en la visualización, mostrar mensaje: “No es posible mostrar el perfil en este momento, intente más tarde”.

- **Actividad:** Usuario visualiza su información de perfil

## Módulo: Viajes
### Proceso: Dar de alta usuarios del viaje
- **Actividad:** Usuario selecciona "Añadir participantes al viaje"
    - Observaciones: El usuario puede agregar participantes al viaje si se tiene un plan en la aplicacion o en su defecto la agencia responsable

- **Actividad:** Sistema muestra formulario para ingresar datos del turista
    - Sistematizable: SI

- **Actividad:** Usuario ingresa datos
    - Restricciones: los campos no deben estar vacios y el correo debe ser valido
    - Validaciones: Validar que los campos no esten vacios y el correo sea valido
    - Observaciones: Los datos requeridos son nombre completo, Telefono, correo....

- **Actividad:** Usuario selecciona "Enviar invitación al viaje"
    - Restricciones: El correo registrado debe ser valio y debe existir
    - Validaciones: Validar que el correo que se ha mandado haya sido respondido o se haya mandado correctamente
    - Excepciones: Si el correo no existe, se mostrara un mensaje con la siguiente leyenda "Correo no valido"
    - Observaciones: La invitacion enviada via correo solo sera valida durante un periodo de tiempo definido

- **Actividad:** Sistema envia correo electrónico con enlace de descarga
    - Sistematizable: SI

### Proceso: Verificar asistencia de usuario 





### Proceso: Eliminar usuarios del viaje
- **Actividad:** usuario selecciona viaje
    - Restricciones: El viaje debe existir y estar activo al momento de hacer cambios
    - Validaciones: Validar la existencia del viaje
    - Excepciones: Si el viaje no existe o esta finalizado mostrar "No se puede seleccionar"
    - Observaciones: Se dene tener permisos de agencia para poder realizar esta accion o en su defecto un usuario con un plan de paga tiene habilitada esta accion

- **Actividad:** usuario selecciona "eliminar participantes"
    - Restricciones: se deben tener permisos para modificar la lista de participantes
    - Validaciones: validar que el usuario tenga el rol adecuado
    - Observaciones: La opcion solo es visible si se tiene el rol de guia o un plan de paga y esta disponible si hay almenos un participante en el viaje

- **Actividad:** usuario selecciona participante
    - Restricciones: El participante debe estar asociado al viaje
    - Validaciones: validar que el correo del participante o identificador del mismo exita en el viaje
    - Observaciones: puede mostrarse informacion del participante antes de eliminar

- **Actividad:** usuario confirma eleminacion
    - Restricciones: Confirmacion por parte del usuario(boton)
    - Validaciones: validar el estado del boton
    - Observaciones: mostrar advertensia

- **Actividad:** sistema elimina participante del viaje
    - Sistematizable: SI
    - Observaciones: se actualiza la lista de particiapntes del viaje y se manda notificacion al usuario que fue eliminado

### Proceso: Consultar itinerario
- **Actividad:** Usuario selecciona viaje actual
    - Observaciones: El viaje estara disponible en la pantalla principal del usuario para perimitr ver el itinerario de  manera rapida

- **Actividad:** Usuario presiona "consultar itinerario"

- **Actividad:** Sistema obtine datos del viaje asociado
    - Sistematizable: SI
    - Restricciones: El viaje debe existir y estar activo al momento de la consulta.
    - Validaciones: Validar que el viaje exista y se encuentre activo

- **Actividad:** sistema carga itinerario
    - Sistematizable: SI

- **Actividad:** usuario visualiza itinerario

### Proceso: Editar itinerario
- **Actividad:** Usuario selecciona viaje actual
    - Restricciones: El viaje debe existir y estar activo al momento de hacer cambios

- **Actividad:** usuario selecciona editar  itinerario

- **Actividad:** usuario realiza cambios
    - Restricciones: los campos modificados deben cumplir  el formato establecido
    - Validaciones: validar fechas, horas, ubicaciones y campos no vacios
    - Excepciones: Si hay inconsistencias mostrar el mensaje "Conflicto de horarios u/o informacion"
    - Observaciones: Se pueden realizar cambios dependiendo de los permisos de la agencia, un usuario con un plan de pago tiene habilitada la opcion

- **Actividad:** sistema actualiza cambios
    - Sistematizable: SI
    - Observaciones: Se mandan notificaciones a los participantes del viaje notificando cambios en el horario y se guardan datos de modificaciones como quien, cuando y que modifico

## Módulo: Comunicación
### Proceso: Activar "Walkie-Talkie" con grupo
- **Actividad:** Usuario selecciona “Walkie-talkie”

- **Actividad:** Sistema establece conexión con el grupo
    - Sistematizable: Sí
    - Restricciones: Se requiere conexión a internet activa (datos o WiFi).
    - Validaciones: Validar que el dispositivo tenga acceso a internet.
    - Excepciones: Si no hay conexión, mostrar mensaje: “No es posible conectar. Revisa tu conexión”.

- **Actividad:** Sistema envía notificación emergente
    - Sistematizable: Sí
    - Restricciones: El grupo debe tener una sesión activa con algún dispositivo.
    - Validaciones: Validar que el grupo tenga una sesión activa con algún dispositivo.
    - Observaciones: Sistema envía notificación emergente a todo el grupo.

- **Actividad:** Sistema inicia canal de voz
    - Sistematizable: Sí
    - Excepciones: Si la conexión falla, mostrar mensaje: “Error al iniciar comunicación”.

- **Actividad:** Usuario selecciona "Finalizar"
    - Excepciones: Si no se logra cerrar, terminar automáticamente la sesión tras un tiempo determinado.

### Proceso: Ver chat grupal  de viaje *
- **Actividad:** Usuario selecciona  "Chat de viaje"

- **Actividad:** Sistema despliega pantalla de chat grupal
    - Sistematizable: Si
    - Restricciones: Debe de haber un viaje activo; el viaje activo debe tener un chat grupal habilitado.
    - Validaciones: Validar que usuario se encuentre en un viaje activo, con un chat grupal habilitado.
    - Excepciones: Si el chat no existe, mostrar mensaje: “Este viaje no tiene chat habilitado”.

- **Actividad:** Sistema actualiza mensajes
    - Sistematizable: Si
    - Restricciones: El usuario debe tener una conexión a internet para poder recibir mensajes nuevos en tiempo real.
    - Validaciones: Validar que el usuario tenga una conexión a internet para recibir mensajes en tiempo real.

### Proceso: Creación de alertas personalizadas
- **Actividad:** Usuario selecciona "alertas"

- **Actividad:** Sistema carga y despliega pantalla de alertas
    - Sistematizable: Si
    - Restricciones: Debe de haber un viaje activo; el viaje activo debe tener un chat grupal habilitado.
    - Validaciones: Validar que usuario se encuentre en un viaje activo, con un chat grupal habilitado.
    - Excepciones: Si el chat no existe, mostrar mensaje: “Este viaje no tiene chat habilitado”.

- **Actividad:** Usuario selecciona nueva alerta
    - Sistematizable: Si
    - Restricciones: El usuario debe tener una conexión a internet para poder recibir mensajes nuevos en tiempo real.
    - Validaciones: Validar que el usuario tenga una conexión a internet para recibir mensajes en tiempo real.

- **Actividad:** Sistema carga y muestra formulario 

- **Actividad:** Usuario rellena formulario
    - Sistematizable: Si

- **Actividad:** Usuario selecciona "crear alerta"

    - Sistematizable: Si


    - Restricciones: El usuario debe tener una conexión a internet para poder enviar la alerta.
    - Validaciones: Validar que el usuario tenga una conexión a internet para enviar la alerta.
    - Excepciones: Si la conexión es fallida, mostrar mensaje "No se puede enviar la alerta, no tiene conexión a internet".

### Proceso: Edición de alertas personalizadas

    - Sistematizable: Si
    - Restricciones: Debe de haber un viaje activo; el viaje activo debe tener un chat grupal habilitado.
    - Validaciones: Validar que usuario se encuentre en un viaje activo, con un chat grupal habilitado.
    - Excepciones: Si el chat no existe, mostrar mensaje: “Este viaje no tiene chat habilitado”.

    - Sistematizable: Si
    - Restricciones: El usuario debe tener una conexión a internet para poder recibir mensajes nuevos en tiempo real.
    - Validaciones: Validar que el usuario tenga una conexión a internet para recibir mensajes en tiempo real.

- **Actividad:** Usuario selecciona "alerta"

- **Actividad:** Sistema carga y  despliega pantalla de alertas
    - Sistematizable: Si

- **Actividad:** Usuario selecciona una alerta

- **Actividad:** Sistema carga y muestra datos de alerta
    - Sistematizable: Si

- **Actividad:** Usuario mofica la alerta

- **Actividad:** Usuario selecciona "modificar alerta"
    - Restricciones: El usuario debe tener una conexión a internet para poder modificar la alerta.
    - Validaciones: Validar que el usuario tenga una conexión a internet para modificar la alerta.
    - Excepciones: Si la conexión es fallida, mostrar mensaje "No se puede modificar la alerta, no tiene conexión a internet".

### Proceso: Eliminación de alertas personalizadas

    - Sistematizable: Si
    - Restricciones: Debe de haber un viaje activo; el viaje activo debe tener un chat grupal habilitado.
    - Validaciones: Validar que usuario se encuentre en un viaje activo, con un chat grupal habilitado.
    - Excepciones: Si el chat no existe, mostrar mensaje: “Este viaje no tiene chat habilitado”.

    - Sistematizable: Si
    - Restricciones: El usuario debe tener una conexión a internet para poder recibir mensajes nuevos en tiempo real.
    - Validaciones: Validar que el usuario tenga una conexión a internet para recibir mensajes en tiempo real.

- **Actividad:** Usuario selecciona "alerta"

- **Actividad:** Sistema carga y  despliega pantalla de alertas
    - Sistematizable: Si

- **Actividad:** Usuario selecciona una alerta

- **Actividad:** Sistema carga y muestra datos de alerta
    - Sistematizable: Si

- **Actividad:** Usuario selecciona "eliminar alerta"
    - Restricciones: El usuario debe tener una conexión a internet para poder eliminar la alerta.
    - Validaciones: Validar que el usuario tenga una conexión a internet para eliminar la alerta.
    - Excepciones: Si la conexión es fallida, mostrar mensaje "No se puede eliminar la alerta, no tiene conexión a internet".

## Módulo: ubicación
### Proceso: visualización de mapa interactivo
- **Actividad:** Usuario selecciona "Ubicación"

- **Actividad:** Sistema muestra mapa interactivo
    - Sistematizable: Si
    - Restricciones: El usuario debe tener conexion a internet y GPS activo
    - Validaciones: Verificar que la ubicacion tenga permisos de ubicacion concedidos
    - Excepciones: S i no hay permisos de ubicacion o de internet el mapa no  se mostrara

- **Actividad:** usuario visualiza mapa interactivo

### Proceso: Recibir alerta de turistas alejados
- **Actividad:** Sistema obtiene ubicacion de turistas
    - Sistematizable: Si
    - Restricciones: Los turistas deben tener permisos de ubicacion activados y conexion a internet
    - Validaciones: verificar que haya acceso a internet y permisis concedidos
    - Excepciones: Si no se obtienen los permisos del Usuario no se puede obtener la ubicacion

- **Actividad:** sistema consulta ubicación de referencia establecida
    - Restricciones: Debe de haber una referencia de ubicacion registrada en el sistema
    - Validaciones: verificar que la referencia este correctamente guardada
    - Observaciones: la referencia puede cambiar segun los eventos del itinerario

- **Actividad:** sistema calcula distancia entre turista y referencia
    - Sistematizable: Si
    - Restricciones: sistema debe tenr las ubucaciones de ambos puntos
    - Validaciones: verificar los datos de coordenadas
    - Excepciones: No se generara el calculo de la distancia en caso de no tener alguno de los datos faltantes o erroneos

- **Actividad:**  sistema genera notificación de turista lejano
    - Sistematizable: Si
    - Restricciones: sistema debe detectar que la distancia supera al umbral configurado
    - Validaciones: Validar la distancia de configuracion
    - Excepciones: Si no se supera el umbral el sistema no manda notificacion
    - Observaciones: La notificacion puede tener datos como Turista, Distancia aproximada

- **Actividad:** Usuario recibe notificación de turista lejano
    - Sistematizable: Si
    - Restricciones: El usuario debe tener sesion activa en el viaje
    - Validaciones: Validar que la notificacion se mando correctamente
    - Excepciones: En caso de fallas de conexion hay retraso en la notificacion
    - Observaciones: la notificacion puede ser visual o sonora para capturar l atencion del usuario

### Proceso: indicar punto de reunion en el mapa interactivo

- **Actividad:** Usuario selecciona "Indicar punto de reunión"
    - Restricciones: El usuario debe tenr un viaje activo y permisos de ubicacion activados
    - Validaciones: verificar que el usuario exista dentro dle viaje con el rol de guia
    - Excepciones: Si no hay viajes activos se muestra el mensaje "No hay viajes disponibles para asignar un punto de reunion"
    - Observaciones: La opcion estara deshabilitada si no hay un viaje en curso

- **Actividad:** Sistema muestra mapa interactivo
    - Sistematizable: Si
    - Restricciones: El usuario debe tener conexion a internet y GPS activo
    - Validaciones: Verificar que la ubicacion tenga permisos de ubicacion concedidos

- **Actividad:** Usuario marca punto de reunión en el mapa
    - Restricciones: El punto debe estra dentro de la ciudad del viaje
    - Validaciones: verificar que sean coordenadas validas

- **Actividad:** sistema guarda punto de reunión 
    - Sistematizable: Si
    - Observaciones: pueden agregarse datos de descripcion del punto de referencia

- **Actividad:** Sistema envia notificación a los usuarios en el viaje
    - Sistematizable: Si
    - Restricciones: debe haber usuarios asociados al viaje
    - Validaciones: verificar que el punto  de reunioin tenga datos validos

- **Actividad:** Usuarios en el viaje reciben punto de reunión
    - Sistematizable: Si

- **Actividad:** Usuario selecciona  "Idioma"

- **Actividad:** Sistema despliega lista de idiomas disponibles

- **Actividad:** Usuario selecciona el idioma deseado
    - Sistematizable: Si

- **Actividad:** Sistema guarda preferencias de idioma seleccionado

- **Actividad:** Sistema actualiza idioma
    - Sistematizable: Si

- **Actividad:** Usuario selecciona “Cambiar tema de la aplicación”
    - Sistematizable: Si
    - Restricciones: La aplicación debe contar con traducciones completas para el idioma seleccionado.
    - Validaciones: Validar que todas las secciones visibles cambien correctamente al idioma elegido.

- **Actividad:** Sistema muestra temas disponibles

- **Actividad:** Usuario selecciona tema deseado
    - Sistematizable: Si

- **Actividad:** Sistema aplica el tema seleccionado

- **Actividad:** Sistema guarda preferencias de tema seleccionado
    - Sistematizable: Si
    - Restricciones: Todos los componentes deben soportar cambio de tema.
    - Validaciones: Validar que todos los componentes de la aplicación soporten tema seleccionado.
    - Excepciones: Si algún componente no soporta el cambio, se mantiene con el diseño por defecto.

### Proceso: Configurar alertas específicas
- **Actividad:** Usuario selecciona “Configurar alertas”
    - Sistematizable: Si

- **Actividad:** Sistema muestra alertas para configurar

- **Actividad:** Usuario configura alertas
    - Sistematizable: Si
    - Restricciones: Deben estar habilitados los permisos del dispositivo para mostrar notificaciones.
    - Validaciones: Validar que la aplicación tenga permisos activos en el dispositivo para enviar notificaciones.
    - Excepciones: Si el usuario deniega permisos del dispositivo, no se mostrarán notificaciones aunque estén activadas en la app.

- **Actividad:** Sistema guarda configuración de alertas

    - Sistematizable: Si
    - Restricciones: Solo se pueden guardar configuraciones que correspondan a alertas habilitadas.
    - Validaciones: Validar que la selección del usuario coincida con una alerta válida y que se guarde correctamente en su perfil.
    - Excepciones: Si ocurre un error, se mantiene la configuración anterior como respaldo.










