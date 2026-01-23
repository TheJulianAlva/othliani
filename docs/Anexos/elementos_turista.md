# Descripción detallada de elementos del Turista (App Móvil)


## Módulo: General

### Actividad: Usuario abre OthliAni 

**Proceso:** (Sin proceso especificado)

- **Observaciones:** En caso de no tener descargada la aplicación se, el enlace redirigira a la playstore o appstore según sea el caso



### Actividad: Usuario ingresa número de folio 

**Proceso:** (Sin proceso especificado)

- **Observaciones:** El número de folio corresponde al viaje en el que ha sido registrado el usuario.



### Actividad: Sistema busca viaje por folio

**Proceso:** (Sin proceso especificado)

- **Restricciones:** El folio debe pertenecer a un viaje activo que acepte usuarios.

- **Validaciones:** Validar que el viaje con folio ingresado exista y acepte usuarios nuevos.

- **Excepciones:** Si el folio ya fue ocupado o no es valido, mostrar mensaje: "Error, el folio ya ha sido ocupado o es invalido, intentelo nuevamente"



### Actividad: Sistema redirige a formulario de registro

**Proceso:** (Sin proceso especificado)

- **Observaciones:** El número de telefono del usuario se utilizará para vincular a él la cuenta de turista que sea creada. El usuario ya tendrá información registrada en su cuenta previamente, los datos que se soliciten serán solamente para completar su registro y personalización.



### Actividad: Usuario ingresa datos

**Proceso:** (Sin proceso especificado)



### Actividad: Usuario acepta  "Términos y Condiciones"

**Proceso:** (Sin proceso especificado)



### Actividad: Usuario acepta "Aviso de privacidad"

**Proceso:** (Sin proceso especificado)



### Actividad: Usuario selecciona "Crear cuenta"

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema registra cuenta 

**Proceso:** (Sin proceso especificado)

- **Restricciones:** No se debe permitir guardar datos incompletos o inválidos; el usuario debe de haber aceptado "Términos y Condiciones" y "Aviso de Privacidad" para poder crear una cuenta; el registro de correo electrónico debe ser único.

- **Validaciones:** Validar que todos los campos necesarios tengan información, y que los datos sean válidos; validar que el usuario haya aceptado los documentos requeridos; validar que el correo es único en la base de datos.

- **Excepciones:** Si ocurre un error en la inserción de datos, mostrar mensaje: “Error al crear la cuenta, intente más tarde”.



### Actividad: Sistema redirige a pantalla de iniciar sesión

**Proceso:** (Sin proceso especificado)



### Actividad: Usuario selecciona "Iniciar sesión"

**Proceso:** Iniciar sesión

- **Observaciones:** Si hay una sesión activa ya no se muestra pantalla para inicio de sesión, el sistema abre automáticamente la pantalla principal de la cuenta activa.



### Actividad: Sistema muestra formulario de inicio de sesión

**Proceso:** (Sin proceso especificado)



### Actividad: Usuario ingresa información solicitada

**Proceso:** (Sin proceso especificado)



### Actividad: Usuario selecciona "Ingresar"

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema verifica las credenciales

**Proceso:** (Sin proceso especificado)

- **Restricciones:** Los campos no deben estar vacíos, el correo debe tener formato válido; el correo debe estar registrado en la base de datos de cuentas de usuarios/turistas. La contraseña ingresada debe ser correcta; la cuenta no debe estar bloqueada o suspendida.

- **Validaciones:** Validar que la cuenta del usuario exista y que la contraseña coincida con la registrada; verificar que la cuenta no cuente con restricciones de uso y que siga activa.

- **Observaciones:** Las cuentas de turista están limitadas a su uso mientras se encuentren en un viaje, despues de un tiempo de haber concluido éste, la cuenta será eliminada.



### Actividad: Sistema  otorga acceso

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema redirige a pantalla principal

**Proceso:** (Sin proceso especificado)



### Actividad: Usuario selecciona “Olvidé mi contraseña”

**Proceso:** Recuperar Contraseña



### Actividad: Sistema solicita correo electrónico

**Proceso:** (Sin proceso especificado)

- **Restricciones:** Sistema solo debe permitir correos con formato válido; el correo ingresado debe pertenecer a una cuenta activa.

- **Validaciones:** Validar formato correcto del correo ingresado; validar que cuenta exista y se encuentre activa.

- **Excepciones:** Si el correo no cumple formato válido, mostrar mensaje: “Ingrese un correo válido”.



### Actividad: Usuario ingresa su correo electrónico

