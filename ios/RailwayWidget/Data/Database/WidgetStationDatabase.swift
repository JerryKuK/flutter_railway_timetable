import GRDB
import Foundation

final class WidgetStationDatabase {
    let pool: DatabasePool

    // Opens the shared SQLite written by the Flutter app (Dart/Drift).
    // Uses DatabasePool so WAL readers from the widget extension don't
    // conflict with the write connection held open by the main app process.
    static func make() -> WidgetStationDatabase? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppGroupDataSource.appGroupID
        ) else { return nil }
        let dbPath = containerURL.appendingPathComponent("widget_stations.db").path
        var config = Configuration()
        config.maximumReaderCount = 1
        guard let pool = try? DatabasePool(path: dbPath, configuration: config) else { return nil }
        return WidgetStationDatabase(pool: pool)
    }

    private init(pool: DatabasePool) {
        self.pool = pool
    }
}
