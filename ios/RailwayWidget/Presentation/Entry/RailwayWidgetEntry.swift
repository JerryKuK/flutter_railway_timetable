import WidgetKit
import Foundation

struct RailwayWidgetEntry: TimelineEntry {
    let date: Date
    let route: WidgetRoute
    let schedules: [TrainSchedule]
    let pickerMode: String   // "none" | "from" | "to"
    let lastError: String?   // nil = no error
    let pickerStations: [PickerStation]  // ordered station list for the picker, sourced from SQLite
    let lastUpdate: String?  // nil = never refreshed; otherwise "HH:mm" Asia/Taipei of the last successful API fetch

    static let trPlaceholderRoute = WidgetRoute(
        system: .tr, fromId: "1000", fromName: "臺北", toId: "4400", toName: "高雄"
    )

    static let hsrPlaceholderRoute = WidgetRoute(
        system: .hsr, fromId: "1000", fromName: "臺北", toId: "1070", toName: "左營"
    )

    static var trPlaceholder: RailwayWidgetEntry {
        RailwayWidgetEntry(
            date: Date(),
            route: trPlaceholderRoute,
            schedules: [],
            pickerMode: "none",
            lastError: nil,
            pickerStations: PickerStationDefaults.stations(for: "TR"),
            lastUpdate: nil
        )
    }

    static var hsrPlaceholder: RailwayWidgetEntry {
        RailwayWidgetEntry(
            date: Date(),
            route: hsrPlaceholderRoute,
            schedules: [],
            pickerMode: "none",
            lastError: nil,
            pickerStations: PickerStationDefaults.stations(for: "HSR"),
            lastUpdate: nil
        )
    }
}
