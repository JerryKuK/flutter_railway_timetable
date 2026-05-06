import XCTest
@testable import RailwayWidget

// MARK: - Mock

private class MockPickerStationRepository: IPickerStationRepository {
    var stubbedStations: [PickerStation] = []
    var shouldThrow = false

    func getStations(system: String) throws -> [PickerStation] {
        if shouldThrow { throw NSError(domain: "DB", code: -1) }
        return stubbedStations
    }
}

// MARK: - Helpers

private func station(_ name: String, id: String = "0000", system: String = "TR", order: Int = 0) -> PickerStation {
    PickerStation(name: name, stationId: id, system: system, sortOrder: order)
}

// MARK: - Tests

final class GetPickerStationsUseCaseTests: XCTestCase {
    private var mock: MockPickerStationRepository!
    private var useCase: GetPickerStationsUseCase!

    override func setUp() {
        super.setUp()
        mock = MockPickerStationRepository()
        useCase = GetPickerStationsUseCase(repository: mock)
    }

    func testEmptyDB_returnsDefaults() {
        mock.stubbedStations = []
        let result = useCase.execute(system: "TR")
        let defaults = PickerStationDefaults.stations(for: "TR")
        XCTAssertEqual(result.map { $0.name }, defaults.map { $0.name })
    }

    func testDBThrows_returnsDefaults() {
        mock.shouldThrow = true
        let result = useCase.execute(system: "TR")
        XCTAssertEqual(result, PickerStationDefaults.stations(for: "TR"))
    }

    func testFullDB_returnDBStationsOnly() {
        let dbStations = (0..<10).map { station("站\($0)", id: "100\($0)", order: $0) }
        mock.stubbedStations = dbStations
        let result = useCase.execute(system: "TR")
        XCTAssertEqual(result.count, 10)
        XCTAssertEqual(result.map { $0.name }, dbStations.map { $0.name })
    }

    func testPartialDB_fillsWithDefaultsUpTo10() {
        // 5 DB stations (names not in defaults)
        mock.stubbedStations = (0..<5).map { station("獨特站\($0)", id: "999\($0)", order: $0) }
        let result = useCase.execute(system: "TR")
        XCTAssertEqual(result.count, 10)
        // DB stations come first
        XCTAssertEqual(result.prefix(5).map { $0.name }, mock.stubbedStations.map { $0.name })
    }

    func testPartialDB_noDuplicatesWithDefaults() {
        // DB contains "臺北" which is also in defaults
        mock.stubbedStations = [station("臺北", id: "1000", order: 0)]
        let result = useCase.execute(system: "TR")
        let names = result.map { $0.name }
        XCTAssertEqual(names.filter { $0 == "臺北" }.count, 1, "臺北 should not be duplicated")
    }

    func testReturnsCappedAt10() {
        // 8 DB stations, none in defaults — total after merge would be 8 + 10 = 18, should cap at 10
        mock.stubbedStations = (0..<8).map { station("新站\($0)", order: $0) }
        let result = useCase.execute(system: "TR")
        XCTAssertEqual(result.count, 10)
    }

    func testHSRSystem_returnsHSRDefaults() {
        mock.stubbedStations = []
        let result = useCase.execute(system: "HSR")
        XCTAssertEqual(result, PickerStationDefaults.stations(for: "HSR"))
    }
}
