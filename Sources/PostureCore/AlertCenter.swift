import Foundation

public struct AlertCenter {
    private var posture: AlertPolicy
    private var sitting = AlertPolicy.immediate(snoozeDuration: MonitorTiming.Sitting.snooze)

    public init(alertDelay: AlertDelay) {
        posture = Self.makePosturePolicy(for: alertDelay)
    }

    public mutating func updatePosture(hasIssues: Bool, at time: TimeInterval) {
        _ = posture.update(hasIssues: hasIssues, at: time)
    }

    public mutating func updateSitting(duration: TimeInterval, at time: TimeInterval) {
        _ = sitting.update(hasIssues: duration >= MonitorTiming.Sitting.limit, at: time)
    }

    public func currentAlert(for issues: Set<PostureIssue>, sittingMinutes: Int) -> MonitorAlert? {
        if posture.isAlerting, !issues.isEmpty {
            return .posture(issues)
        }
        if sitting.isAlerting {
            return .sittingTooLong(minutes: sittingMinutes)
        }
        return nil
    }

    public mutating func snooze(_ alert: MonitorAlert, at time: TimeInterval) {
        switch alert {
        case .posture: posture.snooze(at: time)
        case .sittingTooLong: sitting.snooze(at: time)
        }
    }

    public mutating func resetPosture() {
        posture.reset()
    }

    public mutating func reset() {
        posture.reset()
        sitting.reset()
    }

    public mutating func rebuildPosture(for alertDelay: AlertDelay) {
        posture = Self.makePosturePolicy(for: alertDelay)
    }

    private static func makePosturePolicy(for alertDelay: AlertDelay) -> AlertPolicy {
        AlertPolicy(delay: alertDelay, snoozeDuration: MonitorTiming.Alert.snooze)
    }
}
