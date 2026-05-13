import Testing
import Foundation

// TDX v2 THSR DailyTimetable OD API nests TrainNo & TrainTypeName inside
// a `DailyTrainInfo` object. This test locks the decode shape so a future
// "simplification" cannot silently re-break HSR schedule fetching.
@Suite("TDXAPIClient — HSR schedule decode shape")
struct HSRDecodeTests {

    @Test("decodes nested DailyTrainInfo.TrainNo from real-shape HSR response")
    func decodes_nested_DailyTrainInfo() throws {
        let json = """
        [
          {
            "DailyTrainInfo": {
              "TrainNo": "617",
              "TrainTypeName": { "Zh_tw": "標準", "En": "Standard" }
            },
            "OriginStopTime":      { "DepartureTime": "09:06", "ArrivalTime": "09:06" },
            "DestinationStopTime": { "DepartureTime": "11:09", "ArrivalTime": "11:09" }
          }
        ]
        """.data(using: .utf8)!

        let items = try JSONDecoder().decode([TDXAPIClient.HSRDailyTrain].self, from: json)
        #expect(items.count == 1)
        #expect(items.first?.DailyTrainInfo?.TrainNo == "617")
        #expect(items.first?.DailyTrainInfo?.TrainTypeName?.Zh_tw == "標準")
        #expect(items.first?.OriginStopTime?.DepartureTime == "09:06")
        #expect(items.first?.DestinationStopTime?.ArrivalTime == "11:09")
    }

    @Test("empty array decodes without error (HSR 404 case)")
    func decodes_empty_array() throws {
        let json = "[]".data(using: .utf8)!
        let items = try JSONDecoder().decode([TDXAPIClient.HSRDailyTrain].self, from: json)
        #expect(items.isEmpty)
    }

    @Test("missing DailyTrainInfo is tolerated (nil-coalesced in mapping)")
    func tolerates_missing_DailyTrainInfo() throws {
        let json = """
        [
          {
            "OriginStopTime":      { "DepartureTime": "09:06", "ArrivalTime": "09:06" },
            "DestinationStopTime": { "DepartureTime": "11:09", "ArrivalTime": "11:09" }
          }
        ]
        """.data(using: .utf8)!

        let items = try JSONDecoder().decode([TDXAPIClient.HSRDailyTrain].self, from: json)
        #expect(items.count == 1)
        #expect(items.first?.DailyTrainInfo == nil)
    }
}
