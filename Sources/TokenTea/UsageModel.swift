import OSLog
import SwiftUI

@MainActor
final class UsageModel: ObservableObject {
    @Published var usage = TokenUsage()
    @Published var rateLimit: RateLimitSnapshot?
    @Published var lastUpdated: Date?
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    var remainingFraction: Double {
        (rateLimit?.remainingPercent ?? 0) / 100
    }

    var remainingPercent: Int {
        Int((remainingFraction * 100).rounded())
    }

    private let reader = TokenUsageReader()
    private let usageService = CodexUsageService()
    private var refreshTask: Task<Void, Never>?
    private let logger = Logger(subsystem: "com.local.TokenTea", category: "usage")

    func start() {
        guard refreshTask == nil else { return }
        refreshTask = Task { [weak self] in
            guard let self else { return }
            await self.refresh()
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                await self.refresh()
            }
        }
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        async let localUsage = reader.usage()
        do {
            rateLimit = try await usageService.fetchCoreLimit()
            errorMessage = nil
            logger.info("Core usage refreshed: \(self.remainingPercent, privacy: .public)% remaining")
        } catch {
            rateLimit = nil
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Could not load Codex usage"
            logger.error("Core usage refresh failed: \(self.errorMessage ?? "Unknown error", privacy: .public)")
        }
        usage = await localUsage
        lastUpdated = .now
        isRefreshing = false
    }
}

extension Int {
    var compactTokens: String {
        if self >= 1_000_000 { return String(format: "%.1fM", Double(self) / 1_000_000) }
        if self >= 1_000 { return String(format: "%.1fK", Double(self) / 1_000) }
        return "\(self)"
    }
}
