import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_railway_timetable/core/enums/railway_type.dart';
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
  late MockTimetableRepository mockTraRepo;
  late MockTimetableRepository mockHsrRepo;
  late HomeBloc homeBloc;

  final tDate = '2026/04/19';
  final tTime = '08:30';

  final tTraStations = [
    const Station(stationId: '1000', stationName: '台北', city: '臺北市'),
    const Station(stationId: '9000', stationName: '高雄', city: '高雄市'),
  ];
  final tHsrStations = [
    const Station(stationId: '1000', stationName: '台北'),
    const Station(stationId: '9900', stationName: '左營'),
  ];

  setUp(() {
    mockRepo = MockRecentSearchRepository();
    mockTraRepo = MockTimetableRepository();
    mockHsrRepo = MockTimetableRepository();
    when(mockRepo.getRecentSearches()).thenAnswer((_) async => []);
    when(mockRepo.getLastStationSelection(any)).thenAnswer((_) async => null);
    when(mockRepo.saveLastStationSelection(
      railwayType: anyNamed('railwayType'),
      departureStation: anyNamed('departureStation'),
      departureStationId: anyNamed('departureStationId'),
      arrivalStation: anyNamed('arrivalStation'),
      arrivalStationId: anyNamed('arrivalStationId'),
    )).thenAnswer((_) async {});
    when(mockTraRepo.getStations()).thenAnswer((_) async => tTraStations);
    when(mockHsrRepo.getStations()).thenAnswer((_) async => tHsrStations);
    homeBloc = HomeBloc(
      mockRepo,
      mockTraRepo,
      mockHsrRepo,
      initialDate: tDate,
      initialTime: tTime,
    );
  });

  tearDown(() => homeBloc.close());

  group('HomeBloc', () {
    test('initial state has default TRA stations', () {
      expect(homeBloc.state.departureStation, '臺北');
      expect(homeBloc.state.arrivalStation, '高雄');
      expect(homeBloc.state.railwayType, RailwayType.tra);
    });

    test('init loads last station selection from DB when available', () async {
      when(mockRepo.getLastStationSelection('tra')).thenAnswer((_) async => {
        'departureStation': '松山',
        'departureStationId': '1020',
        'arrivalStation': '板橋',
        'arrivalStationId': '2000',
      });
      final bloc = HomeBloc(
        mockRepo, mockTraRepo, mockHsrRepo,
        initialDate: tDate, initialTime: tTime,
      );
      await Future.delayed(Duration.zero);
      expect(bloc.state.departureStation, '松山');
      expect(bloc.state.departureStationId, '1020');
      expect(bloc.state.arrivalStation, '板橋');
      expect(bloc.state.arrivalStationId, '2000');
      await bloc.close();
    });

    test('init uses hardcoded defaults when DB has no last selection', () async {
      when(mockRepo.getLastStationSelection(any)).thenAnswer((_) async => null);
      final bloc = HomeBloc(
        mockRepo, mockTraRepo, mockHsrRepo,
        initialDate: tDate, initialTime: tTime,
      );
      await Future.delayed(Duration.zero);
      expect(bloc.state.departureStation, '台北');
      expect(bloc.state.arrivalStation, '高雄');
      await bloc.close();
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
      'SwapStations persists swapped selection to DB',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const HomeEvent.swapStations()),
      verify: (_) {
        verify(mockRepo.saveLastStationSelection(
          railwayType: 'tra',
          departureStation: anyNamed('departureStation'),
          departureStationId: anyNamed('departureStationId'),
          arrivalStation: anyNamed('arrivalStation'),
          arrivalStationId: anyNamed('arrivalStationId'),
        )).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'SwitchRailwayType saves current selection before switching',
      build: () => homeBloc,
      setUp: () {
        when(mockRepo.getLastStationSelection('hsr'))
            .thenAnswer((_) async => null);
      },
      act: (bloc) =>
          bloc.add(const HomeEvent.switchRailwayType(RailwayType.hsr)),
      verify: (_) {
        verify(mockRepo.saveLastStationSelection(
          railwayType: 'tra',
          departureStation: anyNamed('departureStation'),
          departureStationId: anyNamed('departureStationId'),
          arrivalStation: anyNamed('arrivalStation'),
          arrivalStationId: anyNamed('arrivalStationId'),
        )).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'SwitchRailwayType 切換至高鐵時更新 railwayType 並使用預設站點（無歷史）',
      build: () => homeBloc,
      setUp: () {
        when(mockRepo.getLastStationSelection('hsr'))
            .thenAnswer((_) async => null);
      },
      act: (bloc) =>
          bloc.add(const HomeEvent.switchRailwayType(RailwayType.hsr)),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.railwayType, 'railwayType', RailwayType.hsr)
            .having((s) => s.departureStation, 'departure', '南港')
            .having((s) => s.departureStationId, 'depId', '0990')
            .having((s) => s.arrivalStation, 'arrival', '左營')
            .having((s) => s.arrivalStationId, 'arrId', '9900'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'SwitchRailwayType 切換至高鐵時載入 DB 歷史站台',
      build: () => homeBloc,
      setUp: () {
        when(mockRepo.getLastStationSelection('hsr')).thenAnswer((_) async => {
          'departureStation': '台中',
          'departureStationId': '5000',
          'arrivalStation': '新竹',
          'arrivalStationId': '3500',
        });
      },
      act: (bloc) =>
          bloc.add(const HomeEvent.switchRailwayType(RailwayType.hsr)),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.railwayType, 'railwayType', RailwayType.hsr)
            .having((s) => s.departureStation, 'departure', '台中')
            .having((s) => s.arrivalStation, 'arrival', '新竹'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'SwitchRailwayType 切換回台鐵',
      build: () => homeBloc,
      setUp: () {
        when(mockRepo.getLastStationSelection('hsr'))
            .thenAnswer((_) async => null);
        when(mockRepo.getLastStationSelection('tra'))
            .thenAnswer((_) async => null);
      },
      act: (bloc) async {
        bloc.add(const HomeEvent.switchRailwayType(RailwayType.hsr));
        bloc.add(const HomeEvent.switchRailwayType(RailwayType.tra));
      },
      expect: () => [
        isA<HomeState>().having((s) => s.railwayType, 'r', RailwayType.hsr),
        isA<HomeState>()
            .having((s) => s.railwayType, 'railwayType', RailwayType.tra)
            .having((s) => s.departureStation, 'departure', '台北')
            .having((s) => s.arrivalStationId, 'arrId', '9000'),
      ],
    );

    test('LoadStations 初始化同時載入 TRA + THSR 車站', () async {
      final bloc = HomeBloc(
        mockRepo,
        mockTraRepo,
        mockHsrRepo,
        initialDate: tDate,
        initialTime: tTime,
      );
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      expect(bloc.state.traStations.length, 2);
      expect(bloc.state.hsrStations.length, 2);
      expect(bloc.state.isLoadingStations, false);
      await bloc.close();
    });

    test('LoadStations 失敗時設定 stationsError', () async {
      when(mockTraRepo.getStations()).thenThrow(Exception('Network error'));
      final bloc = HomeBloc(
        mockRepo,
        mockTraRepo,
        mockHsrRepo,
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
      'Search 高鐵模式時 navigateToTimetable=true 且儲存 railwayType=hsr',
      build: () => homeBloc,
      setUp: () {
        when(mockRepo.getLastStationSelection('hsr'))
            .thenAnswer((_) async => null);
        when(mockRepo.saveSearch(any)).thenAnswer((_) async {});
        when(mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) async {
        bloc.add(const HomeEvent.switchRailwayType(RailwayType.hsr));
        bloc.add(const HomeEvent.search());
      },
      expect: () => [
        isA<HomeState>().having((s) => s.railwayType, 'r', RailwayType.hsr),
        isA<HomeState>().having((s) => s.navigateToTimetable, 'nav', true),
      ],
      verify: (_) {
        final captured = verify(mockRepo.saveSearch(captureAny)).captured;
        final saved = captured.last as RecentSearch;
        expect(saved.railwayType, 'hsr');
      },
    );

    blocTest<HomeBloc, HomeState>(
      'ClearHistory 台鐵模式只清除台鐵紀錄',
      build: () => homeBloc,
      setUp: () {
        when(mockRepo.clearByRailwayType('tra')).thenAnswer((_) async {});
        when(mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) =>
          bloc.add(const HomeEvent.clearHistory(railwayType: 'tra')),
      verify: (_) {
        verify(mockRepo.clearByRailwayType('tra')).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'ClearHistory 高鐵模式只清除高鐵紀錄，台鐵紀錄不受影響',
      build: () => homeBloc,
      setUp: () {
        when(mockRepo.getLastStationSelection('hsr'))
            .thenAnswer((_) async => null);
        when(mockRepo.clearByRailwayType('hsr')).thenAnswer((_) async {});
        when(mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) async {
        bloc.add(const HomeEvent.switchRailwayType(RailwayType.hsr));
        bloc.add(const HomeEvent.clearHistory(railwayType: 'hsr'));
      },
      verify: (_) {
        verify(mockRepo.clearByRailwayType('hsr')).called(1);
        verifyNever(mockRepo.clearByRailwayType('tra'));
      },
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
      'SelectRecentSearch persists selection to DB',
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
      verify: (_) {
        verify(mockRepo.saveLastStationSelection(
          railwayType: anyNamed('railwayType'),
          departureStation: anyNamed('departureStation'),
          departureStationId: anyNamed('departureStationId'),
          arrivalStation: anyNamed('arrivalStation'),
          arrivalStationId: anyNamed('arrivalStationId'),
        )).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'SelectDepartureStation 更新出發站並儲存至 DB',
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
      verify: (_) {
        verify(mockRepo.saveLastStationSelection(
          railwayType: anyNamed('railwayType'),
          departureStation: anyNamed('departureStation'),
          departureStationId: anyNamed('departureStationId'),
          arrivalStation: anyNamed('arrivalStation'),
          arrivalStationId: anyNamed('arrivalStationId'),
        )).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'SelectArrivalStation 更新到達站並儲存至 DB',
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
      verify: (_) {
        verify(mockRepo.saveLastStationSelection(
          railwayType: anyNamed('railwayType'),
          departureStation: anyNamed('departureStation'),
          departureStationId: anyNamed('departureStationId'),
          arrivalStation: anyNamed('arrivalStation'),
          arrivalStationId: anyNamed('arrivalStationId'),
        )).called(1);
      },
    );
  });
}
