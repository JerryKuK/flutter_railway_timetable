import AppIntents
import WidgetKit

// Show inline station picker within the widget (no app launch)
struct ShowPickerIntent: AppIntent {
    static var title: LocalizedStringResource = "選擇車站"
    @Parameter(title: "Mode") var mode: String  // "from" or "to"

    init() { self.mode = "from" }
    init(mode: String) { self.mode = mode }

    func perform() async throws -> some IntentResult {
        AppGroupDataSource().savePickerMode(mode)
        WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")
        return .result()
    }
}

// Select a station chip — stationId is passed directly, no lookup needed
struct SelectStationIntent: AppIntent {
    static var title: LocalizedStringResource = "設定車站"
    @Parameter(title: "Station Name") var stationName: String
    @Parameter(title: "Station ID") var stationId: String

    init() { self.stationName = ""; self.stationId = "" }
    init(stationName: String, stationId: String) {
        self.stationName = stationName
        self.stationId = stationId
    }

    func perform() async throws -> some IntentResult {
        let ds = AppGroupDataSource()
        let mode = ds.loadPickerMode()
        let current = ds.loadRoute() ?? RailwayWidgetEntry.placeholderRoute

        let updated: WidgetRoute
        if mode == "from" {
            updated = WidgetRoute(system: current.system,
                                  fromId: stationId, fromName: stationName,
                                  toId: current.toId, toName: current.toName)
        } else {
            updated = WidgetRoute(system: current.system,
                                  fromId: current.fromId, fromName: current.fromName,
                                  toId: stationId, toName: stationName)
        }
        ds.saveRoute(updated)
        ds.savePickerMode("none")
        WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")
        return .result()
    }
}

// Close picker without changing station
struct DismissPickerIntent: AppIntent {
    static var title: LocalizedStringResource = "關閉選站"

    func perform() async throws -> some IntentResult {
        AppGroupDataSource().savePickerMode("none")
        WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")
        return .result()
    }
}
