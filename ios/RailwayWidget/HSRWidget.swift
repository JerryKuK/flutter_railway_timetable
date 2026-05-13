import WidgetKit
import SwiftUI

struct HSRRailwayTimelineProvider: TimelineProvider {
    private let dataSource = AppGroupDataSource(system: .hsr)
    private let widgetDb: WidgetStationDatabase? = WidgetStationDatabase.make()

    func placeholder(in context: Context) -> RailwayWidgetEntry { .hsrPlaceholder }

    func getSnapshot(in context: Context, completion: @escaping (RailwayWidgetEntry) -> Void) {
        completion(.hsrPlaceholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RailwayWidgetEntry>) -> Void) {
        let route = dataSource.loadRoute() ?? RailwayWidgetEntry.hsrPlaceholderRoute
        let pickerMode = dataSource.loadPickerMode()
        let schedules = dataSource.loadSchedules()
        let lastError = dataSource.loadLastError()

        let pickerStations: [PickerStation]
        if let db = widgetDb {
            let useCase = GetPickerStationsUseCase(repository: PickerStationRepositoryImpl(db: db))
            pickerStations = useCase.execute(system: "HSR")
        } else {
            pickerStations = PickerStationDefaults.stations(for: "HSR")
        }

        let entry = RailwayWidgetEntry(
            date: Date(), route: route, schedules: schedules,
            pickerMode: pickerMode, lastError: lastError,
            pickerStations: pickerStations
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct HSRMediumWidget: Widget {
    let kind: String = "HSRWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HSRRailwayTimelineProvider()) { entry in
            MediumWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("高鐵時刻表")
        .description("顯示台灣高鐵下班車資訊")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    HSRMediumWidget()
} timeline: {
    RailwayWidgetEntry.hsrPlaceholder
}
