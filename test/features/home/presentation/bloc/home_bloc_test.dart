import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_railway_timetable/features/home/domain/entity/recent_search.dart';
import 'package:flutter_railway_timetable/features/home/domain/repository/recent_search_repository.dart';
import 'package:flutter_railway_timetable/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_railway_timetable/features/home/presentation/bloc/home_event.dart';
import 'package:flutter_railway_timetable/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/entity/station.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/repository/timetable_repository.dart';

@GenerateMocks([RecentSearchRepository, TimetableRepository])
import 'home_bloc_test.mocks.dart';

void main() {
  late MockRecentSearchRepository mockRepo;
  late MockTimetableRepository mockTimetableRepo;
  late HomeBloc homeBloc;

  final tDate = '2026/04/06';
  final tTime = '08:30';

  final tStations = [
    const Station(stationId: '1000', stationName: '台北', city: '臺北市'),
    const Station(stationId: '9000', stationName: '高雄', city: '高雄市'),
  ];

  setUp(() {
    mockRepo = MockRecentSearchRepository();
    mockTimetableRepo = MockTimetableRepository();
    when(mockRepo.getRecentSearches()).thenAnswer((_) async => []);
    when(mockTimetableRepo.getStations()).thenAnswer((_) async => tStations);
    homeBloc = HomeBloc(
      mockRepo,
      mockTimetableRepo,
      initialDate: tDate,
      initialTime: tTime,
    );
  });

  tearDown(() => homeBloc.close());

  group('HomeBloc', () {
    test('initial state has default stations', () {
      expect(homeBloc.state.departureStation, '台北');
      expect(homeBloc.state.arrivalStation, '高雄');
    });

    blocTest<HomeBloc, HomeState>(
      'SwapStations swaps departure and arrival',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const HomeEvent.swapStations()),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.departureStation, 'departure', '高雄')
            .having((s) => s.arrivalStation, 'arrival', '台北'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'ClearHistory clears recent searches',
      build: () => homeBloc,
      setUp: () {
        when(mockRepo.clearAll()).thenAnswer((_) async {});
        when(mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const HomeEvent.clearHistory()),
      verify: (_) => verify(mockRepo.clearAll()).called(1),
    );

    blocTest<HomeBloc, HomeState>(
      'SelectRecentSearch fills in departure and arrival stations',
      build: () => homeBloc,
      act: (bloc) => bloc.add(
        HomeEvent.selectRecentSearch(
          const RecentSearch(
            departureStation: '板橋車站',
            arrivalStation: '高雄車站',
            departureStationId: 'BNQ',
            arrivalStationId: 'KHH',
          ),
        ),
      ),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.departureStation, 'departure', '板橋車站')
            .having((s) => s.arrivalStation, 'arrival', '高雄車站'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'UpdateDate updates date in state',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const HomeEvent.updateDate('2026/05/01')),
      expect: () => [
        isA<HomeState>().having((s) => s.date, 'date', '2026/05/01'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'Search saves current stations to recent searches repository',
      build: () => homeBloc,
      setUp: () {
        when(mockRepo.saveSearch(any)).thenAnswer((_) async {});
        when(mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const HomeEvent.search()),
      verify: (_) => verify(mockRepo.saveSearch(any)).called(1),
    );

    blocTest<HomeBloc, HomeState>(
      'Search emits state with navigateToTimetable=true after save completes',
      build: () => homeBloc,
      setUp: () {
        when(mockRepo.saveSearch(any)).thenAnswer((_) async {});
        when(mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const HomeEvent.search()),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.navigateToTimetable,
          'navigateToTimetable',
          true,
        ),
      ],
    );

    test('LoadStations 成功時更新 stations 並將 isLoadingStations 設為 false', () async {
      when(mockTimetableRepo.getStations()).thenAnswer((_) async => tStations);
      final bloc = HomeBloc(
        mockRepo,
        mockTimetableRepo,
        initialDate: tDate,
        initialTime: tTime,
      );
      // 等待所有 pending 事件（loadRecentSearches + loadStations）完成
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      expect(bloc.state.stations.length, 2);
      expect(bloc.state.isLoadingStations, false);
      expect(bloc.state.stationsError, isNull);
      await bloc.close();
    });

    test('LoadStations 失敗時設定 stationsError', () async {
      when(mockTimetableRepo.getStations()).thenThrow(Exception('Network error'));
      final bloc = HomeBloc(
        mockRepo,
        mockTimetableRepo,
        initialDate: tDate,
        initialTime: tTime,
      );
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      expect(bloc.state.stationsError, isNotNull);
      expect(bloc.state.isLoadingStations, false);
      await bloc.close();
    });

    blocTest<HomeBloc, HomeState>(
      'SelectDepartureStation 更新出發站',
      build: () => homeBloc,
      act: (bloc) => bloc.add(
        HomeEvent.selectDepartureStation(
          const Station(stationId: '2000', stationName: '松山', city: '臺北市'),
        ),
      ),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.departureStation, 'departure', '松山')
            .having((s) => s.departureStationId, 'departureId', '2000'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'SelectArrivalStation 更新到達站',
      build: () => homeBloc,
      act: (bloc) => bloc.add(
        HomeEvent.selectArrivalStation(
          const Station(stationId: '3000', stationName: '板橋', city: '新北市'),
        ),
      ),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.arrivalStation, 'arrival', '板橋')
            .having((s) => s.arrivalStationId, 'arrivalId', '3000'),
      ],
    );
  });
}
