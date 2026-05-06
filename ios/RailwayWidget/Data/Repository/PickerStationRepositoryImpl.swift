import GRDB

// MARK: - GRDB record (Data layer only — not exposed to Domain)
private struct PickerStationRecord: Codable, FetchableRecord, TableRecord {
    var id: Int64?
    var name: String
    var stationId: String
    var system: String
    var sortOrder: Int

    static let databaseTableName = "widget_stations"

    enum CodingKeys: String, CodingKey {
        case id; case name
        case stationId = "station_id"
        case system
        case sortOrder = "sort_order"
    }
}

// MARK: - Repository (read-only — writes are handled by the Flutter app via Drift)
struct PickerStationRepositoryImpl: IPickerStationRepository {
    private let db: WidgetStationDatabase

    init(db: WidgetStationDatabase) { self.db = db }

    func getStations(system: String) throws -> [PickerStation] {
        try db.pool.read { conn in
            try PickerStationRecord
                .filter(Column("system") == system)
                .order(Column("sort_order").asc)
                .fetchAll(conn)
                .map { PickerStation(name: $0.name, stationId: $0.stationId, system: $0.system, sortOrder: $0.sortOrder) }
        }
    }
}
