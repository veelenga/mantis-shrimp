import Foundation
import PostureCore

final class SettingsStore {
    private static let key = "monitorSettings"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> MonitorSettings {
        guard let data = defaults.data(forKey: Self.key),
              let settings = try? JSONDecoder().decode(MonitorSettings.self, from: data) else {
            return MonitorSettings()
        }
        return settings
    }

    func importIfEmpty(from legacy: UserDefaults) {
        guard defaults.data(forKey: Self.key) == nil, let data = legacy.data(forKey: Self.key) else { return }
        defaults.set(data, forKey: Self.key)
    }

    func save(_ settings: MonitorSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: Self.key)
    }
}
