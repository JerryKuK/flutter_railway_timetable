import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entity/user_profile.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({required UserProfile profile}) = _ProfileState;
}
