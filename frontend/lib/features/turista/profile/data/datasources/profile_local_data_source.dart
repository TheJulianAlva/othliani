import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/turista/profile/data/models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> getProfile();
  Future<void> cacheProfile(UserProfileModel profile);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserProfileModel> getProfile() async {
    final name = sharedPreferences.getString('userName') ?? 'Turista Invitado';
    final email =
        sharedPreferences.getString('userEmail') ?? 'turista@example.com';
    final avatarUrl = sharedPreferences.getString(
      'userAvatar',
    ); // New key for future

    return UserProfileModel(name: name, email: email, avatarUrl: avatarUrl);
  }

  @override
  Future<void> cacheProfile(UserProfileModel profile) async {
    await sharedPreferences.setString('userName', profile.name);
    await sharedPreferences.setString('userEmail', profile.email);
    if (profile.avatarUrl != null) {
      await sharedPreferences.setString('userAvatar', profile.avatarUrl!);
    }
  }
}
