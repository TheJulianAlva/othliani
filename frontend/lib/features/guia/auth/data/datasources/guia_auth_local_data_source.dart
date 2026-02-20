import 'dart:convert';

import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class GuiaAuthLocalDataSource {
  Future<void> cacheGuiaUser(GuiaUserModel user);
  Future<GuiaUserModel?> getLastGuiaUser();
  Future<void> clearGuiaUser();
  Future<void> cacheOnboardingStatus();
  Future<bool> getOnboardingStatus();
}

const _cachedGuiaUserKey = 'CACHED_GUIA_USER';
const _onboardingGuiaKey = 'GUIA_ONBOARDING_DONE';

class GuiaAuthLocalDataSourceImpl implements GuiaAuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  GuiaAuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheGuiaUser(GuiaUserModel user) {
    return sharedPreferences.setString(
      _cachedGuiaUserKey,
      json.encode(user.toJson()),
    );
  }

  @override
  Future<GuiaUserModel?> getLastGuiaUser() {
    final jsonString = sharedPreferences.getString(_cachedGuiaUserKey);
    if (jsonString != null) {
      return Future.value(GuiaUserModel.fromJson(json.decode(jsonString)));
    }
    return Future.value(null);
  }

  @override
  Future<void> clearGuiaUser() {
    return sharedPreferences.remove(_cachedGuiaUserKey);
  }

  @override
  Future<void> cacheOnboardingStatus() {
    return sharedPreferences.setBool(_onboardingGuiaKey, true);
  }

  @override
  Future<bool> getOnboardingStatus() {
    return Future.value(sharedPreferences.getBool(_onboardingGuiaKey) ?? false);
  }
}
