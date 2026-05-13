import Testing
import Foundation

@Suite("RailwayWidgetEntry — placeholder factories")
struct RailwayWidgetEntryTests {

    // MARK: - Task 3.1 — hsrPlaceholderRoute defaults to 臺北 → 左營

    @Test("hsrPlaceholderRoute uses traditional '臺北' and '左營' for HSR system")
    func hsrPlaceholderRoute_isTaipeiToZuoying() {
        let route = RailwayWidgetEntry.hsrPlaceholderRoute
        #expect(route.system == .hsr)
        #expect(route.fromName == "臺北", "Expected traditional '臺' character, not '台'")
        #expect(route.toName == "左營")
    }

    @Test("trPlaceholderRoute uses 臺北 → 高雄 for TR system")
    func trPlaceholderRoute_isTaipeiToKaohsiung() {
        let route = RailwayWidgetEntry.trPlaceholderRoute
        #expect(route.system == .tr)
        #expect(route.fromName == "臺北")
        #expect(route.toName == "高雄")
    }

    @Test("hsrPlaceholder entry carries HSR system and empty schedules")
    func hsrPlaceholder_isHSRWithNoSchedules() {
        let entry = RailwayWidgetEntry.hsrPlaceholder
        #expect(entry.route.system == .hsr)
        #expect(entry.schedules.isEmpty)
        #expect(entry.pickerMode == "none")
        #expect(entry.lastError == nil)
    }
}
