import Foundation

struct AppGroupDataSource {
    static let appGroupID = "group.com.jerry.railwaytimetable.widget"
    static let routeKey = "widget_route"
    static let pickerModeKey = "widget_picker_mode"
    static let schedulesKey = "widget_schedules"
    static let lastErrorKey = "widget_last_error"

    private let suiteName: String
    init(suiteName: String = Self.appGroupID) { self.suiteName = suiteName }

    private var defaults: UserDefaults? { UserDefaults(suiteName: suiteName) }

    // MARK: - Route
    func loadRoute() -> WidgetRoute? {
        guard
            let json = defaults?.string(forKey: Self.routeKey),
            let data = json.data(using: .utf8)
        else { return nil }
        return try? JSONDecoder().decode(WidgetRoute.self, from: data)
    }

    func saveRoute(_ route: WidgetRoute) {
        guard let data = try? JSONEncoder().encode(route) else { return }
        defaults?.set(String(data: data, encoding: .utf8), forKey: Self.routeKey)
    }

    // MARK: - Picker Mode
    func loadPickerMode() -> String {
        defaults?.string(forKey: Self.pickerModeKey) ?? "none"
    }

    func savePickerMode(_ mode: String) {
        defaults?.set(mode, forKey: Self.pickerModeKey)
    }

    // MARK: - Last Error (nil = no error)
    func saveLastError(_ msg: String?) {
        if let msg { defaults?.set(msg, forKey: Self.lastErrorKey) }
        else { defaults?.removeObject(forKey: Self.lastErrorKey) }
    }

    func loadLastError() -> String? {
        defaults?.string(forKey: Self.lastErrorKey)
    }

    // MARK: - Schedules (written by RefreshTimetableIntent, read by timeline provider)
    func saveSchedules(_ schedules: [TrainSchedule]) {
        let entries = schedules.map {
            ["dep": $0.departureTime, "arr": $0.arrivalTime, "type": $0.trainType, "num": $0.trainNumber]
        }
        defaults?.set(try? JSONSerialization.data(withJSONObject: entries), forKey: Self.schedulesKey)
    }

    func loadSchedules() -> [TrainSchedule] {
        guard
            let data = defaults?.data(forKey: Self.schedulesKey),
            let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: String]]
        else { return [] }
        return arr.compactMap { d in
            guard let dep = d["dep"], let arr = d["arr"],
                  let type_ = d["type"], let num = d["num"] else { return nil }
            return TrainSchedule(departureTime: dep, arrivalTime: arr, trainType: type_, trainNumber: num, fare: 0)
        }
    }
}
