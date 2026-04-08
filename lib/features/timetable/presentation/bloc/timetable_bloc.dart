import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entity/train.dart';
import '../../domain/usecase/get_daily_timetable_use_case.dart';
import 'timetable_event.dart';
import 'timetable_state.dart';

@injectable
class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final GetDailyTimetableUseCase _useCase;

  String? _lastOrigin;
  String? _lastDestination;
  String? _lastDate;
  String _lastTime = '';

  TimetableBloc(this._useCase) : super(const TimetableState.initial()) {
    on<LoadTimetable>(_onLoad);
    on<RetryTimetable>(_onRetry);
  }

  Future<void> _onLoad(LoadTimetable event, Emitter<TimetableState> emit) async {
    _lastOrigin = event.origin;
    _lastDestination = event.destination;
    _lastDate = event.date;
    _lastTime = event.time;
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

      // 依選定時間過濾：只顯示出發時間 >= 選定時間的班次
      final filtered = _filterByTime(trains, _lastTime);

      // 依出發時間排序（ascending）
      filtered.sort((a, b) {
        final aMin = _toMinutes(a.departureTime) ?? 0;
        final bMin = _toMinutes(b.departureTime) ?? 0;
        return aMin.compareTo(bMin);
      });

      if (filtered.isEmpty) {
        emit(const TimetableState.empty());
      } else {
        emit(TimetableState.loaded(filtered));
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

  /// 只保留 `departureTime >= minTime` 的班次
  List<Train> _filterByTime(List<Train> trains, String minTime) {
    if (minTime.isEmpty) return trains;
    final minMinutes = _toMinutes(minTime);
    if (minMinutes == null) return trains;
    return trains
        .where((t) {
          final dep = _toMinutes(t.departureTime);
          return dep != null && dep >= minMinutes;
        })
        .toList();
  }

  int? _toMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }
}
