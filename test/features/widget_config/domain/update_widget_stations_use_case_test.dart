import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_railway_timetable/features/widget_config/domain/entity/widget_station.dart';
import 'package:flutter_railway_timetable/features/widget_config/domain/repository/i_widget_station_repository.dart';
import 'package:flutter_railway_timetable/features/widget_config/domain/usecase/update_widget_stations_use_case.dart';

@GenerateMocks([IWidgetStationRepository])
import 'update_widget_stations_use_case_test.mocks.dart';

void main() {
  late MockIWidgetStationRepository mockRepo;
  late UpdateWidgetStationsUseCase useCase;

  const tSystem = 'TR';

  setUp(() {
    mockRepo = MockIWidgetStationRepository();
    useCase = UpdateWidgetStationsUseCase(mockRepo);
  });

  group('execute', () {
    test('does nothing when tableExists returns false', () async {
      when(mockRepo.tableExists()).thenAnswer((_) async => false);

      await useCase.execute(
        fromName: '台北', fromId: '1000',
        toName: '高雄', toId: '4400',
        system: tSystem,
      );

      verifyNever(mockRepo.getStations(any));
      verifyNever(mockRepo.setFront(
        fromName: anyNamed('fromName'), fromId: anyNamed('fromId'),
        toName: anyNamed('toName'), toId: anyNamed('toId'),
        system: anyNamed('system'),
      ));
    });

    test('does nothing when station count is below maxStations (10)', () async {
      when(mockRepo.tableExists()).thenAnswer((_) async => true);
      when(mockRepo.getStations(tSystem)).thenAnswer((_) async =>
          List.generate(5, (i) => WidgetStation(name: '站$i', stationId: '$i', system: tSystem, sortOrder: i)));

      await useCase.execute(
        fromName: '台北', fromId: '1000',
        toName: '高雄', toId: '4400',
        system: tSystem,
      );

      verifyNever(mockRepo.setFront(
        fromName: anyNamed('fromName'), fromId: anyNamed('fromId'),
        toName: anyNamed('toName'), toId: anyNamed('toId'),
        system: anyNamed('system'),
      ));
    });

    test('calls setFront when station count equals maxStations (10)', () async {
      when(mockRepo.tableExists()).thenAnswer((_) async => true);
      when(mockRepo.getStations(tSystem)).thenAnswer((_) async =>
          List.generate(10, (i) => WidgetStation(name: '站$i', stationId: '$i', system: tSystem, sortOrder: i)));
      when(mockRepo.setFront(
        fromName: anyNamed('fromName'), fromId: anyNamed('fromId'),
        toName: anyNamed('toName'), toId: anyNamed('toId'),
        system: anyNamed('system'),
      )).thenAnswer((_) async {});

      await useCase.execute(
        fromName: '台北', fromId: '1000',
        toName: '高雄', toId: '4400',
        system: tSystem,
      );

      verify(mockRepo.setFront(
        fromName: '台北', fromId: '1000',
        toName: '高雄', toId: '4400',
        system: tSystem,
      )).called(1);
    });

    test('short-circuits for HSR — never calls setFront (HSR picker shows all 12 stations in fixed N→S order)', () async {
      const hsrSystem = 'HSR';

      await useCase.execute(
        fromName: '臺北', fromId: '1000',
        toName: '左營', toId: '1070',
        system: hsrSystem,
      );

      // HSR early-returns at the top of execute() before any repository call,
      // because HSR has all 12 stations seeded and picker order is geographic
      // (not recency-based). setFront would be a no-op churn at best.
      verifyNever(mockRepo.tableExists());
      verifyNever(mockRepo.getStations(any));
      verifyNever(mockRepo.setFront(
        fromName: anyNamed('fromName'), fromId: anyNamed('fromId'),
        toName: anyNamed('toName'), toId: anyNamed('toId'),
        system: anyNamed('system'),
      ));
    });

    test('swallows exceptions silently', () async {
      when(mockRepo.tableExists()).thenThrow(Exception('DB error'));

      // Should not throw
      await expectLater(
        useCase.execute(
          fromName: '台北', fromId: '1000',
          toName: '高雄', toId: '4400',
          system: tSystem,
        ),
        completes,
      );
    });
  });
}