import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entity/train.dart';

part 'timetable_state.freezed.dart';

@freezed
abstract class TimetableState with _$TimetableState {
  const factory TimetableState.initial() = TimetableInitial;
  const factory TimetableState.loading() = TimetableLoading;
  const factory TimetableState.loaded(List<Train> trains) = TimetableLoaded;
  const factory TimetableState.empty() = TimetableEmpty;
  const factory TimetableState.error(String message) = TimetableError;
}
