import Foundation

struct TrainScheduleRepositoryImpl: TrainScheduleRepository {
    private let authManager: TDXAuthManager
    private let apiClient: TDXAPIClient

    // Returns nil if TDX credentials are missing (xcconfig not linked).
    static func make() -> TrainScheduleRepositoryImpl? {
        guard let auth = try? TDXAuthManager() else { return nil }
        return TrainScheduleRepositoryImpl(authManager: auth, apiClient: TDXAPIClient())
    }

    private init(authManager: TDXAuthManager, apiClient: TDXAPIClient) {
        self.authManager = authManager
        self.apiClient = apiClient
    }

    func getNextTrains(from: String, to: String, system: RailwaySystem, date: String) async throws -> [TrainSchedule] {
        let token = try await authManager.validToken()
        switch system {
        case .tr:  return try await apiClient.fetchTRASchedule(from: from, to: to, date: date, token: token)
        case .hsr: return try await apiClient.fetchHSRSchedule(from: from, to: to, date: date, token: token)
        }
    }
}
