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
    // Fields: TrainNo, TrainTypeName.Zh_tw, OriginStopTime.DepartureTime, DestinationStopTime.ArrivalTime
    func fetchHSRSchedule(from: String, to: String, date: String, token: String) async throws -> [TrainSchedule] {
        let path = "/api/basic/v2/Rail/THSR/DailyTimetable/OD/\(from)/to/\(to)/\(date)"
        let data = try await get(path: path, token: token)

        struct MultiName: Decodable { let Zh_tw: String? }
        struct StopTime: Decodable {
            let DepartureTime: String
            let ArrivalTime: String
        }
        struct Item: Decodable {
            let TrainNo: String
            let TrainTypeName: MultiName?
            let OriginStopTime: StopTime?
            let DestinationStopTime: StopTime?
        }

        // HSR API returns a direct array (no wrapper)
        let items = try JSONDecoder().decode([Item].self, from: data)
        return items.compactMap { item in
            guard let dep = item.OriginStopTime?.DepartureTime,
                  let arr = item.DestinationStopTime?.ArrivalTime,
                  !dep.isEmpty, !arr.isEmpty
            else { return nil }
            return TrainSchedule(
                departureTime: String(dep.prefix(5)),
                arrivalTime: String(arr.prefix(5)),
                trainType: item.TrainTypeName?.Zh_tw ?? "標準",
                trainNumber: "#\(item.TrainNo)",
                fare: 0
            )
        }
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
