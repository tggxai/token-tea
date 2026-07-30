import Foundation

enum CodexUsageError: LocalizedError {
    case missingLogin
    case invalidResponse
    case unauthorized
    case noCoreLimit

    var errorDescription: String? {
        switch self {
        case .missingLogin: "Codex login was not found"
        case .invalidResponse: "Codex returned an invalid usage response"
        case .unauthorized: "Codex login needs to be refreshed"
        case .noCoreLimit: "General Codex usage is unavailable"
        }
    }
}

actor CodexUsageService {
    private let session: URLSession
    private let authURL: URL

    init(
        session: URLSession = .shared,
        authURL: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".codex/auth.json")
    ) {
        self.session = session
        self.authURL = authURL
    }

    func fetchCoreLimit() async throws -> RateLimitSnapshot {
        let authData = try Data(contentsOf: authURL)
        let auth = try JSONDecoder().decode(AuthFile.self, from: authData)
        guard !auth.tokens.accessToken.isEmpty, !auth.tokens.accountID.isEmpty else {
            throw CodexUsageError.missingLogin
        }

        var request = URLRequest(
            url: URL(string: "https://chatgpt.com/backend-api/wham/usage")!,
            timeoutInterval: 20
        )
        request.setValue("Bearer \(auth.tokens.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(auth.tokens.accountID, forHTTPHeaderField: "ChatGPT-Account-ID")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw CodexUsageError.invalidResponse
        }
        if http.statusCode == 401 || http.statusCode == 403 {
            throw CodexUsageError.unauthorized
        }
        guard (200..<300).contains(http.statusCode) else {
            throw CodexUsageError.invalidResponse
        }
        return try Self.parseCoreLimit(from: data)
    }

    static func parseCoreLimit(from data: Data, now: Date = .now) throws -> RateLimitSnapshot {
        let response = try JSONDecoder().decode(UsageResponse.self, from: data)

        if let monthly = response.spendControl?.individualLimit,
           let remaining = monthly.remainingPercent {
            return RateLimitSnapshot(
                id: "core-monthly",
                timestamp: now,
                usedPercent: 100 - remaining,
                windowMinutes: 30 * 24 * 60,
                resetsAt: monthly.resetAt.map { Date(timeIntervalSince1970: $0) }
            )
        }

        let windows = [
            response.rateLimit?.primaryWindow,
            response.rateLimit?.secondaryWindow
        ].compactMap { $0 }

        guard let mostUsed = windows.max(by: { lhs, rhs in
            if lhs.usedPercent == rhs.usedPercent {
                return (lhs.resetAt ?? 0) < (rhs.resetAt ?? 0)
            }
            return lhs.usedPercent < rhs.usedPercent
        }) else {
            throw CodexUsageError.noCoreLimit
        }

        return RateLimitSnapshot(
            id: "core",
            timestamp: now,
            usedPercent: mostUsed.usedPercent,
            windowMinutes: Int((mostUsed.limitWindowSeconds ?? 0) / 60),
            resetsAt: mostUsed.resetAt.map { Date(timeIntervalSince1970: $0) }
        )
    }
}

private struct AuthFile: Decodable {
    let tokens: AuthTokens
}

private struct AuthTokens: Decodable {
    let accessToken: String
    let accountID: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case accountID = "account_id"
    }
}

private struct UsageResponse: Decodable {
    let rateLimit: CoreRateLimit?
    let spendControl: SpendControl?

    enum CodingKeys: String, CodingKey {
        case rateLimit = "rate_limit"
        case spendControl = "spend_control"
    }
}

private struct CoreRateLimit: Decodable {
    let primaryWindow: UsageWindow?
    let secondaryWindow: UsageWindow?

    enum CodingKeys: String, CodingKey {
        case primaryWindow = "primary_window"
        case secondaryWindow = "secondary_window"
    }
}

private struct UsageWindow: Decodable {
    let usedPercent: Double
    let resetAt: Double?
    let limitWindowSeconds: Double?

    enum CodingKeys: String, CodingKey {
        case usedPercent = "used_percent"
        case resetAt = "reset_at"
        case limitWindowSeconds = "limit_window_seconds"
    }
}

private struct SpendControl: Decodable {
    let individualLimit: IndividualLimit?

    enum CodingKeys: String, CodingKey {
        case individualLimit = "individual_limit"
    }
}

private struct IndividualLimit: Decodable {
    let remainingPercent: Double?
    let resetAt: Double?

    enum CodingKeys: String, CodingKey {
        case remainingPercent = "remaining_percent"
        case resetAt = "reset_at"
    }
}
