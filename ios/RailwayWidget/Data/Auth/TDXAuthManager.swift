import Foundation

enum TDXAuthError: Error {
    case missingCredentials
    case tokenFetchFailed
}

// Mirrors Flutter's TdxAuthInterceptor: client_credentials OAuth2 with in-memory token cache.
actor TDXAuthManager {
    private let clientId: String
    private let clientSecret: String
    private var accessToken: String?
    private var tokenExpiry: Date?

    private static let tokenURL = URL(string: "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token")!

    // Throws TDXAuthError.missingCredentials if xcconfig keys are not injected.
    init() throws {
        let info = Bundle.main.infoDictionary
        let rawId = info?["TDX_CLIENT_ID"] as? String ?? ""
        let rawSecret = info?["TDX_CLIENT_SECRET"] as? String ?? ""
        // Guard against unexpanded xcconfig placeholder strings
        guard !rawId.isEmpty, rawId != "$(TDX_CLIENT_ID)",
              !rawSecret.isEmpty, rawSecret != "$(TDX_CLIENT_SECRET)"
        else {
            throw TDXAuthError.missingCredentials
        }
        self.clientId = rawId
        self.clientSecret = rawSecret
    }

    func validToken() async throws -> String {
        if let token = accessToken, let expiry = tokenExpiry, Date() < expiry {
            return token
        }
        return try await refreshToken()
    }

    private func refreshToken() async throws -> String {
        var request = URLRequest(url: Self.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials&client_id=\(clientId)&client_secret=\(clientSecret)".data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let token = json["access_token"] as? String,
            let expiresIn = json["expires_in"] as? Int
        else { throw TDXAuthError.tokenFetchFailed }

        accessToken = token
        tokenExpiry = Date().addingTimeInterval(Double(expiresIn) - 60)
        return token
    }
}
