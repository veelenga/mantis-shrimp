import Foundation

public struct AlertPolicy {
    private enum Mode {
        case off
        case after(AlertDelay.Schedule)
    }

    public private(set) var isAlerting = false

    private let mode: Mode
    private let snoozeDuration: TimeInterval
    private var accumulator = BadTimeAccumulator()
    private var snoozeState = Snooze()

    public init(delay: AlertDelay, snoozeDuration: TimeInterval) {
        mode = delay.schedule.map(Mode.after) ?? .off
        self.snoozeDuration = snoozeDuration
    }

    public init(threshold: TimeInterval, window: TimeInterval, snoozeDuration: TimeInterval) {
        mode = .after(AlertDelay.Schedule(badTime: threshold, window: window))
        self.snoozeDuration = snoozeDuration
    }

    public static func immediate(snoozeDuration: TimeInterval) -> AlertPolicy {
        AlertPolicy(threshold: 0, window: 0, snoozeDuration: snoozeDuration)
    }

    public var badSeconds: TimeInterval {
        accumulator.totalSeconds
    }

    public mutating func update(hasIssues: Bool, at time: TimeInterval) -> Bool {
        guard case .after(let schedule) = mode else { return false }
        accumulator.record(hasIssues: hasIssues, at: time, window: schedule.window)
        isAlerting = hasIssues && badSeconds >= schedule.badTime && !snoozeState.isActive(at: time)
        return isAlerting
    }

    public mutating func snooze(at time: TimeInterval) {
        snoozeState.start(at: time, duration: snoozeDuration)
        isAlerting = false
    }

    public mutating func reset() {
        accumulator.reset()
        isAlerting = false
    }
}
