import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_railway_timetable/features/timetable/data/datasource/tdx_tra_api_service.dart';
import 'package:flutter_railway_timetable/features/timetable/data/dto/tdx_response_dto.dart';
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
    const origin = '1020';
    const destination = '3300';
    const date = '2026-04-06';

    /// 建立 v3 OD 回應：StopTimes[0]=出發站，StopTimes[1]=到達站
    TdxTimetableResponseDto makeResponse({
      required String trainNo,
      String trainType = '',
      required String depTime,
      required String arrTime,
    }) {
      return TdxTimetableResponseDto(
        trainTimetables: [
          TdxTrainTimetableDto(
            trainInfo: TdxTrainInfoDto(
              trainNo: trainNo,
              trainTypeName: trainType.isEmpty
                  ? null
                  : MultilingualName(zhTw: trainType, en: ''),
            ),
            stopTimes: [
              TdxStopTimeDto(
                stationId: origin,
                departureTime: depTime,
                arrivalTime: depTime,
              ),
              TdxStopTimeDto(
                stationId: destination,
                departureTime: arrTime,
                arrivalTime: arrTime,
              ),
            ],
          ),
        ],
      );
    }

    test('returns list of Train entities on success', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => makeResponse(
                trainNo: '171',
                trainType: '自強3000',
                depTime: '08:15',
                arrTime: '11:57',
              ));

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result, isA<List<Train>>());
      expect(result.length, 1);
      expect(result.first.trainNo, '171');
      expect(result.first.trainTypeName, '自強3000');
      expect(result.first.departureTime, '08:15');
      expect(result.first.arrivalTime, '11:57');
    });

    test('returns empty list when TrainTimetables is empty', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async =>
              const TdxTimetableResponseDto(trainTimetables: []));

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

    test('fare 固定為 0（OD 時刻表 API 不含票價）', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async =>
              makeResponse(trainNo: '172', depTime: '09:00', arrTime: '12:00'));

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result.first.fare, 0);
    });

    test('travelTime 由出發與到達時間計算', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async =>
              makeResponse(trainNo: '101', depTime: '08:00', arrTime: '10:30'));

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result.first.travelTime, '2 時 30 分');
    });

    test('getStations fetches from API on first call', () async {
      when(mockApiService.getStations()).thenAnswer((_) async => [
            const TdxStationDto(
              stationId: '1020',
              stationName: MultilingualName(zhTw: '台北', en: 'Taipei'),
              city: '臺北市',
            ),
            const TdxStationDto(
              stationId: '3300',
              stationName: MultilingualName(zhTw: '高雄', en: 'Kaohsiung'),
              city: '高雄市',
            ),
          ]);

      final result = await repository.getStations();

      expect(result, isA<List<Station>>());
      expect(result.length, 2);
      expect(result.first.stationName, '台北');
      expect(result.first.city, '臺北市');
      verify(mockApiService.getStations()).called(1);
    });

    test('getStations returns cached result on second call without hitting API again',
        () async {
      when(mockApiService.getStations()).thenAnswer((_) async => [
            const TdxStationDto(
              stationId: '1020',
              stationName: MultilingualName(zhTw: '台北', en: 'Taipei'),
            ),
          ]);

      await repository.getStations();
      await repository.getStations();

      verify(mockApiService.getStations()).called(1);
    });
  });
}
