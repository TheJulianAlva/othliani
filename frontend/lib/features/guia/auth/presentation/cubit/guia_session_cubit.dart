import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';
import 'package:equatable/equatable.dart';

// --- Estados del Session Cubit ---
abstract class GuiaSessionState extends Equatable {
  const GuiaSessionState();

  @override
  List<Object?> get props => [];
}

class GuiaSessionInitial extends GuiaSessionState {}

class GuiaSessionLoading extends GuiaSessionState {}

class GuiaSessionAuthenticated extends GuiaSessionState {
  final GuiaUserModel user;

  const GuiaSessionAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class GuiaSessionUnauthenticated extends GuiaSessionState {}

class GuiaSessionError extends GuiaSessionState {
  final String message;

  const GuiaSessionError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Cubit Global ---
class GuiaSessionCubit extends Cubit<GuiaSessionState> {
  final SharedPreferences sharedPreferences;

  GuiaSessionCubit({required this.sharedPreferences})
    : super(GuiaSessionInitial());

  /// Carga el usuario cacheados de SharedPreferences
  Future<void> checkSession() async {
    emit(GuiaSessionLoading());
    try {
      final jsonStr = sharedPreferences.getString('CACHED_GUIA_USER');
      if (jsonStr != null) {
        final model = GuiaUserModel.fromJson(json.decode(jsonStr));
        emit(GuiaSessionAuthenticated(model));
      } else {
        emit(GuiaSessionUnauthenticated());
      }
    } catch (e) {
      emit(GuiaSessionError('Error al cargar sesión: $e'));
    }
  }

  /// Inicia sesión o actualiza el cache
  Future<void> loginUser(GuiaUserModel user) async {
    emit(GuiaSessionLoading());
    try {
      final jsonStr = json.encode(user.toJson());
      await sharedPreferences.setString('CACHED_GUIA_USER', jsonStr);
      await sharedPreferences.setBool('isLoggedInGuia', true);
      emit(GuiaSessionAuthenticated(user));
    } catch (e) {
      emit(GuiaSessionError('Error al guardar sesión: $e'));
    }
  }

  /// Limpia la sesión actual
  Future<void> logoutUser() async {
    emit(GuiaSessionLoading());
    try {
      await sharedPreferences.remove('CACHED_GUIA_USER');
      await sharedPreferences.setBool('isLoggedInGuia', false);
      emit(GuiaSessionUnauthenticated());
    } catch (e) {
      emit(GuiaSessionError('Error al cerrar sesión: $e'));
    }
  }
}
