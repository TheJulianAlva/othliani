import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../domain/repositories/agencia_repository.dart'; // ✨ Nuevo Import

// --- EVENTOS ---
abstract class SyncEvent {}

// Este evento se dispara automáticamente cuando el dispositivo avisa un cambio
class ConnectionChangedEvent extends SyncEvent {
  final List<ConnectivityResult> result;
  ConnectionChangedEvent(this.result);
}

// --- ESTADOS ---
enum SyncStatus { online, syncing, offline }

class SyncState {
  final SyncStatus status;
  final String label;
  final String
  lastUpdated; // Mantener compatibilidad con UI anterior si es necesario

  SyncState({
    required this.status,
    required this.label,
    this.lastUpdated = "Ahora",
  });
}

// --- BLOC ---
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  final AgenciaRepository repository; // ✨ Nueva dependecia

  SyncBloc({required this.repository})
    : super(SyncState(status: SyncStatus.online, label: "Verificando...")) {
    // 1. AL INICIAR: Nos suscribimos al stream del repositorio
    _subscription = repository.onConnectivityChanged.listen((result) {
      add(ConnectionChangedEvent(result));
    });

    // 2. LÓGICA DE REACCIÓN
    on<ConnectionChangedEvent>((event, emit) async {
      // Analizamos qué tipo de conexión tenemos
      final result = event.result;

      if (result.contains(ConnectivityResult.none)) {
        // CASO A: No hay red
        emit(
          SyncState(
            status: SyncStatus.offline,
            label: "Modo Offline",
            lastUpdated: "Hace un momento",
          ),
        );
      } else {
        // CASO B: Hay red (WiFi, Móvil, Ethernet)
        // Primero mostramos "Conectando..." para que se vea que trabaja
        emit(
          SyncState(
            status: SyncStatus.syncing,
            label: "Sincronizando...",
            lastUpdated: "Conectando...",
          ),
        );

        // Simulamos un pequeño delay técnico de "Handshake" con el servidor
        await Future.delayed(const Duration(seconds: 1));

        // Estado final: Conectado
        String tipoRed = "Red";
        if (result.contains(ConnectivityResult.wifi)) {
          tipoRed = "WiFi";
        } else if (result.contains(ConnectivityResult.mobile)) {
          tipoRed = "Datos";
        } else if (result.contains(ConnectivityResult.ethernet)) {
          tipoRed = "Ethernet";
        }

        emit(
          SyncState(
            status: SyncStatus.online,
            label: "Online ($tipoRed)",
            lastUpdated: "Ahora",
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel(); // Importante: dejar de escuchar al cerrar la app
    return super.close();
  }
}
