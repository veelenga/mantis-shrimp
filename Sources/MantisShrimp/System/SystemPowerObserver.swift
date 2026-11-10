import AppKit

@MainActor
final class SystemPowerObserver {
    private static let screenLocked = Notification.Name("com.apple.screenIsLocked")
    private static let screenUnlocked = Notification.Name("com.apple.screenIsUnlocked")

    var onScreenOff: (() -> Void)?
    var onScreenOn: (() -> Void)?
    var onLowPowerModeChange: ((Bool) -> Void)?

    private var tokens: [NSObjectProtocol] = []

    init() {
        let workspace = NSWorkspace.shared.notificationCenter
        let distributed = DistributedNotificationCenter.default()
        observe(workspace, [NSWorkspace.screensDidSleepNotification, NSWorkspace.willSleepNotification]) { $0.onScreenOff?() }
        observe(workspace, [NSWorkspace.screensDidWakeNotification, NSWorkspace.didWakeNotification]) { $0.onScreenOn?() }
        observe(distributed, [Self.screenLocked]) { $0.onScreenOff?() }
        observe(distributed, [Self.screenUnlocked]) { $0.onScreenOn?() }
        observe(.default, [.NSProcessInfoPowerStateDidChange]) { $0.onLowPowerModeChange?(ProcessInfo.processInfo.isLowPowerModeEnabled) }
    }

    var isLowPowerModeEnabled: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    private func observe(_ center: NotificationCenter, _ names: [Notification.Name], handler: @escaping (SystemPowerObserver) -> Void) {
        for name in names {
            let token = center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                guard let self else { return }
                MainActor.assumeIsolated { handler(self) }
            }
            tokens.append(token)
        }
    }
}
