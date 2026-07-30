import AppKit
import SwiftUI

struct DashboardView: View {
    @ObservedObject var model: UsageModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOKEN TEA")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(1.8)
                    Text("Usage remaining")
                        .font(.title2.bold())
                }
                Spacer()
                TeacupMeter(fraction: model.remainingFraction, tint: tint)
                    .frame(width: 72, height: 62)
            }

            if model.rateLimit != nil {
                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(model.remainingPercent)%")
                            .font(.system(size: 38, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                        Text("remaining")
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: model.remainingFraction)
                        .tint(tint)
                }
            } else {
                Text(model.errorMessage ?? "General Codex usage is unavailable.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let limit = model.rateLimit {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("General Codex usage")
                            .font(.headline)
                        Text(windowLabel(limit.windowMinutes))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let reset = limit.resetsAt {
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("Resets")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(reset, style: .relative)
                                .font(.headline)
                        }
                    }
                }
            }

            HStack(spacing: 0) {
                stat("Fresh input", model.usage.freshInput)
                Divider().frame(height: 34)
                stat("Cached", model.usage.cached)
                Divider().frame(height: 34)
                stat("Output", model.usage.output)
            }

            HStack {
                if let updated = model.lastUpdated {
                    Text("Updated \(updated, style: .relative) ago")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    Task { await model.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(model.isRefreshing)
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
            .font(.caption)
        }
        .padding(18)
        .frame(width: 340)
    }

    private var tint: Color {
        model.remainingFraction > 0.5 ? .green : model.remainingFraction > 0.2 ? .orange : .red
    }

    private func windowLabel(_ minutes: Int) -> String {
        if minutes >= 1_440 { return "\(minutes / 1_440)-day allowance" }
        if minutes >= 60 { return "\(minutes / 60)-hour allowance" }
        return "\(minutes)-minute allowance"
    }

    private func stat(_ label: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value.compactTokens).font(.headline.monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TeacupMeter: View {
    let fraction: Double
    let tint: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(systemName: "cup.and.heat.waves.fill")
                .font(.system(size: 50))
                .foregroundStyle(tint.opacity(0.18))
            Image(systemName: "cup.and.heat.waves.fill")
                .font(.system(size: 50))
                .foregroundStyle(tint)
                .mask(alignment: .bottom) {
                    Rectangle().frame(height: max(3, 62 * fraction))
                }
        }
        .accessibilityLabel("\(Int((fraction * 100).rounded()))% remaining")
    }
}
