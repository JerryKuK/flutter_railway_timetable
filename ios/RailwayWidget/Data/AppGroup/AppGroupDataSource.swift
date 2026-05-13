import Foundation

struct AppGroupDataSource {
    static let appGroupID = "group.com.jerry.railwaytimetable.widget"

    private let suiteName: String
    private let system: RailwaySystem

    init(system: RailwaySystem, suiteName: String = Self.appGroupID) {
        self.system = system
        self.suiteName = suiteName
    }

    private var defaults: UserDefaults? { UserDefaults(suiteName: suiteName) }

    private var routeKey: String { "\(system.prefix)_widget_route" }
    private var pickerModeKey: String { "\(system.prefix)_widget_picker_mode" }
    private var schedulesKey: String { "\(system.prefix)_widget_schedules" }
    private var lastErrorKey: String { "\(system.prefix)_widget_last_error" }

    // MARK: - Route
    func loadRoute() -> WidgetRoute? {
        guard
            let json = defaults?.string(forKey: routeKey),
            let data = json.data(using: .utf8)
        else { return nil }
        return try? JSONDecoder().decode(WidgetRoute.self, from: data)
    }

    func saveRoute(_ route: WidgetRoute) {
        guard let data = try? JSONEncoder().encode(route) else { return }
        defaults?.set(String(data: data, encoding: .utf8), forKey: routeKey)
    }

    // MARK: - Picker Mode
    func loadPickerMode() -> String {
        defaults?.string(forKey: pickerModeKey) ?? "none"
    }

    func savePickerMode(_ mode: String) {
        defaults?.set(mode, forKey: pickerModeKey)
    }

    // MARK: - Last Error (nil = no error)
    func saveLastError(_ msg: String?) {
        if let msg { defaults?.set(msg, forKey: lastErrorKey) }
        else { defaults?.removeObject(forKey: lastErrorKey) }
    }

    func loadLastError() -> String? {
        defaults?.string(forKey: lastErrorKey)
    }

    // MARK: - Schedules (written by RefreshTimetableIntent, read by timeline provider)
    func saveSchedules(_ schedules: [TrainSchedule]) {
        let entries = schedules.map {
            ["dep": $0.departureTime, "arr": $0.arrivalTime, "type": $0.trainType, "num": $0.trainNumber]
        }
        defaults?.set(try? JSONSerialization.data(withJSONObject: entries), forKey: schedulesKey)
    }

    func loadSchedules() -> [TrainSchedule] {
        guard
            let data = defaults?.data(forKey: schedulesKey),
            let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: String]]
        else { return [] }
        return arr.compactMap { d in
            guard let dep = d["dep"], let arr = d["arr"],
                  let type_ = d["type"], let num = d["num"] else { return nil }
            return TrainSchedule(departureTime: dep, arrivalTime: arr, trainType: type_, trainNumber: num, fare: 0)
        }
    }
}
