import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Domain agnostic enough?
import '../../core/error/failures.dart';
// Importamos las entidades que acabamos de crear:
import '../entities/dashboard_data.dart';
import '../entities/viaje.dart';
import '../entities/guia.dart';
import '../entities/turista.dart';
import '../entities/log_auditoria.dart';

abstract class AgenciaRepository {
  // Dashboard
  Future<Either<Failure, DashboardData>> getDashboardData();

  // Métodos Tipados (Ya no usamos 'dynamic')
  Future<Either<Failure, List<Viaje>>> getListaViajes();
  Future<Either<Failure, Viaje>> getDetalleViaje(String id);
  Future<Either<Failure, List<Guia>>> getListaGuias();
  Future<Either<Failure, List<LogAuditoria>>> getAuditLogs();

  // Nuevos métodos para gestión de viajes
  Future<Either<Failure, List<Turista>>> getTuristasPorViaje(String id);
  Future<Either<Failure, void>> cancelarViaje(String id);

  // Métodos para gestión de usuarios
  Future<Either<Failure, List<Turista>>> getListaClientes();

  // ✨ NUEVO: Contrato para Servicios Externos (sin depender de la implementación)
  Future<List<String>> buscarFotosDestino(String query);

  // ✨ NUEVO: Método para guardar el viaje
  Future<void> crearViaje(Viaje viaje);

  // ✨ NUEVO: Stream de Conectividad (Clean Architecture)
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}
