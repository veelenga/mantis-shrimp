import AppKit
import PostureCore

@MainActor
final class StatusBarController: NSObject, NSMenuDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let monitor: PostureMonitor
    private let statsWindow: StatsWindowController
    private let cameraWindow: CameraWindowController
    private let statusLine = NSMenuItem()
    private let pauseItem = NSMenuItem()
    private let launchAtLoginItem = NSMenuItem()
    private lazy var sensitivityMenu = OptionSubmenu<Sensitivity>(
        title: "Sensitivity",
        optionTitle: { $0.rawValue.capitalized },
        onSelect: { [weak self] sensitivity in
            guard let self else { return }
            monitor.setSensitivity(sensitivity)
            renderMenu(monitor.snapshot)
        }
    )
    private lazy var alertDelayMenu = OptionSubmenu<AlertDelay>(
        title: "Alert after",
        optionTitle: { $0.title },
        separatorAfter: .off,
        onSelect: { [weak self] delay in self?.monitor.setAlertDelay(delay) }
    )
    private lazy var framingMenu = OptionSubmenu<CameraFraming>(
        title: "Camera view",
        optionTitle: { $0.title },
        onSelect: { [weak self] framing in
            guard let self else { return }
            monitor.setCameraFraming(framing)
            renderMenu(monitor.snapshot)
        }
    )
    private var isMenuOpen = false
    private var iconKey: StatusIcon.Key?

    init(monitor: PostureMonitor, statsWindow: StatsWindowController, cameraWindow: CameraWindowController) {
        self.monitor = monitor
        self.statsWindow = statsWindow
        self.cameraWindow = cameraWindow
        super.init()
        let menu = buildMenu()
        menu.delegate = self
        item.menu = menu
        monitor.observe { [weak self] snapshot in self?.render(snapshot) }
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        statusLine.isEnabled = false
        menu.addItem(statusLine)
        menu.addItem(.separator())
        menu.addItem(action("Calibrate (sit well for 5 seconds)", #selector(calibrate)))
        menu.addItem(configure(pauseItem, action: #selector(togglePause)))
        menu.addItem(sensitivityMenu.menuItem)
        menu.addItem(alertDelayMenu.menuItem)
        menu.addItem(framingMenu.menuItem)
        menu.addItem(.separator())
        menu.addItem(action("Camera…", #selector(showCamera), key: "c"))
        menu.addItem(action("Statistics…", #selector(showStats), key: "s"))
        menu.addItem(.separator())
        menu.addItem(configure(launchAtLoginItem, title: "Launch at login", action: #selector(toggleLaunchAtLogin)))
        menu.addItem(action("Quit", #selector(quit), key: "q"))
        return menu
    }

    private func action(_ title: String, _ selector: Selector, key: String = "") -> NSMenuItem {
        configure(NSMenuItem(), title: title, action: selector, key: key)
    }

    private func configure(_ entry: NSMenuItem, title: String? = nil, action: Selector, key: String = "") -> NSMenuItem {
        if let title { entry.title = title }
        entry.action = action
        entry.keyEquivalent = key
        entry.target = self
        return entry
    }

    func menuWillOpen(_ menu: NSMenu) {
        isMenuOpen = true
        renderMenu(monitor.snapshot)
    }

    func menuDidClose(_ menu: NSMenu) {
        isMenuOpen = false
    }

    private func render(_ snapshot: MonitorSnapshot) {
        renderIcon(snapshot)
        if isMenuOpen {
            renderMenu(snapshot)
        }
    }

    private func renderIcon(_ snapshot: MonitorSnapshot) {
        let key = StatusIcon.key(for: snapshot)
        guard key != iconKey else { return }
        iconKey = key
        item.button?.image = StatusIcon.image(for: key)
    }

    private func renderMenu(_ snapshot: MonitorSnapshot) {
        statusLine.title = StatusText.line(for: snapshot)
        pauseItem.title = snapshot.phase == .paused ? "Resume" : "Pause"
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        sensitivityMenu.update(selected: monitor.settings.sensitivity)
        framingMenu.update(selected: monitor.settings.cameraFraming)
        alertDelayMenu.update(selected: monitor.settings.alertDelay)
    }

    @objc private func showCamera() {
        cameraWindow.show()
    }

    @objc private func showStats() {
        statsWindow.show()
    }

    @objc private func calibrate() {
        monitor.calibrate()
    }

    @objc private func togglePause() {
        if monitor.isRunning { monitor.pause() } else { monitor.start() }
    }

    @objc private func toggleLaunchAtLogin() {
        try? LaunchAtLogin.setEnabled(!LaunchAtLogin.isEnabled)
        renderMenu(monitor.snapshot)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
