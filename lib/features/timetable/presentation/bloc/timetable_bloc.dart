import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecase/get_daily_timetable_use_case.dart';
import 'timetable_event.dart';
import 'timetable_state.dart';

@injectable
class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final GetDailyTimetableUseCase _useCase;

  String? _lastOrigin;
  String? _lastDestination;
  String? _lastDate;

  TimetableBloc(this._useCase) : super(const TimetableState.initial()) {
    on<LoadTimetable>(_onLoad);
    on<RetryTimetable>(_onRetry);
  }

  Future<void> _onLoad(LoadTimetable event, Emitter<TimetableState> emit) async {
    _lastOrigin = event.origin;
    _lastDestination = event.destination;
    _lastDate = event.date;
    await _fetchTimetable(emit);
  }

  Future<void> _onRetry(
      RetryTimetable event, Emitter<TimetableState> emit) async {
    if (_lastOrigin != null) {
      await _fetchTimetable(emit);
    }
  }

  Future<void> _fetchTimetable(Emitter<TimetableState> emit) async {
    emit(const TimetableState.loading());
    try {
      final trains = await _useCase(
        origin: _lastOrigin!,
        destination: _lastDestination!,
        date: _lastDate!,
      );
      if (trains.isEmpty) {
        emit(const TimetableState.empty());
      } else {
        emit(TimetableState.loaded(trains));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        emit(const TimetableState.empty());
      } else {
        emit(TimetableState.error(e.message ?? '連線失敗'));
      }
    } catch (e) {
      emit(TimetableState.error(e.toString()));
    }
  }
}
