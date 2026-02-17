import 'package:frontend/features/turista/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<bool> verifyFolio(String folio);
  Future<void> requestPhoneCode(String phoneNumber);
  Future<bool> verifyPhoneCode(String phoneNumber, String code);
  Future<void> resendEmailVerification(String email);
}

class AuthMockDataSource implements AuthRemoteDataSource {
  @override
  Future<bool> verifyFolio(String folio) async {
    await Future.delayed(const Duration(seconds: 1));
    return folio.isNotEmpty && folio != 'invalid';
  }

  @override
  Future<void> requestPhoneCode(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<bool> verifyPhoneCode(String phoneNumber, String code) async {
    await Future.delayed(const Duration(seconds: 1));
    return code == '123456';
  }

  @override
  Future<void> resendEmailVerification(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'error@test.com') {
      throw Exception('User not found');
    }

    return const UserModel(
      id: '1',
      email: 'juanmorales@outlook.com',
      name: 'Juan Morales',
    );
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return UserModel(id: '2', email: email, name: name);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'error@test.com') {
      throw Exception('Email not found');
    }
  }
}
