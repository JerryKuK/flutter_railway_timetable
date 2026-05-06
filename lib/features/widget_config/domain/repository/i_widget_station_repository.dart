import '../entity/widget_station.dart';

abstract interface class IWidgetStationRepository {
  Future<bool> tableExists();
  Future<List<WidgetStation>> getStations(String system);
  Future<void> setFront({
    required String fromName,
    required String fromId,
    required String toName,
    required String toId,
    required String system,
  });
  Future<void> initDefaultsIfNeeded();
}
