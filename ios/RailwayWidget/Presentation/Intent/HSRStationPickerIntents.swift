import AppIntents
import WidgetKit

// Show inline station picker within the HSR widget (no app launch)
struct HSRShowPickerIntent: AppIntent {
    static var title: LocalizedStringResource = "選擇車站（高鐵）"
    @Parameter(title: "Mode") var mode: String  // "from" or "to"

    init() { self.mode = "from" }
    init(mode: String) { self.mode = mode }

    func perform() async throws -> some IntentResult {
        AppGroupDataSource(system: .hsr).savePickerMode(mode)
        WidgetCenter.shared.reloadTimelines(ofKind: "HSRWidget")
        return .result()
    }
}

// Select a HSR station chip — stationId is passed directly, no lookup needed
struct HSRSelectStationIntent: AppIntent {
    static var title: LocalizedStringResource = "設定車站（高鐵）"
    @Parameter(title: "Station Name") var stationName: String
    @Parameter(title: "Station ID") var stationId: String

    init() { self.stationName = ""; self.stationId = "" }
    init(stationName: String, stationId: String) {
        self.stationName = stationName
        self.stationId = stationId
    }

    func perform() async throws -> some IntentResult {
        let ds = AppGroupDataSource(system: .hsr)
        let mode = ds.loadPickerMode()
        let current = ds.loadRoute() ?? RailwayWidgetEntry.hsrPlaceholderRoute

        let updated: WidgetRoute
        if mode == "from" {
            updated = WidgetRoute(system: .hsr,
                                  fromId: stationId, fromName: stationName,
                                  toId: current.toId, toName: current.toName)
        } else {
            updated = WidgetRoute(system: .hsr,
                                  fromId: current.fromId, fromName: current.fromName,
                                  toId: stationId, toName: stationName)
        }
        ds.saveRoute(updated)
        ds.savePickerMode("none")
        WidgetCenter.shared.reloadTimelines(ofKind: "HSRWidget")
        return .result()
    }
}

// Close HSR picker without changing station
struct HSRDismissPickerIntent: AppIntent {
    static var title: LocalizedStringResource = "關閉選站（高鐵）"

    func perform() async throws -> some IntentResult {
        AppGroupDataSource(system: .hsr).savePickerMode("none")
        WidgetCenter.shared.reloadTimelines(ofKind: "HSRWidget")
        return .result()
    }
}
