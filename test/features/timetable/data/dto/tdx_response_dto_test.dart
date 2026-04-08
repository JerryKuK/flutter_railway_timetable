import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_railway_timetable/features/timetable/data/dto/tdx_response_dto.dart';

void main() {
  group('MultilingualName', () {
    test('fromJson 正確解析 Zh_tw 與 En 欄位', () {
      final result = MultilingualName.fromJson({'Zh_tw': '台北', 'En': 'Taipei'});
      expect(result.zhTw, '台北');
      expect(result.en, 'Taipei');
    });

    test('fromJson 缺少欄位時使用預設空字串', () {
      final result = MultilingualName.fromJson({});
      expect(result.zhTw, '');
      expect(result.en, '');
    });
  });

  group('TdxStationDto', () {
    test('fromJson 正確解析車站資訊', () {
      final result = TdxStationDto.fromJson({
        'StationID': '1020',
        'StationName': {'Zh_tw': '台北', 'En': 'Taipei'},
        'LocationCity': '臺北市',
      });
      expect(result.stationId, '1020');
      expect(result.stationName?.zhTw, '台北');
      expect(result.city, '臺北市');
    });

    test('fromJson 缺少 City 時 city 為 null', () {
      final result =
          TdxStationDto.fromJson({'StationID': '1020'});
      expect(result.city, isNull);
    });
  });

  group('TdxTimetableResponseDto (v3)', () {
    final sampleJson = {
      'UpdateTime': '2026-04-08T00:00:00+08:00',
      'Count': 1,
      'TrainTimetables': [
        {
          'TrainInfo': {
            'TrainNo': '0101',
            'TrainTypeName': {
              'Zh_tw': '自強(EMU3000)',
              'En': 'Tze-Chiang(EMU3000)',
            },
          },
          'StopTimes': [
            {
              'StationID': '1020',
              'DepartureTime': '06:00',
              'ArrivalTime': '06:00',
            },
            {
              'StationID': '3300',
              'DepartureTime': '09:00',
              'ArrivalTime': '09:00',
            },
          ],
        },
      ],
    };

    test('fromJson 正確解析外層包裝結構', () {
      final result = TdxTimetableResponseDto.fromJson(sampleJson);
      expect(result.trainTimetables.length, 1);
    });

    test('fromJson 正確解析 TrainInfo', () {
      final result = TdxTimetableResponseDto.fromJson(sampleJson);
      final timetable = result.trainTimetables.first;
      expect(timetable.trainInfo?.trainNo, '0101');
      expect(timetable.trainInfo?.trainTypeName?.zhTw, '自強(EMU3000)');
    });

    test('fromJson 正確解析 StopTimes — [0] 出發站、[last] 到達站', () {
      final result = TdxTimetableResponseDto.fromJson(sampleJson);
      final stops = result.trainTimetables.first.stopTimes;
      expect(stops.length, 2);
      expect(stops.first.stationId, '1020');
      expect(stops.first.departureTime, '06:00');
      expect(stops.last.stationId, '3300');
      expect(stops.last.arrivalTime, '09:00');
    });

    test('fromJson TrainTimetables 缺少時使用空陣列', () {
      final result = TdxTimetableResponseDto.fromJson({});
      expect(result.trainTimetables, isEmpty);
    });

    test('fromJson TrainInfo 缺少時為 null', () {
      final result = TdxTimetableResponseDto.fromJson({
        'TrainTimetables': [
          {'StopTimes': []},
        ],
      });
      expect(result.trainTimetables.first.trainInfo, isNull);
    });
  });
}
