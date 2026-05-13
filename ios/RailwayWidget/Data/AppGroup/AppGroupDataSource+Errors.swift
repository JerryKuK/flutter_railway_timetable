import Foundation

extension AppGroupDataSource {
    /// Maps a fetch error to a stable string code and persists it as `lastError`,
    /// while clearing schedules so the widget shows the error state.
    func recordFetchError(_ error: Error) {
        let message: String
        if let auth = error as? TDXAuthError {
            message = "ERR_AUTH: \(auth)"
        } else if let api = error as? TDXAPIError {
            switch api {
            case .httpError(let code): message = "ERR_HTTP_\(code)"
            case .invalidURL:          message = "ERR_INVALID_URL"
            }
        } else {
            message = "ERR: \(error.localizedDescription)"
        }
        saveSchedules([])
        saveLastError(message)
    }
}