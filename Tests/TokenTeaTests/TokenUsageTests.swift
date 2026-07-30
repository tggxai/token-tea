import Foundation
import Testing
@testable import TokenTea

@Test func parsesLastTokenUsage() {
    let line = """
    {"payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":120,"cached_input_tokens":80,"output_tokens":15,"reasoning_output_tokens":4}}}}
    """
    let usage = TokenLogParser.parseLastUsage(from: line)
    #expect(usage == TokenUsage(input: 120, cached: 80, output: 15, reasoning: 4))
    #expect(usage?.total == 135)
    #expect(usage?.freshInput == 40)
}

@Test func ignoresOtherEvents() {
    #expect(TokenLogParser.parseLastUsage(from: #"{"payload":{"type":"message"}}"#) == nil)
}

@Test func parsesRemainingRateLimit() {
    let data = Data("""
    {
      "rate_limit": {
        "primary_window": {
          "used_percent": 21,
          "limit_window_seconds": 604800,
          "reset_at": 1785915432
        },
        "secondary_window": {
          "used_percent": 10,
          "limit_window_seconds": 18000,
          "reset_at": 1785400000
        }
      },
      "additional_rate_limits": [{
        "limit_name": "GPT-5.3-Codex-Spark",
        "rate_limit": {
          "primary_window": { "used_percent": 0 }
        }
      }]
    }
    """
    .utf8)
    let limit = try! CodexUsageService.parseCoreLimit(from: data)
    #expect(limit.remainingPercent == 79)
    #expect(limit.windowMinutes == 10_080)
}
