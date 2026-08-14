import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/profile_update_result.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UploadProfileImageUseCase uploadProfileImageUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileCubit(
    this.getProfileUseCase,
    this.uploadProfileImageUseCase,
    this.updateProfileUseCase,
  ) : super(ProfileInitial());

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    final result = await getProfileUseCase.execute();
    result.fold(
      (message) => emit(ProfileError(message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<String?> uploadProfileImage(String filePath) async {
    final result = await uploadProfileImageUseCase.execute(filePath);
    return result.fold((_) => null, (url) => url);
  }

  /// Calls `PUT /profile/info` and, on success, merges the returned fields
  /// into the currently loaded profile so the UI reflects the change
  /// immediately without an extra `GET /profile` round trip.
  ///
  /// Fields the update response does not return (e.g. email_verified,
  /// phone_verified, session/order/wishlist data) are preserved from the
  /// previously loaded profile rather than being reset.
  Future<Either<String, ProfileEntity>> updateProfile(
    UpdateProfileParams params,
  ) async {
    final result = await updateProfileUseCase.execute(params);

    return result.fold(
      (message) => Left(message),
      (updated) {
        final mergedProfile = _mergeIntoProfile(updated);
        emit(ProfileLoaded(mergedProfile));
        return Right(mergedProfile);
      },
    );
  }

  ProfileEntity _mergeIntoProfile(ProfileUpdateResult updated) {
    final currentState = state;
    final previousProfile = currentState is ProfileLoaded ? currentState.profile : null;
    final previousUser = previousProfile?.user;

    final mergedUser = ProfileUserEntity(
      id: updated.id,
      profileImageUrl: updated.profileImageUrl ?? previousUser?.profileImageUrl,
      name: updated.fullName ?? previousUser?.name,
      username: updated.username,
      firstName: updated.firstName,
      lastName: updated.lastName,
      gender: updated.gender ?? previousUser?.gender,
      birthday: updated.birthday ?? previousUser?.birthday,
      email: updated.email,
      emailVerified: previousUser?.emailVerified ?? false,
      phone: updated.phone,
      phoneVerified: previousUser?.phoneVerified ?? false,
      countryCode: updated.countryCode,
      preferredLanguages: updated.preferredLanguages,
    );

    if (previousProfile == null) {
      // Defensive fallback: an update should never happen before the
      // profile has loaded once, but avoid crashing if it somehow does.
      return ProfileEntity(
        user: mergedUser,
        activeSessions: const [],
        canChangePassword: false,
        canChangeUsername: false,
        addressCount: 0,
        orderCount: 0,
        inProgressOrderCount: 0,
        wishlistCount: 0,
        orderHistory: const [],
        inProgressOrders: const [],
        wishlist: const [],
      );
    }

    return ProfileEntity(
      user: mergedUser,
      activeSessions: previousProfile.activeSessions,
      canChangePassword: previousProfile.canChangePassword,
      canChangeUsername: previousProfile.canChangeUsername,
      addressCount: previousProfile.addressCount,
      orderCount: previousProfile.orderCount,
      inProgressOrderCount: previousProfile.inProgressOrderCount,
      wishlistCount: previousProfile.wishlistCount,
      orderHistory: previousProfile.orderHistory,
      inProgressOrders: previousProfile.inProgressOrders,
      wishlist: previousProfile.wishlist,
    );
  }
}
