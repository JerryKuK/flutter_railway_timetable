import 'package:injectable/injectable.dart';
import '../entity/train.dart';
import '../repository/timetable_repository.dart';

@injectable
class GetDailyTimetableUseCase {
  final TimetableRepository _repository;

  GetDailyTimetableUseCase(this._repository);

  Future<List<Train>> call({
    required String origin,
    required String destination,
    required String date,
  }) {
    return _repository.getDailyTimetable(
      origin: origin,
      destination: destination,
      date: date,
    );
  }
}
