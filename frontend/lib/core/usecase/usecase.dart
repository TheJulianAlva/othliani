import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';

// ignore: avoid_types_as_parameter_names
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
