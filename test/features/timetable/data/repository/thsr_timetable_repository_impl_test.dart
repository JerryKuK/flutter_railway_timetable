import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_railway_timetable/features/timetable/data/datasource/tdx_thsr_api_service.dart';
import 'package:flutter_railway_timetable/features/timetable/data/dto/tdx_thsr_response_dto.dart';
import 'package:flutter_railway_timetable/features/timetable/data/repository/thsr_timetable_repository_impl.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/entity/station.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/entity/train.dart';

@GenerateMocks([TdxThsrApiService])
import 'thsr_timetable_repository_impl_test.mocks.dart';

void main() {
  late MockTdxThsrApiService mockApiService;
  late ThsrTimetableRepositoryImpl repository;

  setUp(() {
    mockApiService = MockTdxThsrApiService();
    repository = ThsrTimetableRepositoryImpl(mockApiService);
  });

  const origin = '1000';
  const destination = '9900';
  const date = '2026-04-19';

  TdxThsrDailyTrainDto makeTrain({
    String trainNo = '101',
    String typeName = '高鐵',
    String depTime = '06:00',
    String arrTime = '08:36',
  }) =>
      TdxThsrDailyTrainDto(
        trainNo: trainNo,
        trainTypeName: TdxThsrMultilingualName(zhTw: typeName, en: ''),
        originStopTime: TdxThsrStopTimeDto(departureTime: depTime),
        destinationStopTime: TdxThsrStopTimeDto(arrivalTime: arrTime),
      );

  // 自由座成人票：TicketType=1, FareClass=1, CabinClass=3
  TdxThsrODFareItemDto makeFare(int unreservedPrice, {int? reservedPrice}) =>
      TdxThsrODFareItemDto(
        originStationId: origin,
        destinationStationId: destination,
        fares: [
          TdxThsrFareDto(
              ticketType: 1, fareClass: 1, cabinClass: 3, price: unreservedPrice),
          if (reservedPrice != null)
            TdxThsrFareDto(
                ticketType: 1, fareClass: 1, cabinClass: 1, price: reservedPrice),
        ],
      );

  group('ThsrTimetableRepositoryImpl.getDailyTimetable', () {
    test('成功情境：回傳正確 Train 欄位', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => [makeTrain()]);
      when(mockApiService.getODFare(origin, destination))
          .thenAnswer((_) async => [makeFare(320, reservedPrice: 330)]);

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result, isA<List<Train>>());
      expect(result.length, 1);
      expect(result.first.trainNo, '101');
      expect(result.first.departureTime, '06:00');
      expect(result.first.arrivalTime, '08:36');
      expect(result.first.travelTime, '2 時 36 分');
      expect(result.first.fare, 320);
    });

    test('票價 API 失敗時降級：班次仍回傳，fare = 0', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => [makeTrain(trainNo: '103')]);
      when(mockApiService.getODFare(origin, destination))
          .thenThrow(Exception('ODFare error'));

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result.length, 1);
      expect(result.first.trainNo, '103');
      expect(result.first.fare, 0);
    });

    test('API 回傳 404：回傳空列表不拋出例外', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => []);
      when(mockApiService.getODFare(origin, destination))
          .thenAnswer((_) async => []);

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result, isEmpty);
    });

    test('只取 TicketType=1, FareClass=1, CabinClass=3 的自由座成人票', () async {
      when(mockApiService.getDailyTimetable(origin, destination, date))
          .thenAnswer((_) async => [makeTrain()]);
      when(mockApiService.getODFare(origin, destination))
          .thenAnswer((_) async => [
                TdxThsrODFareItemDto(
                  originStationId: origin,
                  destinationStationId: destination,
                  fares: [
                    const TdxThsrFareDto(
                        ticketType: 1, fareClass: 1, cabinClass: 1, price: 330),
                    const TdxThsrFareDto(
                        ticketType: 1, fareClass: 1, cabinClass: 2, price: 700),
                    const TdxThsrFareDto(
                        ticketType: 1, fareClass: 1, cabinClass: 3, price: 320),
                    const TdxThsrFareDto(
                        ticketType: 8, fareClass: 1, cabinClass: 1, price: 310),
                  ],
                ),
              ]);

      final result = await repository.getDailyTimetable(
        origin: origin,
        destination: destination,
        date: date,
      );

      expect(result.first.fare, 320);
    });
  });

  group('ThsrTimetableRepositoryImpl.getStations', () {
    test('成功時回傳 Station 列表', () async {
      when(mockApiService.getStations()).thenAnswer((_) async => [
            const TdxThsrStationDto(
              stationId: '1000',
              stationName: TdxThsrMultilingualName(zhTw: '台北', en: 'Taipei'),
            ),
            const TdxThsrStationDto(
              stationId: '9900',
              stationName: TdxThsrMultilingualName(zhTw: '左營', en: 'Zuoying'),
            ),
          ]);

      final result = await repository.getStations();

      expect(result, isA<List<Station>>());
      expect(result.length, 2);
      expect(result.first.stationId, '1000');
      expect(result.first.stationName, '台北');
      verify(mockApiService.getStations()).called(1);
    });

    test('快取命中：第二次呼叫不重複打 API', () async {
      when(mockApiService.getStations()).thenAnswer((_) async => [
            const TdxThsrStationDto(stationId: '1000'),
          ]);

      await repository.getStations();
      await repository.getStations();

      verify(mockApiService.getStations()).called(1);
    });
  });
}
