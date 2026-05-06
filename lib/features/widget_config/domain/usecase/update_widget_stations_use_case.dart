import '../repository/i_widget_station_repository.dart';

class UpdateWidgetStationsUseCase {
  final IWidgetStationRepository _repository;
  static const int maxStations = 10;

  UpdateWidgetStationsUseCase(this._repository);

  Future<void> execute({
    required String fromName,
    required String fromId,
    required String toName,
    required String toId,
    required String system,
  }) async {
    try {
      if (!await _repository.tableExists()) return;
      final existing = await _repository.getStations(system);
      if (existing.length < maxStations) return;
      await _repository.setFront(
        fromName: fromName, fromId: fromId,
        toName: toName, toId: toId,
        system: system,
      );
    } catch (_) {}
  }
}
