import Testing
import Foundation

@Suite("AppGroupDataSource — key prefix isolation")
struct AppGroupDataSourceTests {

    // Each test uses a unique suite to avoid cross-test contamination.
    private func freshSuite() -> String { "test.\(UUID().uuidString)" }

    private let sampleTRRoute = WidgetRoute(
        system: .tr, fromId: "1000", fromName: "臺北", toId: "4400", toName: "高雄"
    )
    private let sampleHSRRoute = WidgetRoute(
        system: .hsr, fromId: "1000", fromName: "臺北", toId: "1070", toName: "左營"
    )

    // MARK: - Task 1.1 — init(system: .tr) writes only to tr_widget_* keys

    @Test("init(system: .tr) writes route to key 'tr_widget_route'")
    func tr_saveRoute_writesToTRPrefixedKey() throws {
        let suite = freshSuite()
        let ds = AppGroupDataSource(system: .tr, suiteName: suite)
        ds.saveRoute(sampleTRRoute)

        let raw = UserDefaults(suiteName: suite)?.string(forKey: "tr_widget_route")
        #expect(raw != nil, "Expected tr_widget_route to be populated")

        // Confirm the generic legacy key is NOT touched
        let legacy = UserDefaults(suiteName: suite)?.string(forKey: "widget_route")
        #expect(legacy == nil, "Legacy widget_route key must remain untouched")
    }

    @Test("init(system: .tr) picker_mode / schedules / last_error all use tr_widget_* prefix")
    func tr_allFourKeys_useTRPrefix() throws {
        let suite = freshSuite()
        let ds = AppGroupDataSource(system: .tr, suiteName: suite)

        ds.savePickerMode("from")
        ds.saveSchedules([
            TrainSchedule(departureTime: "08:00", arrivalTime: "12:00",
                          trainType: "自強", trainNumber: "#171", fare: 0)
        ])
        ds.saveLastError("ERR_TEST")

        let d = UserDefaults(suiteName: suite)
        #expect(d?.string(forKey: "tr_widget_picker_mode") == "from")
        #expect(d?.data(forKey: "tr_widget_schedules") != nil)
        #expect(d?.string(forKey: "tr_widget_last_error") == "ERR_TEST")

        // Legacy keys remain untouched
        #expect(d?.string(forKey: "widget_picker_mode") == nil)
        #expect(d?.data(forKey: "widget_schedules") == nil)
        #expect(d?.string(forKey: "widget_last_error") == nil)
    }

    // MARK: - Task 1.2 — init(system: .hsr) writes only to hsr_widget_* keys and never collides with TR

    @Test("init(system: .hsr) writes route to key 'hsr_widget_route'")
    func hsr_saveRoute_writesToHSRPrefixedKey() throws {
        let suite = freshSuite()
        let ds = AppGroupDataSource(system: .hsr, suiteName: suite)
        ds.saveRoute(sampleHSRRoute)

        let raw = UserDefaults(suiteName: suite)?.string(forKey: "hsr_widget_route")
        #expect(raw != nil, "Expected hsr_widget_route to be populated")
        #expect(UserDefaults(suiteName: suite)?.string(forKey: "tr_widget_route") == nil,
                "TR key must remain untouched when only HSR datasource writes")
    }

    @Test("tr & hsr datasources on same suite never overwrite each other")
    func trAndHSR_doNotCollide() throws {
        let suite = freshSuite()
        let trDS = AppGroupDataSource(system: .tr, suiteName: suite)
        let hsrDS = AppGroupDataSource(system: .hsr, suiteName: suite)

        trDS.saveRoute(sampleTRRoute)
        hsrDS.saveRoute(sampleHSRRoute)

        let trReadBack = trDS.loadRoute()
        let hsrReadBack = hsrDS.loadRoute()

        #expect(trReadBack == sampleTRRoute, "TR datasource must read back the TR route it wrote")
        #expect(hsrReadBack == sampleHSRRoute, "HSR datasource must read back the HSR route it wrote")
    }

    @Test("hsr saveSchedules does not touch tr_widget_schedules")
    func hsr_saveSchedules_doesNotTouchTRSchedules() throws {
        let suite = freshSuite()
        let trDS = AppGroupDataSource(system: .tr, suiteName: suite)
        let hsrDS = AppGroupDataSource(system: .hsr, suiteName: suite)

        let trSched = [TrainSchedule(departureTime: "08:00", arrivalTime: "12:00",
                                      trainType: "自強", trainNumber: "#171", fare: 0)]
        let hsrSched = [TrainSchedule(departureTime: "09:06", arrivalTime: "11:09",
                                       trainType: "標準", trainNumber: "#617", fare: 0)]

        trDS.saveSchedules(trSched)
        hsrDS.saveSchedules(hsrSched)

        #expect(trDS.loadSchedules().first?.trainNumber == "#171")
        #expect(hsrDS.loadSchedules().first?.trainNumber == "#617")
    }
}
