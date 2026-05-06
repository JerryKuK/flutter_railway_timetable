import Foundation

protocol TrainScheduleRepository {
    func getNextTrains(from: String, to: String, system: RailwaySystem, date: String) async throws -> [TrainSchedule]
}
