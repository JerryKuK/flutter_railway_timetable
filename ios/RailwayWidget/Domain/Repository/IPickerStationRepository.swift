protocol IPickerStationRepository {
    func getStations(system: String) throws -> [PickerStation]
}
