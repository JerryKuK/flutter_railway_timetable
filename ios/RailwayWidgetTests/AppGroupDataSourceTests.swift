import XCTest
@testable import RailwayWidget

// NOTE: Tests run in the app process, so UserDefaults(suiteName:) works.
// The test suite name is unique to avoid polluting the real app group.

final class AppGroupDataSourceTests: XCTestCase {
    private let testSuite = "com.test.railway.appgroup.\(UUID().uuidString)"
    private var ds: AppGroupDataSource!

    override func setUp() {
        super.setUp()
        ds = AppGroupDataSource(suiteName: testSuite)
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults(suiteName: testSuite)?.removePersistentDomain(forName: testSuite)
    }

    // MARK: - Route

    func testSaveLoadRoute_roundTrip() {
        let route = WidgetRoute(system: .tr, fromId: "1000", fromName: "臺北", toId: "4400", toName: "高雄")
        ds.saveRoute(route)
        let loaded = ds.loadRoute()
        XCTAssertEqual(loaded, route)
    }

    func testLoadRoute_returnsNilWhenEmpty() {
        XCTAssertNil(ds.loadRoute())
    }

    func testSaveLoadRoute_hsr() {
        let route = WidgetRoute(system: .hsr, fromId: "1000", fromName: "台北", toId: "1070", toName: "左營")
        ds.saveRoute(route)
        let loaded = ds.loadRoute()
        XCTAssertEqual(loaded?.system, .hsr)
        XCTAssertEqual(loaded?.toId, "1070")
    }

    // MARK: - Picker Mode

    func testLoadPickerMode_defaultsToNone() {
        XCTAssertEqual(ds.loadPickerMode(), "none")
    }

    func testSavePickerMode_from() {
        ds.savePickerMode("from")
        XCTAssertEqual(ds.loadPickerMode(), "from")
    }

    func testSavePickerMode_to() {
        ds.savePickerMode("to")
        XCTAssertEqual(ds.loadPickerMode(), "to")
    }

    // MARK: - Last Error

    func testLoadLastError_returnsNilWhenEmpty() {
        XCTAssertNil(ds.loadLastError())
    }

    func testSaveLastError_string() {
        ds.saveLastError("ERR_HTTP_401")
        XCTAssertEqual(ds.loadLastError(), "ERR_HTTP_401")
    }

    func testSaveLastError_nil_clearsError() {
        ds.saveLastError("ERR_HTTP_401")
        ds.saveLastError(nil)
        XCTAssertNil(ds.loadLastError())
    }

    // MARK: - Schedules

    func testSaveLoadSchedules_roundTrip() {
        let schedules = [
            TrainSchedule(departureTime: "10:00", arrivalTime: "14:30", trainType: "自強", trainNumber: "#101", fare: 0),
            TrainSchedule(departureTime: "11:00", arrivalTime: "15:00", trainType: "莒光", trainNumber: "#202", fare: 0),
        ]
        ds.saveSchedules(schedules)
        let loaded = ds.loadSchedules()
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].departureTime, "10:00")
        XCTAssertEqual(loaded[1].trainType, "莒光")
    }

    func testLoadSchedules_returnsEmptyWhenNotSaved() {
        XCTAssertTrue(ds.loadSchedules().isEmpty)
    }

    func testSaveSchedules_overwritesPrevious() {
        ds.saveSchedules([
            TrainSchedule(departureTime: "08:00", arrivalTime: "12:00", trainType: "自強", trainNumber: "#1", fare: 0)
        ])
        ds.saveSchedules([])
        XCTAssertTrue(ds.loadSchedules().isEmpty)
    }
}
