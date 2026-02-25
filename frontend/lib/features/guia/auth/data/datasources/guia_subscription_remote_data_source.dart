import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';
import 'package:frontend/features/guia/auth/domain/usecases/register_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/activate_subscription_guia_usecase.dart';

/// Mock datasource que simula las operaciones de registro y suscripción.
/// En producción esto se reemplazaría con llamadas reales a Stripe / backend.
abstract class GuiaSubscriptionRemoteDataSource {
  Future<GuiaUserModel> register(RegisterGuiaParams params);
  Future<void> verifyEmailCode(String codigo);
  Future<void> activateSubscription(ActivateSubscriptionGuiaParams params);
}

class GuiaSubscriptionRemoteDataSourceImpl
    implements GuiaSubscriptionRemoteDataSource {
  // Código válido hardcodeado para simulación
  static const String _codigoValido = '123456';

  @override
  Future<GuiaUserModel> register(RegisterGuiaParams params) async {
    // Simula latencia de red
    await Future.delayed(const Duration(milliseconds: 1200));

    return GuiaUserModel(
      id: 'guia_${DateTime.now().millisecondsSinceEpoch}',
      email: params.correo,
      name: '${params.nombre} ${params.apellido}',
      phone: params.telefono,
      emergencyContact: params.contactoEmergencia,
      permissionLevel: 1,
    );
  }

  @override
  Future<void> verifyEmailCode(String codigo) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (codigo.trim() != _codigoValido) {
      throw Exception('Código incorrecto. Por favor verifica tu correo.');
    }
  }

  @override
  Future<void> activateSubscription(
    ActivateSubscriptionGuiaParams params,
  ) async {
    // Simula el procesamiento bancario (2 segundos de realismo)
    await Future.delayed(const Duration(seconds: 2));
    // En producción: llamar a Stripe API con los datos
  }
}
