import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = UsageModel()

    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private var modelChange: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.isVisible = true
        statusItem = item

        if let button = item.button {
            button.target = self
            button.action = #selector(togglePopover)
            button.imagePosition = .imageOnly
        }

        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 340, height: 390)
        popover.contentViewController = NSHostingController(rootView: DashboardView(model: model))

        modelChange = model.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async { self?.updateStatusItem() }
        }
        updateStatusItem()
        model.start()
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func updateStatusItem() {
        guard let button = statusItem?.button else { return }
        let percent = model.remainingPercent
        button.image = TeacupStatusImage.make(fraction: model.remainingFraction)
        button.title = ""
        button.toolTip = model.rateLimit == nil
            ? (model.errorMessage ?? "Codex allowance unavailable")
            : "\(percent)% Codex usage remaining"
        button.setAccessibilityLabel(button.toolTip ?? "Token Tea")
    }

}

enum TeacupStatusImage {
    static func make(fraction: Double) -> NSImage {
        let clamped = min(1, max(0, fraction))
        let color: NSColor = clamped > 0.5 ? .systemGreen : clamped > 0.2 ? .systemOrange : .systemRed

        let image = NSImage(size: NSSize(width: 21, height: 18), flipped: false) { _ in
            let bowl = NSBezierPath(
                roundedRect: NSRect(x: 2, y: 3, width: 13, height: 10),
                xRadius: 2,
                yRadius: 2
            )
            NSGraphicsContext.saveGraphicsState()
            bowl.addClip()
            color.setFill()
            NSBezierPath(
                rect: NSRect(x: 2, y: 3, width: 13, height: max(1, 10 * clamped))
            ).fill()
            NSGraphicsContext.restoreGraphicsState()

            color.setStroke()
            bowl.lineWidth = 1.5
            bowl.stroke()
            let handle = NSBezierPath(ovalIn: NSRect(x: 13, y: 5, width: 6, height: 6))
            handle.lineWidth = 1.5
            handle.stroke()

            for x in [6.0, 11.0] {
                let steam = NSBezierPath()
                steam.move(to: NSPoint(x: x, y: 14))
                steam.curve(
                    to: NSPoint(x: x, y: 18),
                    controlPoint1: NSPoint(x: x - 2, y: 15),
                    controlPoint2: NSPoint(x: x + 2, y: 17)
                )
                steam.lineWidth = 1.2
                steam.stroke()
            }
            return true
        }
        image.isTemplate = false
        return image
    }
}
