class RoutesAgencia {
  // Rutas de Autenticación (Fuera del Menú Principal)
  static const String login = '/login';
  static const String recoverPassword = '/recover-password';

  // Rutas Principales (Dentro del Shell/Sidebar)
  static const String root = '/'; // Redirige a dashboard
  static const String dashboard = '/dashboard';

  static const String viajes = '/viajes';
  static const String detalleViaje = 'detalle'; // Sub-ruta: /viajes/:id
  static const String nuevoViaje = 'nuevo';

  static const String usuarios = '/usuarios'; // Con tabs ?tab=guias

  static const String auditoria = '/auditoria'; // Con filtros ?nivel=critico

  static const String configuracion = '/configuracion';
}
