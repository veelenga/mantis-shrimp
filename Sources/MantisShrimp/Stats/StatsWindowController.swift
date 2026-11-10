import AppKit
import PostureCore
import SwiftUI

@MainActor
final class StatsWindowController {
    private static let title = "Posture statistics"
    private static let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]

    private let model: StatsViewModel
    private var window: NSWindow?

    init(store: PostureHistoryStore) {
        model = StatsViewModel(store: store)
    }

    func show() {
        model.load()
        let window = window ?? makeWindow()
        self.window = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let window = ClosableWindow(
            contentRect: NSRect(origin: .zero, size: StatsLayout.initialSize),
            styleMask: Self.styleMask,
            backing: .buffered,
            defer: false
        )
        window.title = Self.title
        window.isReleasedWhenClosed = false
        window.contentViewController = makeHostingController()
        window.setContentSize(StatsLayout.initialSize)
        window.center()
        return window
    }

    private func makeHostingController() -> NSHostingController<StatsView> {
        let controller = NSHostingController(rootView: StatsView(model: model))
        controller.sizingOptions = [.minSize]
        return controller
    }
}