**Proceso:** (Sin proceso especificado)



### Actividad: Usuario selecciona "Enviar"

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema  envía enlace temporal a correo

**Proceso:** (Sin proceso especificado)

- **Restricciones:** El correo solo puede enviarse a un correo registrado.

- **Validaciones:** Verificar que el correo esté registrado en la base de datos.

- **Observaciones:** Se genera un enlace temporal y único de restablecimiento de contraseña y se manda al correo de la cuenta indicada.



### Actividad: Usuario ingresa a el enlace recibido

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema muestra formulario de restablecimiento

**Proceso:** (Sin proceso especificado)

- **Restricciones:** El enlace/ticket de acceso no debe de haber sido usado anteriormente.

- **Validaciones:** Validar que el enlace/ticket no esté expirado ni haya sido usado antes.



### Actividad: Usuario ingresa nueva contraseña

**Proceso:** (Sin proceso especificado)

- **Observaciones:** Indicar formato de contraseña **



### Actividad: Usuario selecciona "Cambiar contraseña"

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema actualiza contraseña

**Proceso:** (Sin proceso especificado)

- **Restricciones:** La nueva contraseña debe tener el formato indicado.

- **Validaciones:** Validar que los campos no estén vacios; que la contraseña tenga el formato indicado.

- **Observaciones:** Indica que el cambio fue exitoso y que puede salir de la pestaña.



### Actividad: Usuario selecciona "Cerrar sesión"

**Proceso:** Cerrar sesión

- **Observaciones:** Al cerrar sesión el sistema debe mantener el folio de cuenta registrado con el teléfono celular en caso de que el usuario desee volver a iniciar sesión en la cuenta. En caso de eliminación de cuenta, el sistema ya no permitirá el inicio de sesión nuevamente.



### Actividad: Sistema elimina sesión activa

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema borra datos temporales

**Proceso:** (Sin proceso especificado)

- **Restricciones:** Sistema debe de mantener guardado folio asociado con teléfono para un posible re-inicio de sesión.

- **Validaciones:** Validar que sistema guarde folio de cuenta asociado con teléfono.



### Actividad: Sistema redirige a pantalla de inicio sesión

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema verifica status de cuenta

**Proceso:** Eliminar cuenta



### Actividad: Sistema notifica "Cuenta eliminada"

**Proceso:** (Sin proceso especificado)

- **Restricciones:** El estatus de la cuenta debe ser inactivo.

- **Validaciones:** Validar el estatus de la cuenta.



### Actividad: Sistema borra datos de la cuenta

**Proceso:** (Sin proceso especificado)



### Actividad: Usuario selecciona "Perfil"

**Proceso:** Ver perfil



### Actividad: Sistema consulta información asociada con cuenta

**Proceso:** (Sin proceso especificado)

- **Restricciones:** Debe de haber una sesión activa autenticada.

- **Validaciones:** Verificar existencia de una sesión  activa

- **Observaciones:** La consulta debe realizarse en tiempo real para mostrar información actualizada.



### Actividad: Sistema muestra información de perfil

**Proceso:** (Sin proceso especificado)

- **Excepciones:** Si ocurre un error en la visualización, mostrar mensaje: “No es posible mostrar el perfil en este momento, intente más tarde”.



### Actividad: Usuario visualiza su información de perfil

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema consulta información asociada con viaje

**Proceso:** (Sin proceso especificado)

- **Restricciones:** El viaje debe existir y estar activo al momento de la consulta.

- **Validaciones:** Validar que el viaje existe y esté activo.



### Actividad: Sistema muestra información de itinerario

**Proceso:** (Sin proceso especificado)



### Actividad: Usuario visualiza itinerario

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema identifica eventos próximos

**Proceso:** Recibir alertas automáticas de itinerario

- **Observaciones:** Sistema identifica eventos en el itinerario y de acuerdo a tiempos envía las alertas/recordatorios.



### Actividad: Sistema envía alerta con información de evento

**Proceso:** (Sin proceso especificado)

- **Restricciones:** El usuario debe tener notificaciones activas en su dispositivo.

- **Validaciones:** Validar que el usuario visualice las alertas.

- **Observaciones:** Puede incluir detalles adicionales como recomendaciones o recordatorios de transporte. Si no se puede enviar por un canal (ej. app sin conexión), reintentar por otro canal configurado (ej. correo)



### Actividad: Usuario recibe alerta

**Proceso:** (Sin proceso especificado)

- **Observaciones:** Puede configurarse prioridad de canales: notificación en app > correo > SMS.



