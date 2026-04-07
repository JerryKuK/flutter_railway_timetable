import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/repository/timetable_repository.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/usecase/get_daily_timetable_use_case.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/entity/train.dart';

@GenerateMocks([TimetableRepository])
import 'get_daily_timetable_use_case_test.mocks.dart';

void main() {
  late MockTimetableRepository mockRepository;
  late GetDailyTimetableUseCase useCase;

  setUp(() {
    mockRepository = MockTimetableRepository();
    useCase = GetDailyTimetableUseCase(mockRepository);
  });

  group('GetDailyTimetableUseCase', () {
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

    test('returns trains from repository', () async {
      when(mockRepository.getDailyTimetable(
        origin: 'TPE',
        destination: 'KHH',
        date: '2026-04-06',
      )).thenAnswer((_) async => tTrains);

      final result = await useCase(
        origin: 'TPE',
        destination: 'KHH',
        date: '2026-04-06',
      );

      expect(result, tTrains);
    });

    test('propagates exception from repository', () async {
      when(mockRepository.getDailyTimetable(
        origin: anyNamed('origin'),
        destination: anyNamed('destination'),
        date: anyNamed('date'),
      )).thenThrow(Exception('error'));

      expect(
        () => useCase(origin: 'TPE', destination: 'KHH', date: '2026-04-06'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
