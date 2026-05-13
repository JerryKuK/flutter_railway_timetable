import '../repository/i_widget_station_repository.dart';

class UpdateWidgetStationsUseCase {
  final IWidgetStationRepository _repository;

  // TR has 10 default stations; HSR has all 12 of its stations.
  // HSR widget picker shows the full set so users can pick any HSR stop.
  static int maxStations(String system) => system == 'HSR' ? 12 : 10;

  UpdateWidgetStationsUseCase(this._repository);

  Future<void> execute({
    required String fromName,
    required String fromId,
    required String toName,
    required String toId,
    required String system,
  }) async {
    try {
      // HSR's 12 stations are always all shown in a fixed north-to-south order,
      // so recency reordering is a no-op (nothing trims) and would break the
      // user's geographic mental map. TR is the only system that re-orders.
      if (system != 'TR') return;

      if (!await _repository.tableExists()) return;
      final existing = await _repository.getStations(system);
      if (existing.length < maxStations(system)) return;
      await _repository.setFront(
        fromName: fromName, fromId: fromId,
        toName: toName, toId: toId,
        system: system,
      );
    } catch (_) {}
  }
}