### Actividad: Sistema establece conexión con guía

**Proceso:** (Sin proceso especificado)

- **Restricciones:** Se requiere conexión a internet activa (datos o WiFi).

- **Validaciones:** Validar que el dispositivo tenga acceso a internet.

- **Excepciones:** Si no hay conexión, mostrar mensaje: “No es posible conectar. Revisa tu conexión”.

- **Observaciones:** Puede implementarse usando VoIP o integración con llamada telefónica tradicional como respaldo.



### Actividad: Sistema envía notificación emergente a guía

**Proceso:** (Sin proceso especificado)

- **Restricciones:** El guía debe tener una sesión activa con algún dispositivo.

- **Validaciones:** Validar que el guía tenga una sesión activa con algún dispositivo.

- **Observaciones:** Se puede implementar reintento automático o redirección a un número de emergencia alterno.




### Actividad: Sistema inicia canal de voz

**Proceso:** (Sin proceso especificado)

- **Excepciones:** Si la conexión falla, mostrar mensaje: “Error al iniciar comunicación”.



### Actividad: Usuario selecciona "Finalizar"

**Proceso:** (Sin proceso especificado)

- **Excepciones:** Si no se logra cerrar, terminar automáticamente la sesión tras un tiempo determinado.

- **Observaciones:** El sistema debe registrar inicio y fin de la llamada para control administrativo.



### Actividad: Usuario selecciona  "Chat de viaje"

**Proceso:** Ver chat grupal  de viaje *

- **Observaciones:** Esta opción estará disponible desde el módulo de comunicación al tener un viaje activo al momento de abrir la aplicación.



### Actividad: Sistema despliega pantalla de chat grupal

**Proceso:** (Sin proceso especificado)

- **Restricciones:** Debe de haber un viaje activo; el viaje activo debe tener un chat grupal habilitado.

- **Validaciones:** Validar que usuario se encuentre en un viaje activo, con un chat grupal habilitado.

- **Excepciones:** Si el chat no existe, mostrar mensaje: “Este viaje no tiene chat habilitado”.

- **Observaciones:** Cada viaje tiene un chat grupal asociado donde poder comunicarse con el guía o entre sí.



### Actividad: Usuario visualiza mensajes

**Proceso:** (Sin proceso especificado)

- **Observaciones:** Los mensajes se mostrarán en orden cronológico.



### Actividad: Sistema actualiza nuevos mensajes

**Proceso:** (Sin proceso especificado)

- **Restricciones:** El usuario debe tener una conexión a internet para poder recibir mensajes nuevos en tiempo real.

- **Validaciones:** Validar que el usuario tenga una conexión a internet para recibir mensajes en tiempo real.

- **Observaciones:** Se puede crear una cola con mensajes pendientes por enviar en caso de que el usuario no tenga una conexión a internet para cuando restablezca su conexión.



### Actividad: Sistema muestra mapa interactivo

**Proceso:** (Sin proceso especificado)

- **Restricciones:** El usuario debe tener permisos de ubicación activados.

- **Validaciones:** Validar que la aplicación cuente con permisos de ubicación activados.

- **Observaciones:** Se muestra mapa con ubicaciones cercanas a ubicación del usuario, el usuario puede interactuar con mapa. El mapa muestra indicaciones especiales para próximos eventos en itinerario.



### Actividad: Usuario visualiza mapa

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema consulta próximo evento en itinerario

**Proceso:** Recibir alertas por lejanía

- **Restricciones:** Debe de haber eventos activos próximos en itinerario.

- **Validaciones:** Validar que existan eventos próximos con ubicaciones referidas.



### Actividad: Sistema consulta ubicación actual de usuario

**Proceso:** (Sin proceso especificado)

- **Restricciones:** El usuario debe tener permisos de ubicación activados.

- **Validaciones:** Validar que la aplicación cuente con permisos de ubicación activados.



### Actividad: Sistema consulta ubicación de referencia establecida

**Proceso:** (Sin proceso especificado)

- **Observaciones:** Esta ubicación referida puede ser la ubicación del guía, camión, o lugar acordado dentro del itinerario.



### Actividad: Sistema calcula distancia entre usuario y referencia

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema envía alerta de lejanía

**Proceso:** (Sin proceso especificado)

- **Restricciones:** Usuario debe estar más alejado en tiempo que próximo evento en itinerario, o debe estar más alejado que la distancia máxima indicada en viaje.

- **Validaciones:** Validar que usuario se encuentre lejano a próximo evento en itinerario

