import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_railway_timetable/features/widget_config/domain/entity/widget_route.dart';

void main() {
  group('WidgetRoute.toJson', () {
    test('encodes TR route correctly', () {
      const route = WidgetRoute(
        system: WidgetRailwaySystem.tr,
        fromId: '1000',
        fromName: '臺北',
        toId: '4400',
        toName: '高雄',
      );
      final json = jsonDecode(route.toJson()) as Map<String, dynamic>;
      expect(json['system'], 'TR');
      expect(json['fromId'], '1000');
      expect(json['fromName'], '臺北');
      expect(json['toId'], '4400');
      expect(json['toName'], '高雄');
    });

    test('encodes HSR route correctly', () {
      const route = WidgetRoute(
        system: WidgetRailwaySystem.hsr,
        fromId: '1000',
        fromName: '台北',
        toId: '1070',
        toName: '左營',
      );
      final json = jsonDecode(route.toJson()) as Map<String, dynamic>;
      expect(json['system'], 'HSR');
      expect(json['toId'], '1070');
    });

    test('produces valid JSON string', () {
      const route = WidgetRoute(
        system: WidgetRailwaySystem.tr,
        fromId: '1000',
        fromName: '臺北',
        toId: '4400',
        toName: '高雄',
      );
      expect(() => jsonDecode(route.toJson()), returnsNormally);
    });

    test('system field matches iOS RailwaySystem rawValue', () {
      // iOS WidgetRoute decodes "TR" / "HSR" via RailwaySystem.init(rawValue:)
      final trJson = jsonDecode(const WidgetRoute(
        system: WidgetRailwaySystem.tr,
        fromId: '1000', fromName: '臺北',
        toId: '4400', toName: '高雄',
      ).toJson()) as Map<String, dynamic>;
      final hsrJson = jsonDecode(const WidgetRoute(
        system: WidgetRailwaySystem.hsr,
        fromId: '1000', fromName: '台北',
        toId: '1070', toName: '左營',
      ).toJson()) as Map<String, dynamic>;

      expect(trJson['system'], 'TR');
      expect(hsrJson['system'], 'HSR');
    });
  });
}