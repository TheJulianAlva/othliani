import 'package:geolocator/geolocator.dart';

/// Wrapper service for Geolocator to simplify permission handling and timeouts,
/// specifically designed to not block critical paths like the SOS protocol.
class LocationService {
  /// Intenta obtener la posición actual del dispositivo con alta precisión.
  ///
  /// Si los servicios de ubicación están deshabilitados, los permisos son
  /// denegados, o si la solicitud toma más de 5 segundos, retorna [null]
  /// para no bloquear la ejecución del llamador (ej. protocolo SOS).
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio GPS está encendido
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // GPS apagado a nivel de sistema operativo
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // El usuario denegó el permiso
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // Permiso denegado permanentemente
    }

    try {
      // Intentar obtener la posición. Limitamos a 5 segundos para que
      // en caso de mala señal (ej. en una montaña), el SOS no se quede colgado.
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      // Ej. TimeoutException u otros errores de hardware
      return null;
    }
  }
}
