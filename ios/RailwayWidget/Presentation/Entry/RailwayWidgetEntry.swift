import WidgetKit
import Foundation

struct RailwayWidgetEntry: TimelineEntry {
    let date: Date
    let route: WidgetRoute
    let schedules: [TrainSchedule]
    let pickerMode: String   // "none" | "from" | "to"
    let lastError: String?   // nil = no error
    let pickerStations: [PickerStation]  // ordered station list for the picker, sourced from SQLite

    static let placeholderRoute = WidgetRoute(
        system: .tr, fromId: "1000", fromName: "臺北", toId: "4400", toName: "高雄"
    )

    static var placeholder: RailwayWidgetEntry {
        RailwayWidgetEntry(
            date: Date(),
            route: placeholderRoute,
            schedules: [],
            pickerMode: "none",
            lastError: nil,
            pickerStations: PickerStationDefaults.stations(for: "TR")
        )
    }
}
