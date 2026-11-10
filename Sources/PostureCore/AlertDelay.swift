import Foundation

public enum AlertDelay: String, CaseIterable, Codable {
    case off = "off"
    case thirtySeconds = "30s"
    case oneMinute = "1m"
    case twoMinutes = "2m"
    case fiveMinutes = "5m"

    public struct Schedule: Equatable {
        public static let windowToBadTimeRatio: Double = 3

        public let badTime: TimeInterval
        public let window: TimeInterval

        public init(badTime: TimeInterval, window: TimeInterval) {
            self.badTime = badTime
            self.window = window
        }

        public init(badTime: TimeInterval) {
            self.init(badTime: badTime, window: badTime * Self.windowToBadTimeRatio)
        }
    }

    public var isEnabled: Bool {
        self != .off
    }

    public var schedule: Schedule? {
        switch self {
        case .off: nil
        case .thirtySeconds: Schedule(badTime: 30)
        case .oneMinute: Schedule(badTime: 60)
        case .twoMinutes: Schedule(badTime: 120)
        case .fiveMinutes: Schedule(badTime: 300)
        }
    }

    public var title: String {
        switch self {
        case .off: "Off"
        case .thirtySeconds: "30 seconds"
        case .oneMinute: "1 minute"
        case .twoMinutes: "2 minutes"
        case .fiveMinutes: "5 minutes"
        }
    }
}
