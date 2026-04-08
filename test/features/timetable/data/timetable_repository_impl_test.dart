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

    /// 建立 ODFare 回應：單筆 OD 票價清單
    List<TdxODFareItemDto> makeODFareResponse(
        List<TdxFareDto> fares) {
      return [
        TdxODFareItemDto(
          originStationId: origin,
          destinationStationId: destination,
          fares: fares,
        ),
      ];
    }

    test('returns list of Train entities on success', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => makeResponse(
                trainNo: '171',
                trainType: '自強3000',
                depTime: '08:15',
                arrTime: '11:57',
              ));
      when(mockApiService.getODFare(origin, destination))
          .thenAnswer((_) async => []);

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
      when(mockApiService.getODFare(origin, destination))
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

    test('fare 來自 ODFare API，依 TrainTypeID 對應票價', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => TdxTimetableResponseDto(
                trainTimetables: [
                  TdxTrainTimetableDto(
                    trainInfo: TdxTrainInfoDto(
                      trainNo: '171',
                      trainTypeName:
                          const MultilingualName(zhTw: '自強3000', en: ''),
                      trainTypeId: '3',
                    ),
                    stopTimes: [
                      TdxStopTimeDto(
                        stationId: origin,
                        departureTime: '08:15',
                        arrivalTime: '08:15',
                      ),
                      TdxStopTimeDto(
                        stationId: destination,
                        departureTime: '11:57',
                        arrivalTime: '11:57',
                      ),
                    ],
                  ),
                ],
              ));
      // 模擬真實 TDX 回應：含孩童票與折扣票（成自折），確認只取成人全票
      when(mockApiService.getODFare(origin, destination))
          .thenAnswer((_) async => makeODFareResponse([
                const TdxFareDto(ticketType: '成自', price: 843),
                const TdxFareDto(ticketType: '孩自', price: 422),
                const TdxFareDto(ticketType: '愛孩自', price: 422),
                const TdxFareDto(ticketType: '成自折', price: 422), // 折扣票，不應覆蓋全票
                const TdxFareDto(ticketType: '孩自折', price: 0),
                const TdxFareDto(ticketType: '成莒', price: 636),
              ]));

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result.first.fare, 843);
    });

    test('ODFare API 失敗時，班次仍正常回傳，fare 為 0', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => makeResponse(
                trainNo: '172',
                trainType: '自強3000',
                depTime: '09:00',
                arrTime: '12:00',
              ));
      when(mockApiService.getODFare(origin, destination))
          .thenThrow(Exception('ODFare network error'));

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result.length, 1);
      expect(result.first.fare, 0);
    });

    test('區間車與區間快 fare 同樣對應至 成普 票價', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => TdxTimetableResponseDto(
                trainTimetables: [
                  TdxTrainTimetableDto(
                    trainInfo: const TdxTrainInfoDto(
                      trainNo: '4001',
                      trainTypeName: MultilingualName(zhTw: '區間', en: ''),
                    ),
                    stopTimes: [
                      TdxStopTimeDto(
                          stationId: origin,
                          departureTime: '08:00',
                          arrivalTime: '08:00'),
                      TdxStopTimeDto(
                          stationId: destination,
                          departureTime: '08:30',
                          arrivalTime: '08:30'),
                    ],
                  ),
                ],
              ));
      when(mockApiService.getODFare(origin, destination))
          .thenAnswer((_) async => makeODFareResponse([
                const TdxFareDto(ticketType: '成自', price: 37),
                const TdxFareDto(ticketType: '成莒', price: 28),
                const TdxFareDto(ticketType: '成復', price: 24),
                const TdxFareDto(ticketType: '成普', price: 11),
              ]));

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result.first.fare, 11);
    });

    test('travelTime 由出發與到達時間計算', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async =>
              makeResponse(trainNo: '101', depTime: '08:00', arrTime: '10:30'));
      when(mockApiService.getODFare(origin, destination))
          .thenAnswer((_) async => []);

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
