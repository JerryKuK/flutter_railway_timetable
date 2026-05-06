import 'package:flutter/services.dart';
import '../domain/repository/i_widget_station_repository.dart';
import 'database/widget_station_database.dart';
import 'repository/widget_station_repository_impl.dart';

class WidgetDataService {
  static const _channel = MethodChannel('com.jerry.railwaytimetable/app_group');

  static String? _appGroupDir;
  static IWidgetStationRepository? _stationRepository;

  static Future<void> init() async {
    try {
      _appGroupDir = await _channel.invokeMethod<String>('getAppGroupDir');
    } catch (_) {
      return;
    }
    if (_appGroupDir != null && _appGroupDir!.isNotEmpty) {
      final db = WidgetStationDatabase('$_appGroupDir/widget_stations.db');
      _stationRepository = WidgetStationRepositoryImpl(db);
      await _stationRepository!.initDefaultsIfNeeded();
    }
  }

  static IWidgetStationRepository? get stationRepository => _stationRepository;

  static Future<void> refreshWidget() async {
    try {
      await _channel.invokeMethod<void>('reloadWidget');
    } catch (_) {}
  }
}
