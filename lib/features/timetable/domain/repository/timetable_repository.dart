import '../entity/train.dart';
import '../entity/station.dart';

abstract class TimetableRepository {
  Future<List<Train>> getDailyTimetable({
    required String origin,
    required String destination,
    required String date,
  });

  Future<List<Station>> getStations();
}
