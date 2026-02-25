abstract class SucesionMandoRepository {
  Future<void> transferirMandoAgencia({
    required String sucesorId,
    required String sucesorNombre,
    required String viajeId,
  });

  Future<void> notificarDashboardAgencia({
    required String viajeId,
    required double lat,
    required double lng,
  });

  Future<void> enviarSmsEmergencia({
    required String telefono,
    required String nombreContacto,
    required double lat,
    required double lng,
  });

  Future<void> marcarProtocolo911({required double lat, required double lng});
}
