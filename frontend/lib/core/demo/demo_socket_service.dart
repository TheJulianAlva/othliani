import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'demo_config.dart';

/// Singleton que gestiona la conexión Socket.IO al servidor Railway durante la demo.
///
/// Uso en App Turista (Fase 3):
///   DemoSocketService.instance.emitPanic();
///
/// Uso en App Guía:
///   DemoSocketService.instance.onPanic.listen((data) { ... });
class DemoSocketService {
  static final DemoSocketService instance = DemoSocketService._();
  DemoSocketService._();

  io.Socket? _socket;
  final _panicController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream que emite un evento cada vez que un turista activa el pánico.
  Stream<Map<String, dynamic>> get onPanic => _panicController.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// Conecta al servidor Railway y se une al canal del viaje demo.
  /// Sin efecto si [kDemoMode] es false o si ya está conectado.
  void connect() {
    if (!kDemoMode) return;
    if (isConnected) return;

    _socket = io.io(
      kDemoServerUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      _socket!.emit('joinTrip', kDemoTripId);
    });

    _socket!.on('turista_panico', (data) {
      if (data is Map && !_panicController.isClosed) {
        _panicController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Emite el evento de pánico desde la App Turista hacia el servidor.
  void emitPanic() {
    if (!isConnected) return;
    _socket!.emit('turista_panico', {
      'tripId': kDemoTripId,
      'nombre': kDemoTuristaNombre,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
