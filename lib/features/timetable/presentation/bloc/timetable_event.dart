import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable_event.freezed.dart';

@freezed
abstract class TimetableEvent with _$TimetableEvent {
  const factory TimetableEvent.load({
    required String origin,
    required String destination,
    required String date,
    @Default('') String time,
  }) = LoadTimetable;
  const factory TimetableEvent.retry() = RetryTimetable;
}
