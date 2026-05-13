import AppIntents
import WidgetKit

struct RefreshTimetableIntent: AppIntent {
    static var title: LocalizedStringResource = "查詢時刻表（台鐵）"
    static var description = IntentDescription("重新查詢最新台鐵列車班次")

    func perform() async throws -> some IntentResult {
        let ds = AppGroupDataSource(system: .tr)
        let route = ds.loadRoute() ?? RailwayWidgetEntry.trPlaceholderRoute

        guard let repo = TrainScheduleRepositoryImpl.make() else {
            ds.saveSchedules([])
            ds.saveLastError("ERR_NO_CREDENTIALS")
            WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")
            return .result()
        }

        let useCase = GetNextTrainsUseCase(repository: repo)
        let date = DateFormatter.yyyyMMdd.string(from: Date())
        do {
            let schedules = try await useCase.execute(
                from: route.fromId, to: route.toId, system: route.system, date: date
            )
            ds.saveSchedules(schedules)
            ds.saveLastError(nil)
        } catch {
            ds.recordFetchError(error)
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")
        return .result()
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone(identifier: "Asia/Taipei")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
