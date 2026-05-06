import Foundation

struct GetNextTrainsUseCase {
    private let repository: TrainScheduleRepository

    init(repository: TrainScheduleRepository) {
        self.repository = repository
    }

    func execute(from: String, to: String, system: RailwaySystem, date: String, now: Date = Date()) async throws -> [TrainSchedule] {
        let all = try await repository.getNextTrains(from: from, to: to, system: system, date: date)
        let sorted = all.sorted { $0.departureTime < $1.departureTime }
        let nowString = DateFormatter.hhmm.string(from: now)
        var result = sorted.filter { $0.departureTime >= nowString }

        if result.count < 2 {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(identifier: "Asia/Taipei")!
            if let tomorrow = cal.date(byAdding: .day, value: 1, to: now) {
                let tomorrowStr = DateFormatter.yyyyMMddTaipei.string(from: tomorrow)
                if let tomorrowAll = try? await repository.getNextTrains(from: from, to: to, system: system, date: tomorrowStr) {
                    let tomorrowSorted = tomorrowAll.sorted { $0.departureTime < $1.departureTime }
                    result += tomorrowSorted.prefix(2 - result.count)
                }
            }
        }

        return Array(result.prefix(2))
    }
}

private extension DateFormatter {
    static let hhmm: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone(identifier: "Asia/Taipei")
        f.dateFormat = "HH:mm"
        return f
    }()

    static let yyyyMMddTaipei: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone(identifier: "Asia/Taipei")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
