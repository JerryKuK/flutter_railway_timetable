import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String name,
    required String email,
    required int mileage,
    required int points,
    required int frequentRoutes,
  }) = _UserProfile;
}