- **Observaciones:** La alerta se mostrará cuando el usuario se aleja más de la distancia máxima permitida o está demasiado lejos de la ubicación que debe volver pronto. Al interactuar con ella, se abre en la aplicación mapa interactivo con ubicación de evento próximo señalizada.



### Actividad: Usuario recibe alerta

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema despliega lista de idiomas disponibles

**Proceso:** (Sin proceso especificado)

- **Observaciones:** Debe de aparecer una opción que sincronice idioma con idioma del dispositivo.



### Actividad: Usuario selecciona el idioma deseado

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema guarda preferencias de idioma seleccionado

**Proceso:** (Sin proceso especificado)

- **Observaciones:** El cambio debe ser persistente incluso si el usuario cierra la aplicación.



### Actividad: Sistema actualiza idioma

**Proceso:** (Sin proceso especificado)

- **Restricciones:** La aplicación debe contar con traducciones completas para el idioma seleccionado.

- **Validaciones:** Validar que todas las secciones visibles cambien correctamente al idioma elegido.



### Actividad: Usuario selecciona “Cambiar tema de la aplicación”

**Proceso:** Cambiar tema de la aplicación

- **Observaciones:** Esta opción se encontrará disponible dentro del módulo de configuración de la aplicación.



### Actividad: Sistema muestra temas disponibles

**Proceso:** (Sin proceso especificado)

- **Observaciones:** Los temas disponibles son claro, oscuro, automático.



### Actividad: Usuario selecciona tema deseado

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema aplica el tema seleccionado

**Proceso:** (Sin proceso especificado)

- **Restricciones:** Todos los componentes deben soportar cambio de tema.

- **Validaciones:** Validar que todos los componentes de la aplicación soporten tema seleccionado.

- **Excepciones:** Si algún componente no soporta el cambio, se mantiene con el diseño por defecto.



### Actividad: Sistema guarda preferencias de tema seleccionado

**Proceso:** (Sin proceso especificado)

- **Observaciones:** El cambio debe ser persistente incluso si el usuario cierra la aplicación.



### Actividad: Usuario selecciona “Configurar alertas”

**Proceso:** Configurar alertas específicas

- **Observaciones:** Esta opción se encontrará disponible dentro del módulo de configuración de la aplicación.



### Actividad: Sistema muestra alertas para configurar

**Proceso:** (Sin proceso especificado)

- **Restricciones:** Deben estar habilitados los permisos del dispositivo para mostrar notificaciones.

- **Validaciones:** Validar que la aplicación tenga permisos activos en el dispositivo para enviar notificaciones.

- **Excepciones:** Si el usuario deniega permisos del dispositivo, no se mostrarán notificaciones aunque estén activadas en la app.

- **Observaciones:** Las alertas que estarán disponibles para configurar son: próximos eventos, cambios en itinerario, mensajes en chat grupal.



### Actividad: Usuario configura alertas

**Proceso:** (Sin proceso especificado)



### Actividad: Sistema guarda configuración de alertas

**Proceso:** (Sin proceso especificado)

- **Restricciones:** Solo se pueden guardar configuraciones que correspondan a alertas habilitadas.

- **Validaciones:** Validar que la selección del usuario coincida con una alerta válida y que se guarde correctamente en su perfil.

- **Excepciones:** Si ocurre un error, se mantiene la configuración anterior como respaldo.




## Módulo: Comunicación

### Actividad: Usuario selecciona “Walkie-talkie”

**Proceso:** Activar "Walkie-Talkie" con guía

- **Observaciones:** Este botón debe estar destacado para uso rápido; el botón solo aparece cuando el usuario tiene un viaje activo con un guía asignado.




## Módulo: Configuración

### Actividad: Usuario selecciona  "Idioma"

**Proceso:** Cambiar idioma de la aplicación 

- **Observaciones:** Esta opción se encontrará disponible dentro del módulo de configuración de la aplicación.




## Módulo: Cuenta

### Actividad: Usuario recibe notificación de alta

**Proceso:** Crear cuenta

- **Observaciones:** Las activiades descritas vienen precedidas de haber dado de alta al usuario en un viaje de agencia o personal, el enlace será enviado por correo electrónico o SMS




## Módulo: Ubicación

### Actividad: Usuario selecciona "Ubicación"

**Proceso:** Ver mapa interactivo




## Módulo: Viajes

### Actividad: Usuario seleciona viaje actual

**Proceso:** Consultar itinerario

- **Observaciones:** El viaje estará disponible desde la pantalla principal de usuario, donde podrá consultar de manera fácil el itinerario.


