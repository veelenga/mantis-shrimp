import AppKit
import PostureCore

@MainActor
final class AlertBannerController {
    private let monitor: PostureMonitor
    private let panel = AlertBannerPanel()

    init(monitor: PostureMonitor) {
        self.monitor = monitor
        panel.onClick = { [weak self] in self?.monitor.snoozeAlert() }
        monitor.observe { [weak self] snapshot in self?.render(snapshot) }
    }

    private func render(_ snapshot: MonitorSnapshot) {
        guard let alert = snapshot.alert else {
            panel.hide()
            return
        }
        panel.show(AlertText.text(for: alert))
    }
}
