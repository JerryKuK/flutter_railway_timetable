import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_railway_timetable/features/timetable/data/datasource/tdx_tra_api_service.dart';
import 'package:flutter_railway_timetable/features/timetable/data/dto/train_timetable_dto.dart';
import 'package:flutter_railway_timetable/features/timetable/data/repository/timetable_repository_impl.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/entity/station.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/entity/train.dart';

@GenerateMocks([TdxTraApiService])
import 'timetable_repository_impl_test.mocks.dart';

void main() {
  late MockTdxTraApiService mockApiService;
  late TimetableRepositoryImpl repository;

  setUp(() {
    mockApiService = MockTdxTraApiService();
    repository = TimetableRepositoryImpl(mockApiService);
  });

  group('TimetableRepositoryImpl', () {
    const origin = 'TPE';
    const destination = 'KHH';
    const date = '2026-04-06';

    test('returns list of Train entities on success', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => [
                TrainTimetableDto(
                  trainNo: '171',
                  trainTypeName: '自強3000',
                  departureTime: '08:15',
                  arrivalTime: '11:57',
                  travelTime: '3h 42m',
                  fare: 843,
                ),
              ]);

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result, isA<List<Train>>());
      expect(result.length, 1);
      expect(result.first.trainNo, '171');
      expect(result.first.fare, 843);
    });

    test('returns empty list when API returns empty', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => []);

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result, isEmpty);
    });

    test('throws exception on API failure', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenThrow(Exception('Network error'));

      expect(
        () => repository.getDailyTimetable(
          origin: origin,
          destination: destination,
          date: date,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('getStations fetches from API on first call', () async {
      when(mockApiService.getStations()).thenAnswer((_) async => [
            StationDto(stationId: 'TPE', stationName: '台北車站'),
            StationDto(stationId: 'KHH', stationName: '高雄車站'),
          ]);

      final result = await repository.getStations();

      expect(result, isA<List<Station>>());
      expect(result.length, 2);
      expect(result.first.stationName, '台北車站');
      verify(mockApiService.getStations()).called(1);
    });

    test('getStations returns cached result on second call without hitting API again', () async {
      when(mockApiService.getStations()).thenAnswer((_) async => [
            StationDto(stationId: 'TPE', stationName: '台北車站'),
          ]);

      await repository.getStations();
      await repository.getStations();

      verify(mockApiService.getStations()).called(1);
    });
  });
}
