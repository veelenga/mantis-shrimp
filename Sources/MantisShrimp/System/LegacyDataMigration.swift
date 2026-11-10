import Foundation
import PostureCore

enum LegacyDataMigration {
    private struct LegacyApp {
        let bundleID: String
        let folderName: String
    }

    private static let legacyApps = [
        LegacyApp(bundleID: "dev.veelenga.shrimp", folderName: "Shrimp"),
        LegacyApp(bundleID: "dev.veelenga.posturewatch", folderName: "PostureWatch"),
    ]

    static func run(settingsStore: SettingsStore) {
        for app in legacyApps {
            if let legacyDefaults = UserDefaults(suiteName: app.bundleID) {
                settingsStore.importIfEmpty(from: legacyDefaults)
            }
            moveHistoryIfMissing(from: app.folderName)
        }
    }

    private static func moveHistoryIfMissing(from folderName: String) {
        let fileManager = FileManager.default
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let legacy = support.appendingPathComponent(folderName, isDirectory: true)
        let current = FileHistoryStore.rootDirectory
        guard fileManager.fileExists(atPath: legacy.path), !fileManager.fileExists(atPath: current.path) else { return }
        try? fileManager.moveItem(at: legacy, to: current)
    }
}
