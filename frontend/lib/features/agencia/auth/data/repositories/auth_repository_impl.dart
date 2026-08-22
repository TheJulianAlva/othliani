import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/network/dio_client.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) async {
    try {
      final response = await _dioClient.post(
        '/agencias/login',
        data: {
          'correo': email,
          'password': password,
        },
      );

      // El backend devuelve { mensaje, agencia: { id, nombre_comercial, correo, ... } }
      final agenciaData = response.data['agencia'] as Map<String, dynamic>;

      final user = AuthUser(
        id: agenciaData['id'] as String,
        email: agenciaData['correo'] as String,
        name: agenciaData['nombre_comercial'] as String,
        role: 'AGENCY_ADMIN',
      );

      return Right(user);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return Left(ServerFailure('Correo o contraseña incorrectos.'));
      }
      return Left(
        ServerFailure(e.message ?? 'Error de conexión con el servidor.'),
      );
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Sin estado de sesión en el servidor por ahora; limpiar datos locales es suficiente
    return const Right(null);
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    // Sin persistencia de sesión implementada aún
    return const Right(null);
  }
}
