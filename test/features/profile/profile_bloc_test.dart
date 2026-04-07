import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_railway_timetable/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_railway_timetable/features/profile/presentation/bloc/profile_state.dart';

void main() {
  group('ProfileBloc', () {
    late ProfileBloc profileBloc;

    setUp(() => profileBloc = ProfileBloc());
    tearDown(() => profileBloc.close());

    test('initial state has correct fake user data', () {
      final profile = profileBloc.state.profile;
      expect(profile.name, '王小明');
      expect(profile.email, 'xiaoming@email.com');
      expect(profile.mileage, 28);
      expect(profile.points, 1280);
      expect(profile.frequentRoutes, 5);
    });

    test('emits ProfileState with correct type', () {
      expect(profileBloc.state, isA<ProfileState>());
    });
  });
}
