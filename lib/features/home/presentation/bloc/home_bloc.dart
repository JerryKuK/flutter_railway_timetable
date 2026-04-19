import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/railway_type.dart';
import '../../../../features/timetable/domain/entity/station.dart';
import '../../../../features/timetable/domain/repository/timetable_repository.dart';
import '../../domain/entity/recent_search.dart';
import '../../domain/repository/recent_search_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

// THSR default stations
const _hsrDefaultDep = '南港';
const _hsrDefaultDepId = '0990';
const _hsrDefaultArr = '左營';
const _hsrDefaultArrId = '9900';

// TRA default stations
const _traDefaultDep = '台北';
const _traDefaultDepId = '1000';
const _traDefaultArr = '高雄';
const _traDefaultArrId = '3300';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final RecentSearchRepository _recentSearchRepository;
  final TimetableRepository _traRepository;
  final TimetableRepository _hsrRepository;

  HomeBloc(
    this._recentSearchRepository,
    this._traRepository,
    this._hsrRepository, {
    required String initialDate,
    required String initialTime,
    RailwayType initialRailwayType = RailwayType.tra,
  }) : super(HomeState(
          date: initialDate,
          time: initialTime,
          railwayType: initialRailwayType,
          departureStation: initialRailwayType == RailwayType.hsr
              ? _hsrDefaultDep
              : _traDefaultDep,
          departureStationId: initialRailwayType == RailwayType.hsr
              ? _hsrDefaultDepId
              : _traDefaultDepId,
          arrivalStation: initialRailwayType == RailwayType.hsr
              ? _hsrDefaultArr
              : _traDefaultArr,
          arrivalStationId: initialRailwayType == RailwayType.hsr
              ? _hsrDefaultArrId
              : _traDefaultArrId,
        )) {
    on<SwitchRailwayType>(_onSwitchRailwayType);
    on<SwapStations>(_onSwapStations);
    on<UpdateDate>(_onUpdateDate);
    on<UpdateTime>(_onUpdateTime);
    on<Search>(_onSearch);
    on<ClearHistory>(_onClearHistory);
    on<SelectRecentSearch>(_onSelectRecentSearch);
    on<LoadRecentSearches>(_onLoadRecentSearches);
    on<LoadStations>(_onLoadStations);
    on<SelectDepartureStation>(_onSelectDepartureStation);
    on<SelectArrivalStation>(_onSelectArrivalStation);

    add(const HomeEvent.loadRecentSearches());
    add(const HomeEvent.loadStations());
  }

  void _onSwitchRailwayType(
      SwitchRailwayType event, Emitter<HomeState> emit) {
    final isHsr = event.type == RailwayType.hsr;
    final defaultDep = isHsr ? _hsrDefaultDep : _traDefaultDep;
    final defaultArr = isHsr ? _hsrDefaultArr : _traDefaultArr;
    final defaultDepId = isHsr ? _hsrDefaultDepId : _traDefaultDepId;
    final defaultArrId = isHsr ? _hsrDefaultArrId : _traDefaultArrId;

    final stations = isHsr ? state.hsrStations : state.traStations;
    String depStation = defaultDep;
    String depId = defaultDepId;
    String arrStation = defaultArr;
    String arrId = defaultArrId;

    if (stations.isNotEmpty) {
      final dep = _findStation(stations, defaultDep);
      final arr = _findStation(stations, defaultArr);
      if (dep != null) { depStation = dep.stationName; depId = dep.stationId; }
      if (arr != null) { arrStation = arr.stationName; arrId = arr.stationId; }
    }

    emit(state.copyWith(
      railwayType: event.type,
      departureStation: depStation,
      departureStationId: depId,
      arrivalStation: arrStation,
      arrivalStationId: arrId,
      navigateToTimetable: false,
    ));
  }

  void _onSwapStations(SwapStations event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      departureStation: state.arrivalStation,
      departureStationId: state.arrivalStationId,
      arrivalStation: state.departureStation,
      arrivalStationId: state.departureStationId,
    ));
  }

  void _onUpdateDate(UpdateDate event, Emitter<HomeState> emit) {
    emit(state.copyWith(date: event.date));
  }

  void _onUpdateTime(UpdateTime event, Emitter<HomeState> emit) {
    emit(state.copyWith(time: event.time));
  }

  Future<void> _onSearch(Search event, Emitter<HomeState> emit) async {
    final search = RecentSearch(
      departureStation: state.departureStation,
      arrivalStation: state.arrivalStation,
      departureStationId: state.departureStationId,
      arrivalStationId: state.arrivalStationId,
      railwayType: state.railwayType.name,
    );
    await _recentSearchRepository.saveSearch(search);
    final updated = await _recentSearchRepository.getRecentSearches();
    emit(state.copyWith(recentSearches: updated, navigateToTimetable: true));
  }

  Future<void> _onClearHistory(
    ClearHistory event,
    Emitter<HomeState> emit,
  ) async {
    await _recentSearchRepository.clearAll();
    emit(state.copyWith(recentSearches: []));
  }

  void _onSelectRecentSearch(
    SelectRecentSearch event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(
      departureStation: event.search.departureStation,
      departureStationId: event.search.departureStationId,
      arrivalStation: event.search.arrivalStation,
      arrivalStationId: event.search.arrivalStationId,
    ));
  }

  Future<void> _onLoadRecentSearches(
    LoadRecentSearches event,
    Emitter<HomeState> emit,
  ) async {
    final searches = await _recentSearchRepository.getRecentSearches();
    emit(state.copyWith(recentSearches: searches));
  }

  Future<void> _onLoadStations(
    LoadStations event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingStations: true, stationsError: null));
    try {
      final results = await Future.wait([
        _traRepository.getStations(),
        _hsrRepository.getStations(),
      ]);
      final traStations = results[0];
      final hsrStations = results[1];

      // 以站名反查 API 實際的 StationID，確保 picker 高亮正確站點
      final isHsr = state.railwayType == RailwayType.hsr;
      final list = isHsr ? hsrStations : traStations;
      final depStation = _findStation(list, state.departureStation);
      final arrStation = _findStation(list, state.arrivalStation);

      emit(state.copyWith(
        traStations: traStations,
        hsrStations: hsrStations,
        isLoadingStations: false,
        departureStation: depStation?.stationName ?? state.departureStation,
        departureStationId: depStation?.stationId ?? state.departureStationId,
        arrivalStation: arrStation?.stationName ?? state.arrivalStation,
        arrivalStationId: arrStation?.stationId ?? state.arrivalStationId,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingStations: false,
        stationsError: e.toString(),
      ));
    }
  }

  /// 依站名查找站點，正規化 臺/台 差異（TDX API 用臺，介面顯示用台）。
  Station? _findStation(List<Station> stations, String name) {
    if (stations.isEmpty || name.isEmpty) return null;
    String n(String s) => s.replaceAll('臺', '台');
    final normalized = n(name);
    final exact = stations.where((s) => n(s.stationName) == normalized).firstOrNull;
    if (exact != null) return exact;
    return stations
        .where((s) => n(s.stationName).contains(normalized) || normalized.contains(n(s.stationName)))
        .firstOrNull;
  }

  void _onSelectDepartureStation(
    SelectDepartureStation event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(
      departureStation: event.station.stationName,
      departureStationId: event.station.stationId,
    ));
  }

  void _onSelectArrivalStation(
    SelectArrivalStation event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(
      arrivalStation: event.station.stationName,
      arrivalStationId: event.station.stationId,
    ));
  }
}
