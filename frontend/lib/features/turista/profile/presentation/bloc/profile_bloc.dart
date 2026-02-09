import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/profile/domain/entities/user_profile.dart';
import 'package:frontend/features/turista/profile/domain/usecases/get_profile_usecase.dart';
import 'package:frontend/features/turista/profile/domain/usecases/update_profile_usecase.dart';
import 'package:frontend/features/turista/profile/presentation/bloc/profile_event.dart';
import 'package:frontend/features/turista/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await getProfileUseCase(NoParams());
    result.fold(
      (failure) => emit(const ProfileError('Error loading profile')),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      final updatedProfile = UserProfile(
        name: event.name,
        email: event.email,
        avatarUrl: currentState.profile.avatarUrl,
      );

      // Optimistic update
      emit(
        ProfileLoaded(updatedProfile),
      ); // We could show loading, but optimistic is better for UX here

      final result = await updateProfileUseCase(updatedProfile);
      result.fold((failure) {
        emit(const ProfileError('Error updating profile'));
        // Revert if needed, but for now simple error state is ok or revert to previous
        emit(ProfileLoaded(currentState.profile));
      }, (profile) => emit(ProfileLoaded(profile)));
    }
  }
}
