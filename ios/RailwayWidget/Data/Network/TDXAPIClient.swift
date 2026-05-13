import Foundation

enum TDXAPIError: Error {
    case invalidURL
    case httpError(Int)
}

struct TDXAPIClient {
    private static let base = "https://tdx.transportdata.tw"

    // MARK: - TRA
    // Flutter: GET /api/basic/v3/Rail/TRA/DailyTrainTimetable/OD/{origin}/to/{destination}/{trainDate}?$format=JSON
    // Response: { "TrainTimetables": [ { "TrainInfo": {...}, "StopTimes": [origin, dest] } ] }
    // StopTimes[0] = origin stop, StopTimes[last] = destination stop (OD endpoint)
    func fetchTRASchedule(from: String, to: String, date: String, token: String) async throws -> [TrainSchedule] {
        let path = "/api/basic/v3/Rail/TRA/DailyTrainTimetable/OD/\(from)/to/\(to)/\(date)"
        let data = try await get(path: path, token: token)

        struct MultiName: Decodable { let Zh_tw: String? }
        struct StopTime: Decodable {
            let StationID: String
            let DepartureTime: String
            let ArrivalTime: String
        }
        struct TrainInfoItem: Decodable {
            let TrainNo: String
            let TrainTypeName: MultiName?
        }
        struct TimetableItem: Decodable {
            let TrainInfo: TrainInfoItem?
            let StopTimes: [StopTime]
        }
        struct Response: Decodable {
            let TrainTimetables: [TimetableItem]
        }

        let response = try JSONDecoder().decode(Response.self, from: data)
        return response.TrainTimetables.compactMap { item in
            // OD endpoint: StopTimes[0] = origin, StopTimes[last] = destination
            guard let origin = item.StopTimes.first,
                  let dest = item.StopTimes.last,
                  item.StopTimes.count >= 2
            else { return nil }
            return TrainSchedule(
                departureTime: String(origin.DepartureTime.prefix(5)),
                arrivalTime: String(dest.ArrivalTime.prefix(5)),
                trainType: item.TrainInfo?.TrainTypeName?.Zh_tw ?? "",
                trainNumber: "#\(item.TrainInfo?.TrainNo ?? "")",
                fare: 0
            )
        }
    }

    // MARK: - HSR
    // Flutter: GET /api/basic/v2/Rail/THSR/DailyTimetable/OD/{origin}/to/{destination}/{trainDate}?$format=JSON
    // Response: DIRECT ARRAY (no wrapper object) — List<TdxThsrDailyTrainDto>
    // Note: TDX v2 THSR DailyTimetable OD API NESTS TrainNo & TrainTypeName inside a `DailyTrainInfo` object.
    //       OriginStopTime / DestinationStopTime remain top-level.
    func fetchHSRSchedule(from: String, to: String, date: String, token: String) async throws -> [TrainSchedule] {
        let path = "/api/basic/v2/Rail/THSR/DailyTimetable/OD/\(from)/to/\(to)/\(date)"
        let data = try await get(path: path, token: token)

        let items = try JSONDecoder().decode([HSRDailyTrain].self, from: data)
        return items.compactMap { item in
            guard let dep = item.OriginStopTime?.DepartureTime,
                  let arr = item.DestinationStopTime?.ArrivalTime,
                  !dep.isEmpty, !arr.isEmpty
            else { return nil }
            return TrainSchedule(
                departureTime: String(dep.prefix(5)),
                arrivalTime: String(arr.prefix(5)),
                trainType: item.DailyTrainInfo?.TrainTypeName?.Zh_tw ?? "標準",
                trainNumber: "#\(item.DailyTrainInfo?.TrainNo ?? "")",
                fare: 0
            )
        }
    }

    // HSR DailyTimetable OD response item (file-scoped so tests can reach it)
    struct HSRMultiName: Decodable { let Zh_tw: String? }
    struct HSRStopTime: Decodable {
        let DepartureTime: String
        let ArrivalTime: String
    }
    struct HSRTrainInfo: Decodable {
        let TrainNo: String
        let TrainTypeName: HSRMultiName?
    }
    struct HSRDailyTrain: Decodable {
        let DailyTrainInfo: HSRTrainInfo?
        let OriginStopTime: HSRStopTime?
        let DestinationStopTime: HSRStopTime?
    }

    // MARK: - Shared HTTP (adds $format=JSON like Flutter does)
    private func get(path: String, token: String) async throws -> Data {
        var components = URLComponents(string: Self.base + path)!
        components.queryItems = [URLQueryItem(name: "$format", value: "JSON")]
        guard let url = components.url else { throw TDXAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode ?? 0
        if code == 404 { return "[]".data(using: .utf8)! }  // HSR: 404 = no trains
        guard (200..<300).contains(code) else { throw TDXAPIError.httpError(code) }
        return data
    }
}
