import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_railway_timetable/features/home/domain/entity/recent_search.dart';
import 'package:flutter_railway_timetable/features/home/domain/repository/recent_search_repository.dart';
import 'package:flutter_railway_timetable/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_railway_timetable/features/home/presentation/bloc/home_event.dart';
import 'package:flutter_railway_timetable/features/home/presentation/bloc/home_state.dart';

@GenerateMocks([RecentSearchRepository])
import 'home_bloc_test.mocks.dart';

void main() {
  late MockRecentSearchRepository mockRepo;
  late HomeBloc homeBloc;

  final tDate = '2026/04/06';
  final tTime = '08:30';

  setUp(() {
    mockRepo = MockRecentSearchRepository();
    when(mockRepo.getRecentSearches()).thenAnswer((_) async => []);
    homeBloc = HomeBloc(mockRepo, initialDate: tDate, initialTime: tTime);
  });

  tearDown(() => homeBloc.close());

  group('HomeBloc', () {
    test('initial state has default stations', () {
      expect(homeBloc.state.departureStation, '台北車站');
      expect(homeBloc.state.arrivalStation, '高雄車站');
    });

    blocTest<HomeBloc, HomeState>(
      'SwapStations swaps departure and arrival',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const HomeEvent.swapStations()),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.departureStation, 'departure', '高雄車站')
            .having((s) => s.arrivalStation, 'arrival', '台北車站'),
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
  });
}
