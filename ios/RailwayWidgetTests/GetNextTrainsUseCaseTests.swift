import XCTest
@testable import RailwayWidget

// MARK: - Mock

private class MockTrainScheduleRepository: TrainScheduleRepository {
    var stubbedSchedules: [TrainSchedule] = []
    var shouldThrow = false

    func getNextTrains(from: String, to: String, system: RailwaySystem, date: String) async throws -> [TrainSchedule] {
        if shouldThrow { throw URLError(.badServerResponse) }
        return stubbedSchedules
    }
}

// MARK: - Tests

final class GetNextTrainsUseCaseTests: XCTestCase {
    private var mock: MockTrainScheduleRepository!
    private var useCase: GetNextTrainsUseCase!

    override func setUp() {
        super.setUp()
        mock = MockTrainScheduleRepository()
        useCase = GetNextTrainsUseCase(repository: mock)
    }

    func testEmptyInput_returnsEmpty() async throws {
        mock.stubbedSchedules = []
        let result = try await useCase.execute(from: "1000", to: "4400", system: .tr, date: "2026-05-06", now: date("10:00"))
        XCTAssertTrue(result.isEmpty)
    }

    func testFiltersOutPastTrains() async throws {
        mock.stubbedSchedules = [
            schedule(dep: "08:00"), // past (now = 10:00)
            schedule(dep: "09:59"), // past
            schedule(dep: "10:00"), // exactly now — included
            schedule(dep: "11:00"),
        ]
        let result = try await useCase.execute(from: "1000", to: "4400", system: .tr, date: "2026-05-06", now: date("10:00"))
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].departureTime, "10:00")
        XCTAssertEqual(result[1].departureTime, "11:00")
    }

    func testReturnsCapped2Results() async throws {
        mock.stubbedSchedules = [
            schedule(dep: "10:00"),
            schedule(dep: "10:30"),
            schedule(dep: "11:00"),
            schedule(dep: "11:30"),
        ]
        let result = try await useCase.execute(from: "1000", to: "4400", system: .tr, date: "2026-05-06", now: date("09:00"))
        XCTAssertEqual(result.count, 2)
    }

    func testSortsByDepartureTimeBeforeFiltering() async throws {
        mock.stubbedSchedules = [
            schedule(dep: "12:00"),
            schedule(dep: "10:00"),
            schedule(dep: "11:00"),
        ]
        let result = try await useCase.execute(from: "1000", to: "4400", system: .tr, date: "2026-05-06", now: date("09:00"))
        XCTAssertEqual(result[0].departureTime, "10:00")
        XCTAssertEqual(result[1].departureTime, "11:00")
    }

    func testAllTrainsPast_returnsEmpty() async throws {
        mock.stubbedSchedules = [schedule(dep: "06:00"), schedule(dep: "07:00")]
        let result = try await useCase.execute(from: "1000", to: "4400", system: .tr, date: "2026-05-06", now: date("23:59"))
        XCTAssertTrue(result.isEmpty)
    }

    func testRepositoryThrows_propagatesError() async {
        mock.shouldThrow = true
        do {
            _ = try await useCase.execute(from: "1000", to: "4400", system: .tr, date: "2026-05-06")
            XCTFail("Expected error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}

// MARK: - Helpers

private func schedule(dep: String, arr: String = "XX:XX") -> TrainSchedule {
    TrainSchedule(departureTime: dep, arrivalTime: arr, trainType: "自強", trainNumber: "#100", fare: 0)
}

private func date(_ hhmm: String) -> Date {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd HH:mm"
    return f.date(from: "2026-05-06 \(hhmm)")!
}
