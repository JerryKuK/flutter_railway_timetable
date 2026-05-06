class WidgetStation {
  final String name;
  final String stationId;
  final String system;    // 'TR' or 'HSR'
  final int sortOrder;

  const WidgetStation({
    required this.name,
    required this.stationId,
    required this.system,
    required this.sortOrder,
  });
}
