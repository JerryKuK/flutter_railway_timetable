struct GetPickerStationsUseCase {
    private let repository: IPickerStationRepository

    init(repository: IPickerStationRepository) {
        self.repository = repository
    }

    /// Returns up to 10 ordered picker stations for `system`.
    /// Defaults are seeded by the Flutter app on first launch (Dart/Drift).
    /// Falls back to in-memory defaults if the DB is unavailable or empty.
    func execute(system: String) -> [PickerStation] {
        do {
            let dbStations = try repository.getStations(system: system)
            guard !dbStations.isEmpty else {
                return PickerStationDefaults.stations(for: system)
            }
            if dbStations.count < 10 {
                let existingNames = Set(dbStations.map { $0.name })
                let extras = PickerStationDefaults.stations(for: system)
                    .filter { !existingNames.contains($0.name) }
                return Array((dbStations + extras).prefix(10))
            }
            return dbStations
        } catch {
            return PickerStationDefaults.stations(for: system)
        }
    }
}
