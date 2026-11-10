import Foundation

public struct PresenceState: Equatable {
    public static let initial = PresenceState(sittingDuration: 0, absentSince: nil)

    public let sittingDuration: TimeInterval
    public let absentSince: TimeInterval?

    public init(sittingDuration: TimeInterval, absentSince: TimeInterval?) {
        self.sittingDuration = sittingDuration
        self.absentSince = absentSince
    }

    public var sittingMinutes: Int {
        Int(sittingDuration / TimeInterval.secondsPerMinute)
    }

    public func absence(at time: TimeInterval) -> TimeInterval? {
        absentSince.map { time - $0 }
    }
}

public struct PresenceTracker {
    private var sitting = SittingTracker(breakDuration: MonitorTiming.Sitting.breakDuration)
    private var absentSince: TimeInterval?

    public private(set) var state = PresenceState.initial

    public init() {}

    @discardableResult
    public mutating func update(isPresent: Bool, at time: TimeInterval) -> PresenceState {
        let sittingDuration = sitting.update(isPresent: isPresent, at: time)
        absentSince = isPresent ? nil : (absentSince ?? time)
        state = PresenceState(sittingDuration: sittingDuration, absentSince: absentSince)
        return state
    }

    public mutating func reset() {
        sitting.reset()
        absentSince = nil
        state = .initial
    }
}
