import WidgetKit
import SwiftUI

struct RailwayTimelineProvider: TimelineProvider {
    private let dataSource = AppGroupDataSource(system: .tr)
    private let widgetDb: WidgetStationDatabase? = WidgetStationDatabase.make()

    func placeholder(in context: Context) -> RailwayWidgetEntry { .trPlaceholder }

    func getSnapshot(in context: Context, completion: @escaping (RailwayWidgetEntry) -> Void) {
        completion(.trPlaceholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RailwayWidgetEntry>) -> Void) {
        let route = dataSource.loadRoute() ?? RailwayWidgetEntry.trPlaceholderRoute
        let pickerMode = dataSource.loadPickerMode()
        let schedules = dataSource.loadSchedules()
        let lastError = dataSource.loadLastError()
        let lastUpdate = dataSource.loadLastUpdate()

        let pickerStations: [PickerStation]
        if let db = widgetDb {
            let useCase = GetPickerStationsUseCase(repository: PickerStationRepositoryImpl(db: db))
            pickerStations = useCase.execute(system: "TR")
        } else {
            pickerStations = PickerStationDefaults.stations(for: "TR")
        }

        let entry = RailwayWidgetEntry(
            date: Date(), route: route, schedules: schedules,
            pickerMode: pickerMode, lastError: lastError,
            pickerStations: pickerStations, lastUpdate: lastUpdate
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct RailwayWidget: Widget {
    let kind: String = "RailwayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RailwayTimelineProvider()) { entry in
            MediumWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("台鐵時刻表")
        .description("顯示台鐵下班車資訊")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    RailwayWidget()
} timeline: {
    RailwayWidgetEntry.trPlaceholder
}
