import 'package:go_router/go_router.dart';
import 'enrutador_app_agencia.dart';
import 'routes_agencia.dart';

class AppRouterAgencia {
  static final GoRouter router = EnrutadorAppAgencia.createRouter(
    RoutesAgencia.dashboard,
  );
}
