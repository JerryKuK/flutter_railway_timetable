import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_railway_timetable/features/timetable/data/dto/tdx_thsr_response_dto.dart';

void main() {
  group('TdxThsrDailyTrainDto.fromJson', () {
    final sampleJson = {
      'TrainDate': '2026-05-07',
      'DailyTrainInfo': {
        'TrainNo': '0601',
        'TrainTypeName': {'Zh_tw': '高鐵', 'En': 'THSR'},
      },
      'OriginStopTime': {'DepartureTime': '06:00', 'ArrivalTime': '06:00'},
      'DestinationStopTime': {'DepartureTime': '08:36', 'ArrivalTime': '08:36'},
    };

    test('從 DailyTrainInfo 巢狀物件正確解析 TrainNo', () {
      final dto = TdxThsrDailyTrainDto.fromJson(sampleJson);
      expect(dto.dailyTrainInfo?.trainNo, '0601');
    });

    test('從 DailyTrainInfo 巢狀物件正確解析 TrainTypeName', () {
      final dto = TdxThsrDailyTrainDto.fromJson(sampleJson);
      expect(dto.dailyTrainInfo?.trainTypeName?.zhTw, '高鐵');
    });

    test('OriginStopTime 在頂層，仍可正確解析 DepartureTime', () {
      final dto = TdxThsrDailyTrainDto.fromJson(sampleJson);
      expect(dto.originStopTime?.departureTime, '06:00');
    });

    test('DestinationStopTime 在頂層，仍可正確解析 ArrivalTime', () {
      final dto = TdxThsrDailyTrainDto.fromJson(sampleJson);
      expect(dto.destinationStopTime?.arrivalTime, '08:36');
    });

    test('DailyTrainInfo 缺少時 dailyTrainInfo 為 null', () {
      final dto = TdxThsrDailyTrainDto.fromJson({});
      expect(dto.dailyTrainInfo, isNull);
    });
  });
}
