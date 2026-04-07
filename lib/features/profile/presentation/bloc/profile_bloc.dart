import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entity/user_profile.dart';
import 'profile_state.dart';

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc()
      : super(
          const ProfileState(
            profile: UserProfile(
              name: '王小明',
              email: 'xiaoming@email.com',
              mileage: 28,
              points: 1280,
              frequentRoutes: 5,
            ),
          ),
        );
}
