import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/timetable/domain/repository/timetable_repository.dart';
import '../../domain/entity/recent_search.dart';
import '../../domain/repository/recent_search_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final RecentSearchRepository _recentSearchRepository;
  final TimetableRepository _timetableRepository;

  HomeBloc(
    this._recentSearchRepository,
    this._timetableRepository, {
    required String initialDate,
    required String initialTime,
  }) : super(HomeState(date: initialDate, time: initialTime)) {
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
      final stations = await _timetableRepository.getStations();
      emit(state.copyWith(stations: stations, isLoadingStations: false));
    } catch (e) {
      emit(state.copyWith(
        isLoadingStations: false,
        stationsError: e.toString(),
      ));
    }
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
