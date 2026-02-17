import 'dart:convert';

import 'package:frontend/features/turista/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> clearUser();
  Future<void> cacheOnboardingStatus();
  Future<bool> getOnboardingStatus();
}

const cachedUserKey = 'CACHED_USER';
const onboardingKey = 'SEEN_ONBOARDING';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) {
    return sharedPreferences.setString(
      cachedUserKey,
      json.encode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getLastUser() {
    final jsonString = sharedPreferences.getString(cachedUserKey);
    if (jsonString != null) {
      return Future.value(UserModel.fromJson(json.decode(jsonString)));
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<void> clearUser() {
    return sharedPreferences.remove(cachedUserKey);
  }

  @override
  Future<void> cacheOnboardingStatus() {
    return sharedPreferences.setBool(onboardingKey, true);
  }

  @override
  Future<bool> getOnboardingStatus() {
    return Future.value(sharedPreferences.getBool(onboardingKey) ?? false);
  }
}
