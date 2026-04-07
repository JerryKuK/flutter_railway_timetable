import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/entity/train.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/usecase/get_daily_timetable_use_case.dart';
import 'package:flutter_railway_timetable/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:flutter_railway_timetable/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:flutter_railway_timetable/features/timetable/presentation/bloc/timetable_state.dart';

@GenerateMocks([GetDailyTimetableUseCase])
import 'timetable_bloc_test.mocks.dart';

void main() {
  late MockGetDailyTimetableUseCase mockUseCase;
  late TimetableBloc timetableBloc;

  final tTrains = [
    Train(
      trainNo: '171',
      trainTypeName: '自強3000',
      departureTime: '08:15',
      arrivalTime: '11:57',
      travelTime: '3h 42m',
      fare: 843,
    ),
  ];

  setUp(() {
    mockUseCase = MockGetDailyTimetableUseCase();
    timetableBloc = TimetableBloc(mockUseCase);
  });

  tearDown(() => timetableBloc.close());

  group('TimetableBloc', () {
    blocTest<TimetableBloc, TimetableState>(
      'emits loading then loaded when trains are found',
      build: () => timetableBloc,
      setUp: () {
        when(mockUseCase(
          origin: 'TPE',
          destination: 'KHH',
          date: '2026-04-06',
        )).thenAnswer((_) async => tTrains);
      },
      act: (bloc) => bloc.add(const TimetableEvent.load(
        origin: 'TPE',
        destination: 'KHH',
        date: '2026-04-06',
      )),
      expect: () => [
        const TimetableState.loading(),
        TimetableState.loaded(tTrains),
      ],
    );

    blocTest<TimetableBloc, TimetableState>(
      'emits loading then empty when no trains found',
      build: () => timetableBloc,
      setUp: () {
        when(mockUseCase(
          origin: anyNamed('origin'),
          destination: anyNamed('destination'),
          date: anyNamed('date'),
        )).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const TimetableEvent.load(
        origin: 'TPE',
        destination: 'KHH',
        date: '2026-04-06',
      )),
      expect: () => [
        const TimetableState.loading(),
        const TimetableState.empty(),
      ],
    );

    blocTest<TimetableBloc, TimetableState>(
      'emits loading then error when use case throws',
      build: () => timetableBloc,
      setUp: () {
        when(mockUseCase(
          origin: anyNamed('origin'),
          destination: anyNamed('destination'),
          date: anyNamed('date'),
        )).thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const TimetableEvent.load(
        origin: 'TPE',
        destination: 'KHH',
        date: '2026-04-06',
      )),
      expect: () => [
        const TimetableState.loading(),
        isA<TimetableError>(),
      ],
    );
  });
}
