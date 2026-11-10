import AppKit
import PostureCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var monitor: PostureMonitor?
    private var statusBar: StatusBarController?
    private var alertBanner: AlertBannerController?
    private var powerObserver: SystemPowerObserver?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let settingsStore = SettingsStore()
        LegacyDataMigration.run(settingsStore: settingsStore)
        let historyStore = FileHistoryStore(directory: FileHistoryStore.defaultDirectory())
        let monitor = PostureMonitor(settingsStore: settingsStore, recorder: PostureRecorder(store: historyStore))
        statusBar = StatusBarController(
            monitor: monitor,
            statsWindow: StatsWindowController(store: historyStore),
            cameraWindow: CameraWindowController(monitor: monitor)
        )
        alertBanner = AlertBannerController(monitor: monitor)
        powerObserver = makePowerObserver(for: monitor)
        self.monitor = monitor
        monitor.start()
    }

    @MainActor
    private func makePowerObserver(for monitor: PostureMonitor) -> SystemPowerObserver {
        let observer = SystemPowerObserver()
        observer.onScreenOff = { monitor.suspend() }
        observer.onScreenOn = { monitor.resume() }
        observer.onLowPowerModeChange = { monitor.setLowPowerMode($0) }
        monitor.setLowPowerMode(observer.isLowPowerModeEnabled)
        return observer
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor?.shutDown()
    }
}
