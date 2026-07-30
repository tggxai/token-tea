import Foundation

struct TokenUsage: Equatable, Sendable {
    var input = 0
    var cached = 0
    var output = 0
    var reasoning = 0

    var total: Int { input + output }
    var freshInput: Int { max(0, input - cached) }

    static func + (lhs: Self, rhs: Self) -> Self {
        .init(
            input: lhs.input + rhs.input,
            cached: lhs.cached + rhs.cached,
            output: lhs.output + rhs.output,
            reasoning: lhs.reasoning + rhs.reasoning
        )
    }
}

struct RateLimitSnapshot: Equatable, Sendable {
    let id: String
    let timestamp: Date
    let usedPercent: Double
    let windowMinutes: Int
    let resetsAt: Date?

    var remainingPercent: Double {
        min(100, max(0, 100 - usedPercent))
    }
}

enum TokenLogParser {
    static func parseLastUsage(from line: String) -> TokenUsage? {
        guard let data = line.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let payload = root["payload"] as? [String: Any],
              payload["type"] as? String == "token_count",
              let info = payload["info"] as? [String: Any],
              let usage = info["last_token_usage"] as? [String: Any]
        else { return nil }

        return TokenUsage(
            input: usage["input_tokens"] as? Int ?? 0,
            cached: usage["cached_input_tokens"] as? Int ?? 0,
            output: usage["output_tokens"] as? Int ?? 0,
            reasoning: usage["reasoning_output_tokens"] as? Int ?? 0
        )
    }
}

actor TokenUsageReader {
    private let fileManager = FileManager.default

    func usage(for date: Date = .now, calendar: Calendar = .current) -> TokenUsage {
        guard let folder = sessionFolder(for: date, calendar: calendar),
              let files = try? fileManager.contentsOfDirectory(
                at: folder,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
              )
        else { return .init() }

        var result = TokenUsage()
        for url in files where url.pathExtension == "jsonl" {
            guard let contents = try? String(contentsOf: url, encoding: .utf8) else { continue }
            for line in contents.split(separator: "\n") {
                if let usage = TokenLogParser.parseLastUsage(from: String(line)) {
                    result = result + usage
                }
            }
        }
        return result
    }

    private func sessionFolder(for date: Date, calendar: Calendar) -> URL? {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = parts.year, let month = parts.month, let day = parts.day else { return nil }
        return fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent(".codex/sessions")
            .appendingPathComponent(String(format: "%04d/%02d/%02d", year, month, day))
    }
}
