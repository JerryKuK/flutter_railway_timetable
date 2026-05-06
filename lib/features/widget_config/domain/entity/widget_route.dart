import 'dart:convert';

enum WidgetRailwaySystem { tr, hsr }

class WidgetRoute {
  final WidgetRailwaySystem system;
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;

  const WidgetRoute({
    required this.system,
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
  });

  String toJson() => jsonEncode({
        'system': system == WidgetRailwaySystem.tr ? 'TR' : 'HSR',
        'fromId': fromId,
        'fromName': fromName,
        'toId': toId,
        'toName': toName,
      });
}
