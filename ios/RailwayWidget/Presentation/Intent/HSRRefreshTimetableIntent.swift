import AppIntents
import WidgetKit

struct HSRRefreshTimetableIntent: AppIntent {
    static var title: LocalizedStringResource = "查詢時刻表（高鐵）"
    static var description = IntentDescription("重新查詢最新台灣高鐵列車班次")

    func perform() async throws -> some IntentResult {
        let ds = AppGroupDataSource(system: .hsr)
        let route = ds.loadRoute() ?? RailwayWidgetEntry.hsrPlaceholderRoute

        guard let repo = TrainScheduleRepositoryImpl.make() else {
            ds.saveRefreshError("ERR_NO_CREDENTIALS")
            WidgetCenter.shared.reloadTimelines(ofKind: "HSRWidget")
            return .result()
        }

        let useCase = GetNextTrainsUseCase(repository: repo)
        let date = TaipeiClock.todayDate()
        do {
            let schedules = try await useCase.execute(
                from: route.fromId, to: route.toId, system: .hsr, date: date
            )
            ds.saveRefreshResult(route: route, schedules: schedules, lastUpdate: TaipeiClock.nowTime())
        } catch {
            ds.recordFetchError(error)
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "HSRWidget")
        return .result()
    }
}
