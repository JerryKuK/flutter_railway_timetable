import Foundation

struct GetNextTrainsUseCase {
    private let repository: TrainScheduleRepository

    init(repository: TrainScheduleRepository) {
        self.repository = repository
    }

    func execute(from: String, to: String, system: RailwaySystem, date: String, now: Date = Date()) async throws -> [TrainSchedule] {
        let all = try await repository.getNextTrains(from: from, to: to, system: system, date: date)
        let sorted = all.sorted { $0.departureTime < $1.departureTime }
        let nowString = TaipeiClock.nowTime(now)
        var result = sorted.filter { $0.departureTime >= nowString }

        if result.count < 2 {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(identifier: "Asia/Taipei")!
            if let tomorrow = cal.date(byAdding: .day, value: 1, to: now) {
                let tomorrowStr = TaipeiClock.todayDate(tomorrow)
                if let tomorrowAll = try? await repository.getNextTrains(from: from, to: to, system: system, date: tomorrowStr) {
                    let tomorrowSorted = tomorrowAll.sorted { $0.departureTime < $1.departureTime }
                    result += tomorrowSorted.prefix(2 - result.count)
                }
            }
        }

        return Array(result.prefix(2))
    }
}

